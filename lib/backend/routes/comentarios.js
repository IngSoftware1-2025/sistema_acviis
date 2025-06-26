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

// GET /comentarios/contrato/:idContrato
router.get('/contrato/:idContrato', async (req, res) => {
  try {
    const { idContrato } = req.params;
    const comentarios = await prisma.comentarios.findMany({
      where: { id_contrato: idContrato }
    });
    res.json(comentarios);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
// GET /comentarios/trabajador/:idTrabajador
router.get('/trabajador/:idTrabajador', async (req, res) => {
  try {
    const { idTrabajador } = req.params;
    const comentarios = await prisma.comentarios.findMany({
      where: { id_trabajadores: idTrabajador }
    });
    res.json(comentarios);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /comentarios/anexo/:idAnexo
router.get('/anexo/:idAnexo', async (req, res) => {
  try {
    const { idAnexo } = req.params;
    const comentarios = await prisma.comentarios.findMany({
      where: { id_anexo: idAnexo }
    });
    res.json(comentarios);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;