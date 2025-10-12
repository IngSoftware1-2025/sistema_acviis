const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Asigna un recurso a una obra
 */
router.post('/', async (req, res) => {
  const { 
    obraId,
    recursoTipo,
    vehiculoId,
    herramientaId,
    eppId,
    cantidad,
    observaciones
  } = req.body;

  try {
    console.log("Recibida solicitud para asignar recurso:", {
      obraId, recursoTipo, vehiculoId, herramientaId, eppId, cantidad
    });
    
    // Validación de datos
    if (!obraId || !recursoTipo) {
      return res.status(400).json({ error: 'Obra ID y tipo de recurso son obligatorios' });
    }

    // Validar que la obra existe
    const obraExiste = await prisma.obras.findUnique({
      where: { id: obraId }
    });

    if (!obraExiste) {
      return res.status(404).json({ error: 'La obra especificada no existe' });
    }

    // Validar que el tipo de recurso es válido
    if (!['vehiculo', 'herramienta', 'epp'].includes(recursoTipo)) {
      return res.status(400).json({ 
        error: 'Tipo de recurso inválido. Debe ser: vehiculo, herramienta o epp' 
      });
    }

    // Validar que se proporciona el ID correcto según el tipo
    let idValido = false;
    switch(recursoTipo) {
      case 'vehiculo':
        if (vehiculoId) {
          const vehiculo = await prisma.vehiculos.findUnique({
            where: { id: vehiculoId }
          });
          idValido = !!vehiculo;
        }
        break;
      case 'herramienta':
        if (herramientaId) {
          const herramienta = await prisma.herramientas.findUnique({
            where: { id: herramientaId }
          });
          idValido = !!herramienta;
        }
        break;
      case 'epp':
        if (eppId) {
          const epp = await prisma.epp.findUnique({
            where: { id: eppId }
          });
          idValido = !!epp;
        }
        break;
    }

    if (!idValido) {
      return res.status(400).json({ 
        error: `ID de ${recursoTipo} no proporcionado o no existe` 
      });
    }

    // SOLUCIÓN CLAVE: Buscar cualquier asignación existente, independientemente del estado
    // Esto es debido a la restricción única en la base de datos
    const asignacionExistente = await prisma.obra_recurso.findFirst({
      where: {
        obra_id: obraId,
        recurso_tipo: recursoTipo,
        ...(recursoTipo === 'vehiculo' && { vehiculo_id: vehiculoId }),
        ...(recursoTipo === 'herramienta' && { herramienta_id: herramientaId }),
        ...(recursoTipo === 'epp' && { epp_id: parseInt(eppId) }),
      }
    });

    console.log("Resultado búsqueda de asignación existente:", asignacionExistente ? 
      `Encontrada: ID=${asignacionExistente.id}, estado=${asignacionExistente.estado}` : 
      "No encontrada");

    // Si existe una asignación activa, no permitir reasignación
    if (asignacionExistente && asignacionExistente.estado === 'activo') {
      return res.status(409).json({ 
        error: `Este ${recursoTipo} ya está asignado activamente a la obra` 
      });
    }
    
    // SOLUCIÓN PRINCIPAL: Si ya existe una asignación (probablemente retirada)
    // actualizar ese registro en lugar de crear uno nuevo
    if (asignacionExistente) {
      console.log(`REASIGNACIÓN: Actualizando asignación existente ID=${asignacionExistente.id}`);
      
      try {
        // Datos para actualizar
        const datosActualizacion = {
          estado: 'activo',
          fecha_retiro: null,
          fecha_asignacion: new Date(),
          cantidad: cantidad || asignacionExistente.cantidad,
          observaciones: observaciones || asignacionExistente.observaciones
        };
        
        console.log("Actualizando con datos:", datosActualizacion);
        
        // Actualizar la asignación a estado activo
        const asignacionActualizada = await prisma.obra_recurso.update({
          where: { 
            id: asignacionExistente.id 
          },
          data: datosActualizacion
        });
        
        console.log("Asignación actualizada correctamente:", {
          id: asignacionActualizada.id,
          estado: asignacionActualizada.estado
        });
        
        return res.status(200).json({
          message: `${recursoTipo} reasignado correctamente a la obra`,
          data: asignacionActualizada
        });
      } catch (updateError) {
        console.error("Error al actualizar asignación:", updateError);
        return res.status(500).json({ 
          error: `Error al reasignar ${recursoTipo}: ${updateError.message}` 
        });
      }
    }

    // Si no existe ninguna asignación previa, crear una nueva
    console.log("Creando nueva asignación de recurso");
    try {
      const asignacion = await prisma.obra_recurso.create({
        data: {
          obra_id: obraId,
          recurso_tipo: recursoTipo,
          ...(recursoTipo === 'vehiculo' && { vehiculo_id: vehiculoId }),
          ...(recursoTipo === 'herramienta' && { herramienta_id: herramientaId }),
          ...(recursoTipo === 'epp' && { epp_id: parseInt(eppId) }),
          cantidad: cantidad || 1,
          observaciones
        }
      });
      
      console.log("Nueva asignación creada:", {
        id: asignacion.id,
        tipo: asignacion.recurso_tipo,
        estado: asignacion.estado
      });

      return res.status(201).json({
        message: `${recursoTipo} asignado correctamente a la obra`,
        data: asignacion
      });
    } catch (createError) {
      console.error("Error al crear nueva asignación:", createError);
      return res.status(500).json({ 
        error: `Error al asignar ${recursoTipo}: ${createError.message}` 
      });
    }
  } catch (error) {
    console.error('Error general al asignar recurso:', error);
    return res.status(500).json({ error: 'Error interno al asignar recurso' });
  }
});

/**
 * Retira un recurso de una obra (establece fecha de retiro y cambia estado)
 */
router.put('/:id/retirar', async (req, res) => {
  const { id } = req.params;
  const { observaciones } = req.body;

  try {
    // Verificar si existe la asignación
    const asignacion = await prisma.obra_recurso.findUnique({
      where: { id }
    });

    if (!asignacion) {
      return res.status(404).json({ error: 'Asignación no encontrada' });
    }

    if (asignacion.estado !== 'activo') {
      return res.status(400).json({ error: 'El recurso ya ha sido retirado de la obra' });
    }

    // Actualizar la asignación
    const asignacionActualizada = await prisma.obra_recurso.update({
      where: { id },
      data: {
        fecha_retiro: new Date(),
        estado: 'retirado',
        observaciones: observaciones || asignacion.observaciones
      }
    });

    return res.json({
      message: 'Recurso retirado correctamente',
      data: asignacionActualizada
    });
  } catch (error) {
    console.error('Error al retirar recurso:', error);
    return res.status(500).json({ error: 'Error interno al retirar recurso' });
  }
});

/**
 * Obtiene todos los recursos asignados a una obra específica
 */
router.get('/obra/:obraId', async (req, res) => {
  const { obraId } = req.params;
  const { tipo } = req.query; // Opcional: filtrar por tipo de recurso

  try {
    // Validar que la obra existe
    const obraExiste = await prisma.obras.findUnique({
      where: { id: obraId }
    });

    if (!obraExiste) {
      return res.status(404).json({ error: 'La obra especificada no existe' });
    }

    // Construir la consulta
    const whereClause = {
      obra_id: obraId,
      ...(tipo && { recurso_tipo: tipo })
    };

    // Obtener los recursos asignados
    const recursos = await prisma.obra_recurso.findMany({
      where: whereClause,
      include: {
        vehiculo: { select: { 
          patente: true, 
          tipo: true, 
          capacidad_kg: true, 
          estado: true 
        }},
        herramienta: { select: { 
          tipo: true, 
          estado: true, 
          cantidad: true 
        }},
        epp: { select: { 
          tipo: true, 
          cantidad: true 
        }}
      },
      orderBy: {
        fecha_asignacion: 'desc'
      }
    });

    // Formatear la respuesta para que sea más amigable
    const recursosFormateados = recursos.map(recurso => {
      let detallesRecurso;
      
      switch(recurso.recurso_tipo) {
        case 'vehiculo':
          detallesRecurso = recurso.vehiculo;
          break;
        case 'herramienta':
          detallesRecurso = recurso.herramienta;
          break;
        case 'epp':
          detallesRecurso = recurso.epp;
          break;
      }
      
      return {
        id: recurso.id,
        tipo: recurso.recurso_tipo,
        fechaAsignacion: recurso.fecha_asignacion,
        fechaRetiro: recurso.fecha_retiro,
        cantidad: recurso.cantidad,
        observaciones: recurso.observaciones,
        estado: recurso.estado,
        detalles: detallesRecurso
      };
    });

    return res.json({
      obraNombre: obraExiste.nombre,
      recursos: recursosFormateados
    });
  } catch (error) {
    console.error('Error al obtener recursos de la obra:', error);
    return res.status(500).json({ error: 'Error interno al obtener recursos' });
  }
});

/**
 * Obtiene recursos disponibles (no asignados) para asignar a obras
 */
router.get('/disponibles/:tipo', async (req, res) => {
  const { tipo } = req.params;

  try {
    if (!['vehiculo', 'herramienta', 'epp'].includes(tipo)) {
      return res.status(400).json({ 
        error: 'Tipo de recurso inválido. Debe ser: vehiculo, herramienta o epp' 
      });
    }

    let recursosDisponibles;

    switch(tipo) {
      case 'vehiculo':
        // Obtener vehículos que no estén asignados activamente a ninguna obra
        recursosDisponibles = await prisma.vehiculos.findMany({
          where: {
            estado: 'activo', // Solo vehículos activos
            // Filtrar los vehículos que no están asignados activamente a ninguna obra
            // SOLUCIÓN: Considerar disponibles los que solo tienen asignaciones retiradas
            NOT: {
              obra_recursos: {
                some: {
                  estado: 'activo' // No incluir los que tienen asignaciones activas
                }
              }
            }
          },
          select: {
            id: true,
            patente: true,
            tipo: true,
            capacidad_kg: true,
            estado: true
          }
        });
        break;

      case 'herramienta':
        recursosDisponibles = await prisma.herramientas.findMany({
          where: {
            estado: 'activo', // Solo herramientas activas
            // Filtrar las que no están asignadas activamente a ninguna obra
            // SOLUCIÓN: Considerar disponibles también las que solo tienen asignaciones retiradas
            NOT: {
              obra_recursos: {
                some: {
                  estado: 'activo' // No incluir las que tienen asignaciones activas
                }
              }
            }
          },
          select: {
            id: true,
            tipo: true,
            estado: true,
            cantidad: true
          }
        });
        break;

      case 'epp':
        // Para EPP, filtrar los que están disponibles (no asignados activamente)
        recursosDisponibles = await prisma.epp.findMany({
          where: {
            // Filtrar los EPP que no están asignados activamente a ninguna obra
            // SOLUCIÓN: Considerar disponibles los EPP que solo tienen asignaciones retiradas
            NOT: {
              obra_recursos: {
                some: {
                  estado: 'activo' // No incluir los que tienen asignaciones activas
                }
              }
            }
          },
          select: {
            id: true,
            tipo: true,
            cantidad: true
          }
        });
        break;
    }

    return res.json({
      tipo,
      recursos: recursosDisponibles
    });
  } catch (error) {
    console.error(`Error al obtener ${tipo}s disponibles:`, error);
    return res.status(500).json({ error: `Error interno al obtener ${tipo}s disponibles` });
  }
});

module.exports = router;