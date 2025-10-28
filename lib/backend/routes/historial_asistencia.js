const express = require('express');
const multer = require('multer');
const { GridFSBucket, ObjectId } = require('mongodb');
const getMongoClient = require('../services/mongoDBClient');
const { PrismaClient } = require('@prisma/client');

const router = express.Router();

const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 } // límite 50MB
});

// POST /historial-asistencia/upload
// Solo guarda el archivo en GridFS y crea el registro en historial_asistencia (sin parseado)
router.post('/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No se envió ningún archivo' });

    const file = req.file;
    const obraId = req.body.obraId || null;

    const client = await getMongoClient();
    if (!client) return res.status(500).json({ error: 'No se pudo obtener la conexión a la base de datos' });

    const dbName = process.env.mongodbDB || 'sistema_acviis';
    const db = client.db(dbName);
    const bucket = new GridFSBucket(db, { bucketName: 'uploads' });

    const uploadStream = bucket.openUploadStream(file.originalname, {
      contentType: file.mimetype,
      metadata: {
        obraId,
        uploadedAt: new Date()
      }
    });

    uploadStream.end(file.buffer);

    uploadStream.on('finish', async () => {
      const fileId = uploadStream.id.toString();

      if (!obraId) {
        return res.status(201).json({ fileId, saved: false, message: 'Archivo guardado en GridFS, no se proporcionó obraId' });
      }

      const prisma = new PrismaClient();
      try {
        const created = await prisma.historial_asistencia.create({
          data: {
            id_excel: fileId,
            obraId: obraId
            // fecha_subida manejada por DB si aplica
          }
        });
        await prisma.$disconnect();

        return res.status(201).json({ fileId, saved: true, historialId: created.id });
      } catch (dbErr) {
        console.error('Prisma insert error:', dbErr);
        try { await prisma.$disconnect(); } catch(_) {}
        return res.status(500).json({ error: 'Error al guardar registro en historial_asistencia' });
      }
    });

    uploadStream.on('error', (err) => {
      console.error('GridFS upload error:', err);
      return res.status(500).json({ error: 'Error al guardar archivo en la base de datos' });
    });
  } catch (err) {
    console.error('Upload handler error:', err);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// GET /historial-asistencia/import/:obraId
// Devuelve el registro más reciente (sin parsear) y metadata básica del archivo en GridFS
const supabase = require('../services/supabaseClient');

router.get('/import/:obraId', async (req, res) => {
  const obraId = req.params.obraId;
  if (!obraId) return res.status(400).json({ error: 'obraId requerido' });

  try {
    const { data: rows, error: supErr } = await supabase
      .from('historial_asistencia')
      .select('*')
      .eq('obraId', obraId)
      .order('fecha_subida', { ascending: false })
      .limit(1);

    if (supErr) {
      console.error('Supabase error:', supErr);
      return res.status(500).json({ error: 'Error consultando historial en Supabase' });
    }
    if (!rows || rows.length === 0) {
      return res.status(404).json({ error: 'No se encontró historial para la obra' });
    }

    const historial = rows[0];
    const fileId = historial.id_excel;
    if (!fileId) return res.status(404).json({ error: 'Registro encontrado pero sin id_excel' });

    const client = await getMongoClient();
    if (!client) return res.status(500).json({ error: 'No se pudo obtener conexión a MongoDB' });
    const db = client.db(process.env.mongodbDB || 'sistema_acviis');
    const filesCol = db.collection('uploads.files');

    let fileMeta = null;
    try {
      fileMeta = await filesCol.findOne({ _id: new ObjectId(fileId) }, { projection: { filename: 1, contentType: 1, length: 1, uploadDate: 1, metadata: 1 } });
    } catch (err) {
      console.warn('No se pudo obtener metadata de GridFS:', err);
    }

    return res.json({ historialId: historial.id, fileId, fileMeta });
  } catch (err) {
    console.error('Import handler error:', err);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// GET /historial-asistencia/download/:fileId
// Descarga/stream del archivo almacenado en GridFS
router.get('/download/:fileId', async (req, res) => {
  const fileId = req.params.fileId;
  if (!fileId) return res.status(400).json({ error: 'fileId requerido' });

  try {
    const client = await getMongoClient();
    if (!client) return res.status(500).json({ error: 'No se pudo obtener conexión a MongoDB' });
    const db = client.db(process.env.mongodbDB || 'sistema_acviis');
    const bucket = new GridFSBucket(db, { bucketName: 'uploads' });

    let downloadStream;
    try {
      downloadStream = bucket.openDownloadStream(new ObjectId(fileId));
    } catch (err) {
      console.error('Invalid fileId for ObjectId:', err);
      return res.status(400).json({ error: 'fileId inválido' });
    }

    // Obtener metadata para headers (intenta leer uploads.files)
    const filesCol = db.collection('uploads.files');
    const meta = await filesCol.findOne({ _id: new ObjectId(fileId) });
    if (meta && meta.contentType) res.setHeader('Content-Type', meta.contentType);
    if (meta && meta.filename) res.setHeader('Content-Disposition', `attachment; filename="${meta.filename}"`);

    downloadStream.pipe(res).on('error', (err) => {
      console.error('GridFS download error:', err);
      if (!res.headersSent) res.status(500).json({ error: 'Error descargando archivo' });
    });
  } catch (err) {
    console.error('Download handler error:', err);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router;