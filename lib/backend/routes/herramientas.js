
const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { createFichaHerramienta } = require('../controllers/PDF/createFichaHerramienta');

router.get('/', async (req, res) => {
  try {
    const herramientas = await prisma.herramientas.findMany({
      orderBy: [
        { estado: 'asc' },  
        { id: 'desc' } 
      ],
      select: {
        id: true,
        tipo: true,
        estado: true,
        garantia: true,
        cantidad_total: true,
        cantidad_disponible: true,
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
    if (!herramienta) return res.status(404).json({ error: 'Herramienta no encontrada' });
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
    tipo,
    garantia,
    cantidad_total,
  } = req.body;

  if (!tipo || !cantidad_total) {
    return res.status(400).json({ error: 'Es necesario rellenar los campos requeridos.' });
  }

  try {
    const nuevo = await prisma.herramientas.create({
      data: {
        tipo,
        estado: "activo",
        garantia: garantia ? new Date(garantia) : null,
        cantidad_total,
        cantidad_disponible: cantidad_total,
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
    garantia,
    cantidad,
  } = req.body;

  const requiredFields = ["tipo", "garantia", "cantidad"];
  for (const field of requiredFields) {
    if (req.body[field] === undefined || req.body[field] === null) {
      return res.status(400).json({ error: `El campo "${field}" es obligatorio.` });
    }
  }

  try {
    const actualizado = await prisma.herramientas.update({
      where: { id },
      data: {
        tipo,
        garantia,
        cantidad,
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
                estado: 'De baja',
                cantidad_total: 0,
                cantidad_disponible: 0,
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

// generar pdf ficha herramienta
router.get('/:id/ficha-pdf', async (req, res) => {
  const { id } = req.params;
  try {
    const herramienta = await prisma.herramientas.findUnique({ where: { id } });
    console.log('Objeto herramienta:', herramienta);

    if (!herramienta) {
      console.log('Herramienta no encontrada');
      return res.status(404).send('Herramienta no encontrada');
    }

    const pdfData = await createFichaHerramienta(herramienta);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename=ficha_herramienta_${herramienta.tipo || herramienta.id}.pdf`
    );

    console.log('PDF generado correctamente');
    res.send(pdfData);
  } catch (error) {
    console.error('Error generando PDF para herramienta', id, error); 
    res.status(500).send('Error al generar PDF');
  }
});

module.exports = router;