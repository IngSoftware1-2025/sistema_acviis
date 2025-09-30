const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// GET todos los EPPs
router.get('/', async (req, res) => {
  try {
    const epps = await prisma.epp.findMany({
      orderBy: { id: 'desc' },
    });

    // ⚡ MAPEAR CAMPOS CORRECTAMENTE:
    const eppsFormateados = epps.map(epp => ({
      id: epp.id,
      tipo: epp.tipo,
      obrasAsignadas: epp.obras_asignadas || [], // ← snake_case → camelCase
      cantidad: epp.cantidad,
      certificadoId: epp.certificado_id,
      fechaRegistro: epp.fecha_registro
    }));

    res.json(eppsFormateados);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener EPPs' });
  }
});

// GET EPP por ID
router.get('/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  
  if (isNaN(id)) {
    return res.status(400).json({ error: 'ID de EPP inválido (debe ser un número)' });
  }

  try {
    const epp = await prisma.epp.findUnique({ 
      where: { id }
    });
    
    if (!epp) return res.status(404).json({ error: 'EPP no encontrado' });
    res.json(epp);
  } catch (err) {
    console.error(`Error al buscar EPP con id ${id}:`, err);
    res.status(500).json({
      error: `No se pudo obtener el EPP con id: ${id}`,
      details: err instanceof Error ? err.message : String(err)
    });
  }
});

// POST crear EPP
router.post('/', async (req, res) => {
  const {
    tipo,
    obras_asignadas,
    cantidad,
    certificado_id
  } = req.body;

  if (!tipo || !cantidad) {
    return res.status(400).json({ error: 'Tipo y cantidad son requeridos' });
  }

  try {
    const nuevoEPP = await prisma.epp.create({
      data: {
        tipo,
        obras_asignadas: obras_asignadas || [],
        cantidad: parseInt(cantidad),
        certificado_id: certificado_id || null,
        fecha_registro: new Date(),
      },
    });
    res.status(201).json(nuevoEPP);
  } catch (error) {
    console.error('Error al crear EPP:', error);
    res.status(500).json({ error: 'No se pudo crear EPP', details: error.message });
  }
});

// PUT actualizar EPP
router.put('/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  const {
    tipo,
    obras_asignadas,     // ← snake_case (para backend directo)
    obrasAsignadas,      // ← camelCase (desde Flutter)
    cantidad,
    certificado_id
  } = req.body;

  if (isNaN(id)) {
    return res.status(400).json({ error: 'ID de EPP inválido' });
  }

  if (!tipo || !cantidad) {
    return res.status(400).json({ error: 'Tipo y cantidad son requeridos' });
  }

  try {
    const actualizado = await prisma.epp.update({
      where: { id },
      data: {
        tipo,
        // ⚡ USAR CUALQUIERA DE LOS DOS FORMATOS:
        obras_asignadas: obrasAsignadas || obras_asignadas || [],
        cantidad: parseInt(cantidad),
        certificado_id: certificado_id || null,
      },
    });
    res.json(actualizado);
  } catch (error) {
    console.error('Error al actualizar EPP:', error);
    res.status(500).json({ error: 'No se pudo actualizar el EPP', details: error.message });
  }
});

// DELETE eliminar EPP
router.delete('/:id', async (req, res) => {
  const id = parseInt(req.params.id);

  if (isNaN(id)) {
    return res.status(400).json({ error: 'ID de EPP inválido' });
  }

  try {
    await prisma.epp.delete({
      where: { id }
    });
    res.json({ message: 'EPP eliminado exitosamente' });
  } catch (error) {
    console.error('Error al eliminar EPP:', error);
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'EPP no encontrado' });
    }
    res.status(500).json({ error: 'No se pudo eliminar el EPP', details: error.message });
  }
});

module.exports = router;
