const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.get('/', async (req, res) => {
  try {
    const herramientas = await prisma.herramientas.findMany({
      orderBy: { id: 'desc' },
      select: {
        id: true,
        tipo: true,
        estado: true,
        garantia: true,
        cantidad: true,
        obra_asig: true,
        asig_inicio: true,
        asig_fin: true,
      },
    });
    res.json(herramientas);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener herramientas' });
  }
});

router.get('/:id', async (req, res) => {
  const id = req.params.id;
  const uuidV4Regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  if (!uuidV4Regex.test(id)) {
    return res.status(400).json({ error: 'ID de herramienta inválido (no es UUID v4)' });
  }
  try {
    const herramienta = await prisma.herramientas.findUnique({ 
      where: { id },
    });
    if (!herramienta) return res.status(404).json({ error: 'Herramienta no encontrado' });
    res.json(herramienta);
  } catch (err) {
    console.error(`Error al buscar herramienta con id ${id}:`, err);
    res.status(500).json({
      error: `No se pudo obtener la herramienta con id: ${id}`,
      details: err instanceof Error ? err.message : String(err)
    });
  }
});


router.post('/', async (req, res) => {
  const {
    id,
    tipo,
    estado,
    garantia,
    cantidad,
    obra_asig,
    asig_inicio,
    asig_fin,
  } = req.body;

  if (!tipo || !estado || !cantidad) {
    return res.status(400).json({ error: 'Es necesario rellenar los campos requeridos.' });
  }

  try {
    const nuevo = await prisma.herramientas.create({
      data: {
        id,
        tipo,
        estado,
        garantia: garantia ? new Date(garantia) : null,
        cantidad,
        obra_asig,
        asig_inicio: asig_inicio ? new Date(asig_inicio) : null,
        asig_fin: asig_fin ? new Date(asig_fin) : null,
      },
    });
    res.status(201).json(nuevo);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo crear registro de herramienta', details: error.message });
  }
});

router.put('/:id/datos', async (req, res) => {
  const { id } = req.params;
  const {
    tipo,
    estado,
    garantia,
    cantidad,
    obra_asig,
    asig_inicio,
    asig_fin,
  } = req.body;
  if (
    !tipo || !estado ||
    !garantia || !cantidad || !obra_asig ||
    !asig_inicio || !asig_fin
  ) {
    return res.status(400).json({ error: 'Todos los campos son obligatorios' });
  }

  try {
    const actualizado = await prisma.herramientas.update({
      where: { id },
      data: {
        tipo,
        estado,
        garantia,
        cantidad,
        obra_asig,
        asig_inicio,
        asig_fin,
      },
    });
    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar la herramienta', details: error.message });
  }
});


// 'Eliminar' una herramienta.
router.put('/:id/dar-de-baja', async (req, res) => {
    const { id } = req.params;

    try {
        const herramientaActualizada = await prisma.herramientas.update({
            where: { id },
            data: {
                estado: 'de baja',
                cantidad: 0,
            }
        });

        res.status(200).json({
            mensaje: 'Herramienta dada de baja correctamente',
            herramienta: herramientaActualizada
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al dar de baja la herramienta' });
    }
});


module.exports = router;