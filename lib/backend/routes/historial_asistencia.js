const express = require('express');
const multer = require('multer');
const { GridFSBucket } = require('mongodb');
const getMongoClient = require('../services/mongoDBClient');
const { PrismaClient } = require('@prisma/client');

const router = express.Router();


const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 } // límite 50MB
});

// POST /historial-asistencia/upload
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

      // Validación de que obraId este presente
      if (!obraId) {
        return res.status(201).json({ fileId, saved: false, message: 'Archivo guardado en GridFS, no se proporcionó obraId' });
      }

      // Guardar en la tabla historial_asistencia
      const prisma = new PrismaClient();
      try {
        const created = await prisma.historial_asistencia.create({
          data: {
            id_excel: fileId,
            obraId: obraId
            // fecha_subida se asigna por defecto en la BD
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

module.exports = router;