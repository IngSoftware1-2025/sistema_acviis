const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.post('/', async (req, res) => {
    const {
        id_trabajador,
        id_contrato,
        duracion,
        tipo,
        parametros,
        comentario,
    } = req.body;
    //res.json(req.body);
    //return;
    try {
        const nuevoAnexo = await prisma.anexos.create({
            data: {
                id_contrato,
                fecha_de_creacion: new Date(),
                duracion,
                tipo,
                parametros,
            }
        });

        // Crear un comentario relacionado al anexo
        const nuevoComentario = await prisma.comentarios.create({
            data: {
                id_trabajadores: id_trabajador,
                id_anexo: nuevoAnexo.id, 
                comentario: comentario,
                fecha: new Date(),
            }
        });

        res.status(200).json({ anexo: nuevoAnexo, comentario: nuevoComentario });
    } catch {
        console.error(error);
        res.status(500).json({ error: 'No se pudo crear el anexo', details: error.message })
    }
});

module.exports = router;