const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// POST /comentarios
router.post('/', async (req, res) => {
  try {
    const { id_trabajadores, id_contrato, fecha, comentario } = req.body;
    
    if (!id_trabajadores || !comentario || !fecha) {
      return res.status(400).json({ error: 'Faltan campos obligatorios.' });
    }
    const idContratoFinal = id_contrato && id_contrato !== '' ? id_contrato : null;
    const nuevoComentario = await prisma.comentarios.create({
      data: {
        id_trabajadores,
        comentario,
        fecha: new Date(fecha),
        id_contrato: idContratoFinal,
      },
    });

    res.status(201).json(nuevoComentario);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;