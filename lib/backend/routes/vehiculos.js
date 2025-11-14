const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { createFichaVehiculo } = require('../controllers/PDF/createFichaVehiculo');

router.get('/', async (req, res) => {
  try {
    const vehiculos = await prisma.vehiculos.findMany({
      orderBy: { id: 'desc' },
      select: {
        id: true,
        patente: true,
        permiso_id: true,
        revision_tecnica: true,
        revision_gases: true,
        ultima_mantencion: true,
        descripcion_mant: true,
        capacidad_kg: true,
        neumaticos: true,
        rueda_repuesto: true,
        observaciones: true,
        proxima_mantencion: true,
        estado: true,
        tipo: true,
      },
    });
    res.json(vehiculos);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener vehículos' });
  }
});


router.get('/:id', async (req, res) => {
  const id = req.params.id;
  const uuidV4Regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  if (!uuidV4Regex.test(id)) {
    return res.status(400).json({ error: 'ID de vehículo inválido (no es UUID v4)' });
  }
  try {
    const vehiculo = await prisma.vehiculos.findUnique({ 
      where: { id },
    });
    if (!vehiculo) return res.status(404).json({ error: 'Vehículo no encontrado' });
    res.json(vehiculo);
  } catch (err) {
    console.error(`Error al buscar vehículo con id ${id}:`, err);
    res.status(500).json({
      error: `No se pudo obtener el vehículo con id: ${id}`,
      details: err instanceof Error ? err.message : String(err)
    });
  }
});


router.post('/', async (req, res) => {
  const {
    patente,
    revision_tecnica,
    revision_gases,
    ultima_mantencion,
    descripcion_mant,
    capacidad_kg,
    neumaticos,
    rueda_repuesto,
    observaciones,
    proxima_mantencion,
    tipo,
  } = req.body;

  const requiredFields = [
    "patente",
    "revision_tecnica",
    "revision_gases",
    "ultima_mantencion",
    "capacidad_kg",
    "neumaticos",
    "rueda_repuesto",
    "proxima_mantencion",
    "tipo"
  ];

  for (const field of requiredFields) {
    if (req.body[field] === undefined || req.body[field] === null) {
        return res.status(400).json({ error: `El campo ${field} es obligatorio.` });
    }
  }

  try {
    const nuevo = await prisma.vehiculos.create({
      data: {
        patente,
        revision_tecnica: revision_tecnica ? new Date(revision_tecnica) : null,
        revision_gases: revision_gases ? new Date(revision_gases) : null,
        ultima_mantencion: ultima_mantencion ? new Date(ultima_mantencion) : null,
        descripcion_mant,
        capacidad_kg,
        neumaticos,
        rueda_repuesto,
        observaciones,
        estado: "Activo",
        proxima_mantencion: proxima_mantencion ? new Date(proxima_mantencion) : null,
        tipo,
      },
    });
    res.status(201).json(nuevo);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo crear registro de vehículo', details: error.message });
  }
});


router.put('/:id/datos', async (req, res) => {
  const { id } = req.params;
  const {
    patente,
    permiso_id,
    revision_tecnica,
    revision_gases,
    ultima_mantencion,
    descripcion_mant,
    capacidad_kg,
    neumaticos,
    rueda_repuesto,
    observaciones,
    proxima_mantencion,
    tipo
  } = req.body;

  const requiredFields = [
    "patente",
    "permiso_circ",
    "revision_tecnica",
    "revision_gases",
    "ultima_mantencion",
    "capacidad_kg",
    "neumaticos",
    "rueda_repuesto",
    "proxima_mantencion",
    "tipo",
  ];
  for (const field of requiredFields) {
    if (req.body[field] === undefined || req.body[field] === null) {
    return res.status(400).json({ error: `El campo "${field}" es obligatorio.` });
    }   
  }

  try {
    const actualizado = await prisma.vehiculos.update({
      where: { id },
      data: {
        patente,
        permiso_id,
        revision_tecnica: new Date(revision_tecnica),
        revision_gases: new Date(revision_gases),
        ultima_mantencion: new Date(ultima_mantencion),
        capacidad_kg,
        descripcion_mant,
        neumaticos,
        rueda_repuesto,
        observaciones,
        proxima_mantencion: new Date(proxima_mantencion),
        tipo,
      },
    });
    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar el vehículo', details: error.message });
  }
});


router.put('/:id/dar-de-baja', async (req, res) => {
    const { id } = req.params;

    try {
        const vehiculoActualizado = await prisma.vehiculos.update({
            where: { id },
            data: {
                estado: 'De baja',
            }
        });

        res.status(200).json({
            mensaje: 'Vehículo dada de baja correctamente',
            vehiculo: vehiculoActualizado
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al dar de baja el vehículo' });
    }
});

router.get('/:id/ficha-pdf', async (req, res) => {
  const { id } = req.params;
  try {
    const vehiculo = await prisma.vehiculos.findUnique({ where: { id } });
    console.log('vehiculo raw (tipo, valor):',
      {
        revision_tecnica: vehiculo.revision_tecnica,
        revision_tecnica_type: typeof vehiculo.revision_tecnica,
        ultima_mantencion: vehiculo.ultima_mantencion,
        ultima_mantencion_type: typeof vehiculo.ultima_mantencion,
        proxima_mantencion: vehiculo.proxima_mantencion,
        proxima_mantencion_type: typeof vehiculo.proxima_mantencion
      }
    );
    if (!vehiculo) return res.status(404).send('Vehículo no encontrado');

    const pdfData = await createFichaVehiculo(vehiculo);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename=ficha_vehiculo_${vehiculo.patente || vehiculo.id}.pdf`
    );
    res.send(pdfData);
  } catch (error) {
    console.error('Error generando PDF para vehículo', id, error);
    res.status(500).send('Error al generar PDF');
  }
});

module.exports = router;