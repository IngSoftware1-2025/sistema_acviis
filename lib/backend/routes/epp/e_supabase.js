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
      cantidadTotal: epp.cantidad_total,
      cantidad_total: epp.cantidad_total,
      cantidadDisponible: epp.cantidad_disponible,
      cantidad_disponible: epp.cantidad_disponible,
      certificadoId: epp.certificado_id,
      certificado_id: epp.certificado_id,
      fechaRegistro: epp.fecha_registro,
      fecha_registro: epp.fecha_registro
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
    
    // Formatear respuesta
    const eppFormateado = {
      id: epp.id,
      tipo: epp.tipo,
      cantidadTotal: epp.cantidad_total,
      cantidad_total: epp.cantidad_total,
      cantidadDisponible: epp.cantidad_disponible,
      cantidad_disponible: epp.cantidad_disponible,
      certificadoId: epp.certificado_id,
      certificado_id: epp.certificado_id,
      fechaRegistro: epp.fecha_registro,
      fecha_registro: epp.fecha_registro
    };
    
    res.json(eppFormateado);
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
    cantidadTotal,
    cantidad_total,
    cantidadDisponible,
    cantidad_disponible,
    certificadoId,
    certificado_id
  } = req.body;

  const cantTotal = cantidadTotal || cantidad_total;
  const cantDisponible = cantidadDisponible || cantidad_disponible || cantTotal;

  if (!tipo || !cantTotal) {
    return res.status(400).json({ error: 'Tipo y cantidad total son requeridos' });
  }

  try {
    const nuevoEPP = await prisma.epp.create({
      data: {
        tipo,
        cantidad_total: parseInt(cantTotal),
        cantidad_disponible: cantDisponible ? parseInt(cantDisponible) : parseInt(cantTotal),
        certificado_id: certificadoId || certificado_id || null,
        fecha_registro: new Date(),
      },
    });
    
    // Formatear respuesta
    const eppFormateado = {
      id: nuevoEPP.id,
      tipo: nuevoEPP.tipo,
      cantidadTotal: nuevoEPP.cantidad_total,
      cantidad_total: nuevoEPP.cantidad_total,
      cantidadDisponible: nuevoEPP.cantidad_disponible,
      cantidad_disponible: nuevoEPP.cantidad_disponible,
      certificadoId: nuevoEPP.certificado_id,
      certificado_id: nuevoEPP.certificado_id,
      fechaRegistro: nuevoEPP.fecha_registro,
      fecha_registro: nuevoEPP.fecha_registro
    };
    
    res.status(201).json(eppFormateado);
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
    cantidadTotal,
    cantidad_total,
    cantidadDisponible,
    cantidad_disponible,
    certificadoId,
    certificado_id
  } = req.body;

  if (isNaN(id)) {
    return res.status(400).json({ error: 'ID de EPP inválido' });
  }

  const cantTotal = cantidadTotal || cantidad_total;

  if (!tipo || !cantTotal) {
    return res.status(400).json({ error: 'Tipo y cantidad total son requeridos' });
  }

  try {
    const actualizado = await prisma.epp.update({
      where: { id },
      data: {
        tipo,
        cantidad_total: parseInt(cantTotal),
        cantidad_disponible: cantidadDisponible || cantidad_disponible ? parseInt(cantidadDisponible || cantidad_disponible) : undefined,
        certificado_id: certificadoId || certificado_id || null,
      },
    });
    
    // Formatear respuesta
    const eppFormateado = {
      id: actualizado.id,
      tipo: actualizado.tipo,
      cantidadTotal: actualizado.cantidad_total,
      cantidad_total: actualizado.cantidad_total,
      cantidadDisponible: actualizado.cantidad_disponible,
      cantidad_disponible: actualizado.cantidad_disponible,
      certificadoId: actualizado.certificado_id,
      certificado_id: actualizado.certificado_id,
      fechaRegistro: actualizado.fecha_registro,
      fecha_registro: actualizado.fecha_registro
    };
    
    res.json(eppFormateado);
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
