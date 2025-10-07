const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer();
const getMongoClient = require('../services/mongoDBClient');
const { GridFSBucket, ObjectId } = require('mongodb');
const stream = require('stream');

// POST - Subir certificado (VERSIÓN CON LOGS)
router.post('/upload-certificado', upload.single('certificado'), async (req, res) => {
  console.log('📤 Recibiendo certificado EPP...');
  
  try {
    if (!req.file) {
      console.log('❌ No se recibió archivo');
      return res.status(400).json({ error: 'No se recibió archivo' });
    }
    
    console.log('📄 Archivo recibido:', req.file.originalname);
    console.log('📊 Tamaño:', req.file.size, 'bytes');
    
    const client = await getMongoClient();
    const db = client.db();
    const bucket = new GridFSBucket(db);

    const bufferStream = new stream.PassThrough();
    bufferStream.end(req.file.buffer);

    const uploadStream = bucket.openUploadStream(req.file.originalname, {
      contentType: req.file.mimetype,
      metadata: {
        tipo: 'Certificado EPP',
        fechaSubida: new Date()
      }
    });

    bufferStream.pipe(uploadStream)
      .on('error', (error) => {
        console.error('❌ Error en GridFS:', error);
        res.status(500).json({ error: 'Error al subir certificado a GridFS', details: error.message });
      })
      .on('finish', () => {
        console.log('✅ Certificado guardado con ID:', uploadStream.id.toString());
        res.json({ success: true, fileId: uploadStream.id.toString() });
      });
  } catch (err) {
    console.error('❌ Error general:', err);
    res.status(500).json({ error: err.message });
  }
});

// GET - Descargar certificado
router.get('/download-certificado/:id', async (req, res) => {
  try {
    const client = await getMongoClient();
    const db = client.db();
    const bucket = new GridFSBucket(db);

    const fileId = req.params.id;
    const _id = new ObjectId(fileId);

    const files = await db.collection('fs.files').find({ _id }).toArray();
    if (!files || files.length === 0) {
      return res.status(404).json({ error: 'Certificado no encontrado' });
    }

    res.set('Content-Type', files[0].contentType || 'application/pdf');
    res.set('Content-Disposition', `attachment; filename="${files[0].filename}"`);

    const downloadStream = bucket.openDownloadStream(_id);
    downloadStream.pipe(res);
    downloadStream.on('error', () => {
      res.status(500).json({ error: 'Error al descargar el certificado' });
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
