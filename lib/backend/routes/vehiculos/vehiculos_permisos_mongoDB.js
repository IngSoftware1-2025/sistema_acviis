const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer();
const getMongoClient = require('../../services/mongoDBClient');
const { GridFSBucket, ObjectId } = require('mongodb');
const stream = require('stream');

// POST - Subir permiso de circulación
router.post('/upload-permiso', upload.single('permiso'), async (req, res) => {
  console.log('Recibiendo permiso de circulación...');
  
  try {
    if (!req.file) {
      console.log('No se recibió archivo');
      return res.status(400).json({ error: 'No se recibió archivo' });
    }
    
    const { vehiculoId } = req.body;
    if (!vehiculoId) {
      return res.status(400).json({ error: 'Se requiere el ID del vehículo' });
    }
    
    console.log('Archivo recibido:', req.file.originalname);
    console.log('Tamaño:', req.file.size, 'bytes');
    console.log('Vehículo ID:', vehiculoId);
    
    const client = await getMongoClient();
    const db = client.db();
    const bucket = new GridFSBucket(db);

    const bufferStream = new stream.PassThrough(); 
    bufferStream.end(req.file.buffer);

    const uploadStream = bucket.openUploadStream(req.file.originalname, {
      contentType: req.file.mimetype,
      metadata: {
        tipo: 'Permiso de Circulación',
        vehiculoId: vehiculoId,
        fechaSubida: new Date()
      }
    });

    bufferStream.pipe(uploadStream)
      .on('error', (error) => {
        console.error('Error en GridFS:', error);
        res.status(500).json({ error: 'Error al subir permiso a GridFS', details: error.message });
      })
      .on('finish', () => {
        console.log('Permiso guardado con ID:', uploadStream.id.toString());
        res.json({ 
          success: true, 
          fileId: uploadStream.id.toString(),
          message: 'Permiso de circulación subido correctamente'
        });
      });
  } catch (err) {
    console.error('Error general:', err);
    res.status(500).json({ error: err.message });
  }
});

// GET - Descargar permiso de circulación
router.get('/download-permiso/:id', async (req, res) => {
  try {
    const client = await getMongoClient();
    const db = client.db();
    const bucket = new GridFSBucket(db);

    const fileId = req.params.id;
    const _id = new ObjectId(fileId);

    const files = await db.collection('fs.files').find({ _id }).toArray();
    if (!files || files.length === 0) {
      return res.status(404).json({ error: 'Permiso no encontrado' });
    }

    res.set('Content-Type', files[0].contentType || 'application/pdf');
    res.set('Content-Disposition', `inline; filename="${files[0].filename}"`);

    const downloadStream = bucket.openDownloadStream(_id);
    downloadStream.pipe(res);
    downloadStream.on('error', () => {
      res.status(500).json({ error: 'Error al descargar el permiso' });
    });
  } catch (err) {
    console.error('Error al descargar permiso:', err);
    res.status(500).json({ error: err.message });
  }
});

// DELETE - Eliminar permiso de circulación
router.delete('/delete-permiso/:id', async (req, res) => {
  try {
    const client = await getMongoClient();
    const db = client.db();
    const bucket = new GridFSBucket(db);

    const fileId = req.params.id;
    const _id = new ObjectId(fileId);

    await bucket.delete(_id);
    
    console.log('Permiso eliminado con ID:', fileId);
    res.json({ 
      success: true, 
      message: 'Permiso eliminado correctamente' 
    });
  } catch (err) {
    console.error('Error al eliminar permiso:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
