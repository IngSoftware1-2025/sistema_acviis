const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// GET todos los proveedores
router.get('/', async (req, res) => {
  try {
    const proveedores = await prisma.proveedores.findMany({
      orderBy: { id: 'desc' }
    });
    res.json(proveedores);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener proveedores' });
  }
});

// GET proveedor por id
router.get('/:id', async (req, res) => {
  const id = req.params.id;
  try {
    const proveedor = await prisma.proveedores.findUnique({ where: { id } });
    if (!proveedor) return res.status(404).json({ error: 'Proveedor no encontrado' });
    res.json(proveedor);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener proveedor', details: err.message });
  }
});

// POST crear proveedor
router.post('/', async (req, res) => {
  const {
    nombre,
    rut,
    direccion,
    correo_electronico,
    telefono,
    estado,
    fecha_registro
  } = req.body;

  if (!nombre || !rut || !correo_electronico) {
    return res.status(400).json({ error: 'Nombre, RUT y correo electrónico requeridos' });
  }

  try {
    const nuevo = await prisma.proveedores.create({
      data: {
        nombre,
        rut,
        direccion,
        correo_electronico,
        telefono,
        estado: estado || 'Activo',
        fecha_registro: fecha_registro ? new Date(fecha_registro) : new Date(),
      },
    });
    res.status(201).json(nuevo);
  } catch (error) {
    if (error.code === 'P2002' && error.meta?.target?.includes('rut')) {
      return res.status(409).json({ error: 'RUT ya registrado' });
    }
    res.status(500).json({ error: 'No se pudo crear proveedor', details: error.message });
  }
});

// PUT actualizar proveedor
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const {
    nombre,
    rut,
    direccion,
    correo_electronico,
    telefono,
    estado
  } = req.body;

  try {
    const actualizado = await prisma.proveedores.update({
      where: { id },
      data: {
        nombre,
        rut,
        direccion,
        correo_electronico,
        telefono,
        estado,
      },
    });
    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar proveedor', details: error.message });
  }
});

// DELETE eliminar proveedor
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await prisma.proveedores.delete({ where: { id } });
    res.json({ message: 'Proveedor eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'No se pudo eliminar proveedor', details: error.message });
  }
});

module.exports = router;