const express = require('express');
const router = express.Router();
const getMongoClient = require('../../services/mongoDBClient');
const fs = require('fs');
const path = require('path');

// Ruta de prueba para verificar conexión a MongoDB
router.get('/ping', async (req, res) => {
    try {
        const client = await getMongoClient();
        // El ping ya se realiza en getMongoClient, pero puedes hacer otro si quieres:
        const result = await client.db().command({ ping: 1 });
        res.json({ message: 'Conexión a MongoDB exitosa', result }); // Esta es la forma de devolver informacion para debug
    } catch (error) {
        res.status(500).json({ error: 'Error al conectar a MongoDB', details: error.message });
    }
});

router.post('/', async (req, res) => {
    try{
        const client = await getMongoClient();
        const db = client.db();
        const bucket = new (require('mongodb')).GridFSBucket(db);

        const filePath = path.join(__dirname, '../../../ui/assets/tests/test.jpg');
        const readStream = fs.createReadStream(filePath);

        const uploadStream = bucket.openUploadStream('test.jpg');
        readStream.pipe(uploadStream)
            .on('error', (error) => {
                res.status(500).json({ error: 'Error al subir archivo a GridFS', details: error.message });
            })
            .on('finish', async () => {
                // Aquí se agrega el documento a la colección 'contrato'
                try {
                    const contratoDoc = {
                        fileId: uploadStream.id, // ID de GridFS
                        fileName: 'test.jpg',
                        fecha: new Date(),
                        // ...Cambos que se quieran agregar
                    };
                    await db.collection('contrato').insertOne(contratoDoc);
                    res.json({ message: 'Archivo subido y documento creado en contrato', fileId: uploadStream.id });
                } catch (err) {
                    res.status(500).json({ error: 'Archivo subido pero error al crear documento en contrato', details: err.message });
                }
            });
    } catch (error) {

    }
});

module.exports = router;