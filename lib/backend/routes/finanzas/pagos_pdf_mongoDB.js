const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer();
const getMongoClient = require('../../services/mongoDBClient');
const { GridFSBucket } = require('mongodb');
const stream = require('stream');

router.post('/upload-pdf', upload.single('pdf'), async (req, res) => {
  try {
    const client = await getMongoClient();
    const db = client.db();
    const bucket = new GridFSBucket(db);

    // Subir PDF a GridFS desde buffer
    const bufferStream = new stream.PassThrough();
    bufferStream.end(req.file.buffer);

    const uploadStream = bucket.openUploadStream(req.file.originalname, {
      contentType: req.file.mimetype,
      metadata: {
        tipo: 'Factura',
        fechaSubida: new Date()
      }
    });

    bufferStream.pipe(uploadStream)
      .on('error', (error) => {
        res.status(500).json({ error: 'Error al subir PDF a GridFS', details: error.message });
      })
      .on('finish', () => {
        res.json({ success: true, fileId: uploadStream.id });
      });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;