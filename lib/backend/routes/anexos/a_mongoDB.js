const express = require('express');
const router = express.Router();
const { GridFSBucket, ObjectId } = require('mongodb');
const fs = require('fs');
const path = require('path');
const stream = require('stream'); 
const getMongoClient = require('../../services/mongoDBClient');
const createAnexo = require('../../formatos/anexos');

router.post('/', async (req, res) => {
    try {
        const client = await getMongoClient();
        const db = client.db();
        const bucket = new GridFSBucket(db);

        const pdfBuffer = await createAnexo(req.body);

        const bufferStream = new stream.PassThrough();
        bufferStream.end(pdfBuffer);

        const uploadStream = bucket.openUploadStream(
            req.body.id_contrato + '.pdf', // filename
            {
                metadata: {
                    tipo: 'Anexo',
                    id_anexo: req.body.id_anexo,
                    tipo_anexo: req.body.tipo,
                    fechaSubida: new Date()
                }
            }
        );
        bufferStream.pipe(uploadStream)
            .on('error', (error) => {
                res.status(500).json({ error: 'Error al subir Anexo PDF a GridFS', details: error.message });
            })
            res.json({ message: 'Anexo PDF generado y subido correctamente', fileId: uploadStream.id });
    } catch (error) {
        res.status(500).json({ error: 'Error general', details: error.message });
    }
})

module.exports = router;