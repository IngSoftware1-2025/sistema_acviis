const express = require('express');
const router = express.Router();
const { GridFSBucket, ObjectId } = require('mongodb');
const fs = require('fs');
const path = require('path');
const stream = require('stream'); 
const getMongoClient = require('../../services/mongoDBClient');
const { createAnexo, createAnexoTemporal } = require('../../formatos/anexos/anexos');

router.post('/', async (req, res) => {
    try {
        const client = await getMongoClient();
        const db = client.db();
        const bucket = new GridFSBucket(db);

        const pdfBuffer = await createAnexo(req.body.parametros.tipo, req.body.parametros);

        const bufferStream = new stream.PassThrough();
        bufferStream.end(pdfBuffer);

        const uploadStream = bucket.openUploadStream(
            req.body.id_contrato + '.pdf', // filename
            {
                metadata: {
                    tipo: 'Anexo',
                    id_anexo: req.body.id_anexo,
                    tipo_anexo: req.body.parametros.tipo,
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

router.get('/descargar-pdf/:id', async (req, res) => {
    try {
        const client = await getMongoClient();
        const db = client.db();
        const bucket = new GridFSBucket(db);
        const id = req.params.id.trim();
        // 1. Buscar por metadata.id_anexo
        let filesCursor = bucket.find({ 'metadata.id_anexo': id });
        let files = await filesCursor.toArray();
        // 2. Si no encuentra, buscar por filename (con y sin .pdf)
        if (!files || files.length === 0) {
            filesCursor = bucket.find({ filename: id });
            files = await filesCursor.toArray();
        }
        if (!files || files.length === 0) {
            filesCursor = bucket.find({ filename: id + '.pdf' });
            files = await filesCursor.toArray();
        }
        if (!files || files.length === 0) {
            return res.status(404).json({ error: 'PDF no encontrado para este anexo.' });
        }
        const file = files[0];
        res.set('Content-Type', 'application/pdf');
        res.set('Content-Disposition', `attachment; filename="${file.filename}"`);
        const downloadStream = bucket.openDownloadStream(file._id);
        downloadStream.pipe(res);
    } catch (error) {
        res.status(500).json({ error: 'Error al descargar el PDF', details: error.message });
    }
});

module.exports = router;