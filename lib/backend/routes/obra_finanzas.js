const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// GET /obra_finanzas/obra/:obraId - Obtener finanzas de una obra
router.get('/obra/:obraId', async (req, res) => {
  try {
    const { obraId } = req.params;
    const { tipo } = req.query;

    // CAMBIO: Ahora usamos obra_id en lugar de obraId
    const whereClause = { obra_id: obraId };
    if (tipo) {
      whereClause.tipo = tipo;
    }

    const finanzas = await prisma.obra_finanza.findMany({
      where: whereClause,
      orderBy: { fecha_asignacion: 'desc' },
      // NUEVO: Puedes incluir datos de la obra relacionada
      include: {
        obra: {
          select: {
            nombre: true,
            direccion: true,
          }
        }
      }
    });

    res.json({ finanzas });
  } catch (error) {
    console.error('[GET /obra/:obraId] Error:', error);
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});

// POST /obra_finanzas - Crear nueva caja chica
router.post('/', async (req, res) => {
  try {
    const {
      obraId,
      tipo,
      proposito,
      estado = 'activa',
      detalles,
    } = req.body;

    // Validaciones
    if (!obraId || !tipo || !proposito) {
      return res.status(400).json({
        error: 'Faltan campos obligatorios: obraId, tipo, proposito',
      });
    }

    // NUEVO: Validar que la obra exista (gracias a la FK)
    const obraExiste = await prisma.obras.findUnique({
      where: { id: obraId }
    });

    if (!obraExiste) {
      return res.status(404).json({
        error: 'La obra especificada no existe',
      });
    }

    // Validar que detalles contenga los montos
    if (tipo === 'caja chica' && (!detalles || detalles.montoTotalAsignado == null)) {
      return res.status(400).json({
        error: 'Para caja chica se requiere detalles.montoTotalAsignado',
      });
    }

    // CAMBIO: Usar obra_id en lugar de obraId
    const nuevaFinanza = await prisma.obra_finanza.create({
      data: {
        obra_id: obraId,
        tipo,
        proposito,
        estado,
        fecha_asignacion: new Date(),
        detalles: detalles || {},
      },
      // NUEVO: Incluir datos de la obra en la respuesta
      include: {
        obra: {
          select: {
            nombre: true,
            direccion: true,
          }
        }
      }
    });

    res.status(201).json({ data: nuevaFinanza });
  } catch (error) {
    console.error('[POST /] Error:', error);
    
    // NUEVO: Manejo específico de errores de FK
    if (error.code === 'P2003') {
      return res.status(400).json({
        error: 'La obra especificada no existe o ha sido eliminada',
      });
    }
    
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});

// PUT /obra_finanzas/:id/cerrar - Cerrar caja chica
router.put('/:id/cerrar', async (req, res) => {
  try {
    const { id } = req.params;
    const { observaciones, fechaCierre } = req.body;

    // Obtener la finanza actual para preservar detalles existentes
    const finanzaActual = await prisma.obra_finanza.findUnique({
      where: { id },
      // NUEVO: Incluir datos de la obra
      include: {
        obra: {
          select: {
            nombre: true,
          }
        }
      }
    });

    if (!finanzaActual) {
      return res.status(404).json({ error: 'Finanza no encontrada' });
    }

    // Actualizar detalles con la información de cierre
    const detallesActualizados = {
      ...(finanzaActual.detalles || {}),
      observaciones,
      fechaCierre: fechaCierre || new Date().toISOString(),
    };

    const finanzaActualizada = await prisma.obra_finanza.update({
      where: { id },
      data: {
        estado: 'cerrada',
        detalles: detallesActualizados,
      },
      // NUEVO: Incluir datos de la obra en la respuesta
      include: {
        obra: {
          select: {
            nombre: true,
            direccion: true,
          }
        }
      }
    });

    res.json({ data: finanzaActualizada });
  } catch (error) {
    console.error('[PUT /:id/cerrar] Error:', error);
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});

// NUEVO: GET /obra_finanzas/:id - Obtener una finanza específica
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const finanza = await prisma.obra_finanza.findUnique({
      where: { id },
      include: {
        obra: {
          select: {
            id: true,
            nombre: true,
            direccion: true,
            responsable_email: true,
          }
        }
      }
    });

    if (!finanza) {
      return res.status(404).json({ error: 'Finanza no encontrada' });
    }

    res.json({ data: finanza });
  } catch (error) {
    console.error('[GET /:id] Error:', error);
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});


// PUT /obra_finanzas/:id - Modificar caja chica
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { detalles } = req.body;

    if (!detalles) {
      return res.status(400).json({
        error: 'Se requiere el campo detalles para actualizar',
      });
    }

    // Obtener la finanza actual
    const finanzaActual = await prisma.obra_finanza.findUnique({
      where: { id },
    });

    if (!finanzaActual) {
      return res.status(404).json({ error: 'Finanza no encontrada' });
    }

    // Validar que la suma cuadre
    const { montoTotalUtilizado, montoUtilizadoImpago, montoUtilizadoResuelto } = detalles;
    if (montoTotalUtilizado && montoUtilizadoImpago != null && montoUtilizadoResuelto != null) {
      if (montoUtilizadoImpago + montoUtilizadoResuelto !== montoTotalUtilizado) {
        return res.status(400).json({
          error: 'La suma de montoUtilizadoImpago + montoUtilizadoResuelto debe ser igual a montoTotalUtilizado',
        });
      }
    }

    // Actualizar solo los detalles
    const finanzaActualizada = await prisma.obra_finanza.update({
      where: { id },
      data: {
        detalles: {
          ...(finanzaActual.detalles || {}),
          ...detalles,
        },
      },
      include: {
        obra: {
          select: {
            nombre: true,
            direccion: true,
          }
        }
      }
    });

    res.json({ data: finanzaActualizada });
  } catch (error) {
    console.error('[PUT /:id] Error:', error);
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});

module.exports = router;