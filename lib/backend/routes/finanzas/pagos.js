const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const createFichaPagos = require('../../formatos/ficha_pagos');

const prisma = new PrismaClient();

// GET /pagos
router.get('/', async (req, res) => {
  try {
    const pagos = await prisma.pagos.findMany();
    res.json(pagos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});

// POST /pagos
router.post('/', async (req, res) => {
  try {
    const data = req.body;
    if ('id' in data) delete data.id;
    if (typeof data.plazo_pagar === 'string') {
      data.plazo_pagar = new Date(data.plazo_pagar);
    }
    const nuevoPago = await prisma.pagos.create({ data });
    res.status(201).json(nuevoPago);
  } catch (error) {
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});

//Creacion del PDF
router.get('/:id/pdf', async (req, res) => {
  try {
    const pago = await prisma.pagos.findUnique({
      where: { id: req.params.id },
    });
    if (!pago) {
      return res.status(404).json({ error: 'Pago no encontrado' });
    }
    const pdfBuffer = await createFichaPagos(pago);

    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename=pago_${pago.id}.pdf`,
      'Content-Length': pdfBuffer.length,
    });
    res.send(pdfBuffer);
  } catch (error) {
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});

// PUT /pagos/:id/tipo_pago
router.put('/:id/visualizacion', async (req, res) => {
  try {
    const { id } = req.params;
    const { visualizacion } = req.body;
    const pagoActualizado = await prisma.pagos.update({
      where: { id },
      data: { visualizacion },
    });
    res.json(pagoActualizado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  } finally {
    await prisma.$disconnect();
  }
});

router.put('/:id/datos', async (req, res) => {
  const { id } = req.params;
  const {
    nombre_mandante,
    rut_mandante,
    direccion_comercial,
    codigo,
    servicio_ofrecido,
    valor,
    plazo_pagar,
    estado_pago,
    fotografia_id,
    tipo_pago,
    sentido,
    visualizacion,
  } = req.body;

  // Validación básica (puedes ajustar según tus necesidades)
  if (
    !nombre_mandante || !rut_mandante ||
    !direccion_comercial || !codigo || !servicio_ofrecido ||
    valor === undefined || !plazo_pagar || !estado_pago ||
    !fotografia_id || !tipo_pago || sentido === undefined || !visualizacion
  ) {
    return res.status(400).json({ error: 'Todos los campos son obligatorios' });
  }

  try {
    const actualizado = await prisma.pagos.update({
      where: { id },
      data: {
        nombre_mandante,
        rut_mandante,
        direccion_comercial,
        codigo,
        servicio_ofrecido,
        valor: Number(valor),
        plazo_pagar: new Date(plazo_pagar),
        estado_pago,
        fotografia_id,
        tipo_pago,
        sentido,
        visualizacion,
      },
    });
    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar el pago', details: error.message });
  }
});

module.exports = router;