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
          const insertRow = {
            // enviar varias variantes del mismo campo para cubrir esquemas distintos
            obra_id: obraId,
            obraId: obraId,
            id_obra: obraId,
            id_excel: fileId,
            file_id: fileId,
            fileId: fileId,
            filename: file.originalname,
            fecha_subida: new Date().toISOString()
          };

          const { data, error } = await supabase
            .from('historial_asistencia')
            .insert([insertRow])
            .select();

          supResult = { data, error: error ? { message: error.message, details: error.details } : null };
          if (error) console.warn('Supabase insert warning:', error);
        }

        return res.status(201).json({ fileId, supResult });
      } catch (e) {
        console.error('Error registrando en Supabase tras upload:', e);
        return res.status(201).json({ fileId: uploadStream.id.toString(), supResult: { error: 'Error registrando en Supabase' } });
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
    // buscar por distintas columnas que puedan referenciar la obra, ordenar por fecha más reciente
    const obraKeys = ['obra_id', 'obraId', 'id_obra', 'obra'];
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

    return res.json({ fileId: fid, row: foundRow });
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
    return res.status(400).json({ error: 'fileId inválido' });
  }
  if (!fileDoc) return res.status(404).json({ error: 'Archivo no encontrado' });

  const bucket = new GridFSBucket(db, { bucketName: 'uploads' });
  const downloadStream = bucket.openDownloadStream(new ObjectId(fileId));

  const chunks = [];
  downloadStream.on('data', (c) => chunks.push(c));
  downloadStream.on('error', (err) => {
    console.error('GridFS download error:', err);
    if (!res.headersSent) return res.status(500).json({ error: 'Error leyendo archivo' });
  });
  downloadStream.on('end', () => {
    try {
      const buffer = Buffer.concat(chunks);
      // Leer con cellStyles para intentar obtener información de estilo (fills)
      const workbook = XLSX.read(buffer, { type: 'buffer', cellStyles: true });

      const sheets = workbook.SheetNames.map((name) => {
        const sheet = workbook.Sheets[name];
        // Si no hay rango, fallback a generar vacío
        const rangeRef = sheet['!ref'];
        if (!rangeRef) return { name, rows: [] };

        const range = XLSX.utils.decode_range(rangeRef);
        const rows = [];
        for (let r = range.s.r; r <= range.e.r; r++) {
          const row = [];
          for (let c = range.s.c; c <= range.e.c; c++) {
            const addr = XLSX.utils.encode_cell({ r, c });
            const cell = sheet[addr];
            if (!cell) {
              row.push(null);
              continue;
            }
            // valor
            const value = cell.v != null ? cell.v : null;
            // intentar extraer color de relleno (fill) si existe
            let color = null;
            try {
              // estructuras posibles: cell.s.fill.fgColor.rgb o cell.s.fgColor.rgb (según versión)
              if (cell.s && cell.s.fill && cell.s.fill.fgColor) {
                color = cell.s.fill.fgColor.rgb || cell.s.fill.fgColor; // fallback
              } else if (cell.s && cell.s.fgColor) {
                color = cell.s.fgColor.rgb || cell.s.fgColor;
              }
              // normalizar (string)
              if (color && typeof color !== 'string') color = String(color);
            } catch (e) {
              color = null;
            }

            // enviar objeto con value y color para que el frontend pueda interpretar
            row.push({ value, color });
          }
          rows.push(row);
        }
        return { name, rows };
      });

      return res.json({ fileId, filename: fileDoc.filename, metadata: fileDoc.metadata, sheets });
    } catch (err) {
      console.warn('Error parseando Excel:', err);
      const buffer = Buffer.concat(chunks);
      return res.json({ fileId, filename: fileDoc.filename, metadata: fileDoc.metadata, base64: buffer.toString('base64') });
    }
  });
});

module.exports = router;