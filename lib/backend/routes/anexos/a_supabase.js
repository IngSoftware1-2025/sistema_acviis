const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.post('/', async (req, res) => {
    const {
        id_trabajador,
        id_contrato,
        parametros,
        comentario
    } = req.body;
    // Convertir parametros a String si no lo es
    const parametrosStr = typeof parametros === 'string' ? parametros : JSON.stringify(parametros);

    
    /*
    const {
        id_trabajador,
        id_contrato,
        duracion,
        tipo,
        parametros,
        comentario,
    } = req.body;
    */
    //res.json(req.body);
    //return;
    try {
        const nuevoAnexo = await prisma.anexos.create({
            data: {
                id_contrato,
                fecha_de_creacion: new Date(),
                parametros: parametrosStr, // <-- aquí usas el string
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
    } catch (error) {
        console.error('Error al crear el anexo o comentario:', error);
        res.status(500).json({
            error: 'No se pudo crear el anexo o comentario',
            details: error?.message || 'Error desconocido'
        });
    }
});

module.exports = router;