const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// GET /contratos → todos
router.get('/', async (req, res) => {
  try {
    const contratos = await prisma.contratos.findMany({
      include: { trabajadores: true },
      orderBy: { id: 'desc' },
    });
    res.json(contratos);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener contratos' });
  }
});

// GET /contratos/:id → uno
router.get('/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    const contrato = await prisma.contratos.findUnique({
      where: { id },
      include: { trabajadores: true },
    });

    if (!contrato) return res.status(404).json({ error: 'Contrato no encontrado' });

    res.json(contrato);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener contrato' });
  }
});

// POST /contratos → crear uno
router.post('/', async (req, res) => {
  const {
    id_trabajadores,
    plazo_de_contrato,
    estado,
    fecha_de_contratacion,
  } = req.body;
  
  try {
    const nuevoContrato = await prisma.contratos.create({
      data: {
        id_trabajadores,
        plazo_de_contrato,
        estado,
        fecha_de_contratacion: new Date(fecha_de_contratacion),
      },
    });

    res.status(200).json(nuevoContrato);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'No se pudo crear el contrato', details: error.message });
  }
});

// PUT /contratos/:id → actualizar uno
router.put('/:id/estado', async (req, res) => {
  const { id } = req.params;
  const { estado } = req.body;
  try {
    const contratoActualizado = await prisma.contratos.update({
      where: { id },
      data: { estado },
    });
    res.json(contratoActualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar el estado del contrato', details: error.message });
  }
});

// PUT /contratos/:id/datos → actualizar varios campos de un contrato
router.put('/:id/datos', async (req, res) => {
  const { id } = req.params;
  const {
    plazo_de_contrato,
    estado
  } = req.body;
  try {
    const contratoActualizado = await prisma.contratos.update({
      where: { id },
      data: {
        plazo_de_contrato,
        estado,
      },
    });
    res.json(contratoActualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar el contrato', details: error.message });
  }
});

module.exports = router;