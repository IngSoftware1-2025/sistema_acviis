const express = require('express');
const router = express.Router();
const { ObjectId, GridFSBucket } = require('mongodb');
const getMongoClient = require('../../services/mongoDBClient');

router.get('/download-pdf/:id', async (req, res) => {
  try {
    const client = await getMongoClient();
    const db = client.db();
    const bucket = new GridFSBucket(db);

    const fileId = req.params.id;
    const _id = new ObjectId(fileId);

    const files = await db.collection('fs.files').find({ _id }).toArray();
    if (!files || files.length === 0) {
      return res.status(404).json({ error: 'Archivo no encontrado' });
    }

    res.set('Content-Type', files[0].contentType || 'application/pdf');
    res.set('Content-Disposition', `attachment; filename="${files[0].filename}"`);

    const downloadStream = bucket.openDownloadStream(_id);
    downloadStream.pipe(res);
    downloadStream.on('error', () => {
      res.status(500).json({ error: 'Error al descargar el archivo' });
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;