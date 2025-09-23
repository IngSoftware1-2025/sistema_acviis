const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const createFichaProveedor = require('../formatos/ficha_proveedores');

// GET todos los proveedores
router.get('/', async (req, res) => {
  try {
    const proveedores = await prisma.proveedores.findMany();
    res.json(proveedores);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo obtener proveedores', details: error.message });
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
    rut,
    direccion,
    nombre_vendedor,
    producto_servicio,
    correo_vendedor,
    telefono_vendedor,
    credito_disponible,
    fecha_registro
  } = req.body;

  if (!rut || !nombre_vendedor || !producto_servicio || !correo_vendedor) {
    return res.status(400).json({ error: 'Campos obligatorios faltantes' });
  }

  try {
    const nuevo = await prisma.proveedores.create({
      data: {
        rut,
        direccion,
        nombre_vendedor,
        producto_servicio,
        correo_vendedor,
        telefono_vendedor,
        credito_disponible: Number(credito_disponible) || 0,
        fecha_registro: fecha_registro ? new Date(fecha_registro) : new Date(),
        estado: 'activo', // <-- Agregado
      },
    });
    res.status(201).json(nuevo);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo crear proveedor', details: error.message });
  }
});

// PUT actualizar proveedor
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const {
    rut,
    direccion,
    nombre_vendedor,
    producto_servicio,
    correo_vendedor,
    telefono_vendedor,
    credito_disponible,
    fecha_registro,
    estado // <-- Agregado
  } = req.body;

  try {
    const actualizado = await prisma.proveedores.update({
      where: { id },
      data: {
        rut,
        direccion,
        nombre_vendedor,
        producto_servicio,
        correo_vendedor,
        telefono_vendedor,
        credito_disponible: credito_disponible !== undefined ? Number(credito_disponible) : undefined,
        fecha_registro: fecha_registro ? new Date(fecha_registro) : undefined,
        estado, // <-- Agregado
      },
    });
    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar proveedor', details: error.message });
  }
});

// PUT actualizar estado del proveedor
router.put('/:id/estado', async (req, res) => {
  const { id } = req.params;
  const { estado } = req.body;
  try {
    const actualizado = await prisma.proveedores.update({
      where: { id },
      data: { estado },
    });
    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar estado', details: error.message });
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

// DELETE eliminar proveedores por filtro
router.delete('/eliminar-por-filtro', async (req, res) => {
  const {
    rut,
    nombre_vendedor,
    producto_servicio,
    credito_min,
    credito_max
  } = req.body;

  try {
    // Construye el filtro dinámicamente
    const where = {};
    if (rut) where.rut = rut;
    if (nombre_vendedor) where.nombre_vendedor = nombre_vendedor;
    if (producto_servicio) where.producto_servicio = producto_servicio;
    if (credito_min !== undefined || credito_max !== undefined) {
      where.credito_disponible = {};
      if (credito_min !== undefined) where.credito_disponible.gte = Number(credito_min);
      if (credito_max !== undefined) where.credito_disponible.lte = Number(credito_max);
    }

    // Busca los proveedores que cumplen el filtro
    const proveedores = await prisma.proveedores.findMany({ where });
    const ids = proveedores.map(p => p.id);

    // Elimina todos los proveedores encontrados
    await prisma.proveedores.deleteMany({
      where: { id: { in: ids } }
    });

    res.json({ message: `Eliminados ${ids.length} proveedores por filtro.` });
  } catch (error) {
    res.status(500).json({ error: 'No se pudo eliminar proveedores por filtro', details: error.message });
  }
});

// GET ficha PDF de proveedor por id
router.get('/:id/pdf', async (req, res) => {
  const id = req.params.id;
  try {
    const proveedor = await prisma.proveedores.findUnique({ where: { id } });
    if (!proveedor) return res.status(404).json({ error: 'Proveedor no encontrado' });

    // Genera el PDF
    const pdfBuffer = await createFichaProveedor(proveedor);

    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="ficha_proveedor_${proveedor.rut}.pdf"`,
      'Content-Length': pdfBuffer.length,
    });
    res.send(pdfBuffer);
  } catch (err) {
    res.status(500).json({ error: 'Error al generar ficha PDF', details: err.message });
  }
});

// GET proveedores por filtro
router.get('/por-filtro', async (req, res) => {
  const { rut, nombre_vendedor, producto_servicio, credito_min, credito_max } = req.query;
  const where = {};
  if (rut) where.rut = rut;
  if (nombre_vendedor) where.nombre_vendedor = nombre_vendedor;
  if (producto_servicio) where.producto_servicio = producto_servicio;
  if (credito_min || credito_max) {
    where.credito_disponible = {};
    if (credito_min) where.credito_disponible.gte = Number(credito_min);
    if (credito_max) where.credito_disponible.lte = Number(credito_max);
  }
  try {
    const proveedores = await prisma.proveedores.findMany({ where });
    res.json(proveedores);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo obtener proveedores', details: error.message });
  }
});

module.exports = router;