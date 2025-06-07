const express = require('express');
const router = express.Router();
const { GridFSBucket, ObjectId } = require('mongodb');
const getMongoClient = require('../../services/mongoDBClient');
const fs = require('fs');
const path = require('path');
const createContract = require('../../formatos/contratos')
const stream = require('stream'); 

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
    try {
        const { nombre, apellido } = req.body; // Asegúrate de recibir estos campos
        const client = await getMongoClient();
        const db = client.db();
        const bucket = new GridFSBucket(db);

        // 1. Genera el PDF en memoria usando tu función
        const pdfBuffer = await createContract(req.body);

        // 2. Subir PDF a GridFS directamente desde el stream
        const bufferStream = new stream.PassThrough();
        bufferStream.end(pdfBuffer);

        const uploadStream = bucket.openUploadStream(`${nombre}_${apellido}_contrato.pdf`);
        bufferStream.pipe(uploadStream)
            .on('error', (error) => {
                res.status(500).json({ error: 'Error al subir PDF a GridFS', details: error.message });
            })
            .on('finish', async () => {
                // 3. Guarda referencia en la colección 'contrato'
                try {
                    const contratoDoc = {
                        fileId: uploadStream.id,
                        filename: `${nombre}_${apellido}_contrato.pdf`,
                        fecha: new Date(),
                        /*
                        nombre,
                        apellido,
                        rut,
                        ...otros
                        */
                    };
                    await db.collection('contrato').insertOne(contratoDoc);
                    res.json({ message: 'PDF generado y subido correctamente', fileId: uploadStream.id });
                } catch (err) {
                    res.status(500).json({ error: 'PDF subido pero error al crear documento en contrato', details: err.message });
                }
            });
    } catch (error) {
        res.status(500).json({ error: 'Error general', details: error.message });
    }
});

router.get('/', async (req, res) => {
    try {
        const { fileId } = req.query;
        if (!fileId) {
            return res.status(400).json({ error: 'Falta el parámetro fileId' });
        }

        const client = await getMongoClient();
        const db = client.db();
        const bucket = new GridFSBucket(db);

        // Buscar el archivo en GridFS
        const downloadStream = bucket.openDownloadStream(new ObjectId(fileId));

        res.set('Content-Type', 'application/pdf');
        res.set('Content-Disposition', 'inline; filename="contrato.pdf"');

        downloadStream.on('error', (err) => {
            res.status(404).json({ error: 'Archivo no encontrado', details: err.message });
        });

        downloadStream.pipe(res);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener el contrato', details: error.message });
    }
});

// Este get es solo para testing, lo ideal despues seria buscar por los metadatos guardados en el db contrato
router.get('/por-nombre', async (req, res) => {
    try {
        const { filename } = req.query;
        if (!filename) {
            return res.status(400).json({ error: 'Falta el parámetro filename' });
        }

        const client = await getMongoClient();
        const db = client.db();
        const bucket = new GridFSBucket(db);

        // Busca el id desde la coleccion contrato
        const fileDoc = await db.collection('contrato').findOne({ filename });
        if (!fileDoc) {
            return res.status(404).json({ error: `Archivo no encontrado ${filename}` });
        }
        // Busca el contrato en fs.files con el id porporcionado en la coleccion contrato
        const file = await db.collection('fs.files').findOne({ _id: fileDoc.fileId });
        if (!file) {
            return res.status(404).json({ error: `Archivo no encontrado en fs.files para filename ${filename}` });
        }
        const downloadStream = bucket.openDownloadStream(file._id);

        res.set('Content-Type', 'application/pdf');
        res.set('Content-Disposition', `inline; filename="${filename}"`);

        downloadStream.on('error', (err) => {
            res.status(404).json({ error: 'Archivo no encontrado', details: err.message });
        });

        downloadStream.pipe(res);
    } catch(error) {
        res.status(500).json({ error: 'Error al obtener el contrato', details: error.message });
    }
})

/*
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
*/
module.exports = router;