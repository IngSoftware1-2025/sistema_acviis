const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// GET /trabajadores → todos
router.get('/', async (req, res) => {
  try {
    const trabajador = await prisma.trabajador.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.json(trabajador);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener trabajadores' });
  }
});

// GET /trabajadores/:id → uno
router.get('/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    const trabajador = await prisma.trabajador.findUnique({ where: { id } });
    if (!trabajador) return res.status(404).json({ error: 'Trabajador no encontrado' });
    res.json(trabajador);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener trabajador' });
  }
});

// POST /trabajadores → crear uno
router.post('/', async (req, res) => {
  const { nombre, apellido, email, edad } = req.body;

  if (!nombre || !email) {
    return res.status(400).json({ error: 'Nombre y email requeridos' });
  }

  try {
    const nuevo = await prisma.trabajador.create({
      data: {
        nombre,
        apellido: apellido || null,
        email,
        edad: edad ? parseInt(edad, 10) : null,
      },
    });
    res.status(201).json(nuevo);
  } catch (error) {
    if (error.code === 'P2002' && error.meta?.target?.includes('email')) {
      return res.status(409).json({ error: 'Email ya registrado' });
    }
    res.status(500).json({ error: 'No se pudo crear trabajador', details: error.message });
  }
});

module.exports = router;
