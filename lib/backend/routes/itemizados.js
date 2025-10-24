const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// GET todos los itemizados
router.get('/', async (req, res) => {
  try {
    const itemizados = await prisma.itemizados.findMany({
      select: {
        id: true,
        nombre: true,
        monto_disponible: true
      }
    });
    res.json(itemizados);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener itemizados' });
  }
});

// POST crear un nuevo itemizado
router.post('/', async (req, res) => {
  try {
    const payload = { ...req.body };
    // eliminar id si viene en el body
    delete payload.id;

    // validación básica
    if (!payload.nombre) {
      return res.status(400).json({ error: 'El campo "nombre" es requerido' });
    }

    // Crear el itemizado en la base de datos
    const nuevo = await prisma.itemizados.create({
      data: payload,
    });

    res.status(201).json(nuevo);
  } catch (error) {
    console.error('Error al crear itemizado:', error);
    res.status(500).json({ error: 'Error al crear itemizado' });
  }
});

module.exports = router;
