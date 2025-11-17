const express = require('express');
const multer = require('multer');
const { GridFSBucket, ObjectId } = require('mongodb');
const getMongoClient = require('../services/mongoDBClient');
const supabase = require('../services/supabaseClient');
const XLSX = require('xlsx');

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } }); // 50MB

// POST /historial-asistencia/upload-register
// Recibe un archivo Excel, lo guarda en GridFS, registra un row en Supabase(historial_asistencia)
// y devuelve el fileId (id de GridFS) y el resultado del registro en Supabase.
router.post('/upload-register', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No se envió ningún archivo (campo "file")' });

    const file = req.file;
    // admitir obraId en distintos nombres de campo por compatibilidad
    const obraId = req.body?.obraId ?? req.body?.obra_id ?? req.body?.id_obra ?? null;

    const client = await getMongoClient();
    if (!client) return res.status(500).json({ error: 'No se pudo conectar a MongoDB' });

    const dbName = process.env.mongodbDB || 'sistema_acviis';
    const db = client.db(dbName);
    const bucket = new GridFSBucket(db, { bucketName: 'uploads' });

    const uploadStream = bucket.openUploadStream(file.originalname, {
      contentType: file.mimetype,
      metadata: {
        obraId,
        filename: file.originalname,
        uploadedAt: new Date().toISOString()
      }
    });

    uploadStream.end(file.buffer);

    uploadStream.on('error', (err) => {
      console.error('GridFS upload error:', err);
      if (!res.headersSent) return res.status(500).json({ error: 'Error al guardar archivo en MongoDB' });
    });

    uploadStream.on('finish', async () => {
      try {
        const fileId = uploadStream.id.toString();

        // Intentar insertar registro en Supabase en la tabla 'historial_asistencia'
        let supResult = null;
        if (!supabase) {
          console.warn('Supabase client no inicializado; no se registró en Supabase');
        } else {
          // si el cliente envió fecha_subida (desde el dispositivo), usarla; si no, usar la fecha del servidor
          const clientFecha = req.body && req.body.fecha_subida ? req.body.fecha_subida : new Date().toISOString();
          const insertRow = {
            obraId: obraId,
            id_excel: fileId,
            fecha_subida: clientFecha
          };

          const { data, error } = await supabase
            .from('historial_asistencia')
            .insert([insertRow])
            .select();

          supResult = { data, error: error ? { message: error.message, details: error.details } : null };
          if (error) console.warn('Supabase insert warning:', error);
        }

        // devolver id_excel (en vez de fileId)
        return res.status(201).json({ id_excel: fileId, supResult });
      } catch (e) {
        console.error('Error registrando en Supabase tras upload:', e);
        return res.status(201).json({ id_excel: uploadStream.id.toString(), supResult: { error: 'Error registrando en Supabase' } });
      }
    });
  } catch (err) {
    console.error('Upload-register handler error:', err);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// GET /historial-asistencia/import/:obraId
// Devuelve el fileId del último excel registrado en la tabla historial_asistencia para la obra.
router.get('/import/:obraId', async (req, res) => {
  const obraId = req.params.obraId;
  if (!obraId) return res.status(400).json({ error: 'obraId requerido' });

  if (!supabase) return res.status(500).json({ error: 'Cliente Supabase no inicializado' });

  try {
    // buscar por la columna que realmente existe en la tabla
    const obraKeys = ['obraId'];
    const fileKeys = ['id_excel', 'file_id', 'fileId', 'gridfs_id', 'mongo_file_id', 'file'];

    let foundRow = null;
    for (const key of obraKeys) {
      const { data, error } = await supabase
        .from('historial_asistencia')
        .select('*')
        .eq(key, obraId)
        .order('fecha_subida', { ascending: false })
        .limit(1);

      if (error) {
        // intentar ordenar por created_at si fecha_subida no existe
        const alt = await supabase
          .from('historial_asistencia')
          .select('*')
          .eq(key, obraId)
          .order('created_at', { ascending: false })
          .limit(1);
        if (!alt.error && alt.data && alt.data.length > 0) {
          foundRow = alt.data[0];
          break;
        }
        continue;
      }
      if (data && data.length > 0) {
        foundRow = data[0];
        break;
      }
    }

    if (!foundRow) {
      return res.status(404).json({ error: 'No se encontró historial para la obra en Supabase' });
    }

    // extraer fileId del row
    let fid = null;
    for (const k of fileKeys) {
      if (Object.prototype.hasOwnProperty.call(foundRow, k) && foundRow[k]) {
        fid = String(foundRow[k]);
        break;
      }
    }

    if (!fid) {
      // intentar buscar ObjectId dentro de strings
      const values = Object.values(foundRow);
      for (const v of values) {
        if (typeof v === 'string') {
          const m = v.match(/([0-9a-fA-F]{24})/);
          if (m) {
            fid = m[1];
            break;
          }
        }
      }
    }

    if (!fid) {
      return res.status(404).json({ error: 'Registro encontrado pero no contiene id del archivo', row: foundRow });
    }

    // devolver id_excel en la respuesta
    return res.json({ id_excel: fid, row: foundRow });
  } catch (err) {
    console.error('Error buscando último excel en Supabase:', err);
    return res.status(500).json({ error: 'Error interno buscando en Supabase' });
  }
});

// GET /historial-asistencia/file/:fileId
router.get('/file/:fileId', async (req, res) => {
  const fileId = req.params.fileId;
  if (!fileId) return res.status(400).json({ error: 'fileId requerido' });

  const client = await getMongoClient();
  if (!client) return res.status(500).json({ error: 'No se pudo conectar a MongoDB' });

  const dbName = process.env.mongodbDB || 'sistema_acviis';
  const db = client.db(dbName);
  const filesCol = db.collection('uploads.files');

  let fileDoc;
  try {
    fileDoc = await filesCol.findOne({ _id: new ObjectId(fileId) });
  } catch (err) {
    console.error('/file/:fileId invalid id:', err);
    return res.status(400).json({ error: 'fileId inválido' });
  }

  if (!fileDoc) return res.status(404).json({ error: 'Archivo no encontrado' });

  try {
    const bucket = new GridFSBucket(db, { bucketName: 'uploads' });
    const downloadStream = bucket.openDownloadStream(new ObjectId(fileId));

    const contentType = fileDoc.contentType || 'application/octet-stream';
    const filename = (fileDoc.filename || `file_${fileId}`).toString().replace(/["\r\n]/g, '');

    res.setHeader('Content-Type', contentType);
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

    downloadStream.on('error', (err) => {
      console.error('GridFS download error:', err);
      if (!res.headersSent) res.status(500).json({ error: 'Error al leer el archivo' });
      downloadStream.destroy();
    });

    // Si el cliente cierra la conexión, cerrar el stream de GridFS
    req.on('close', () => {
      if (!res.writableEnded) {
        try { downloadStream.destroy(); } catch (_) {}
      }
    });

    // Pipe directo al response (stream binario)
    downloadStream.pipe(res);
  } catch (err) {
    console.error('Error en /file/:fileId handler:', err);
    if (!res.headersSent) res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router;