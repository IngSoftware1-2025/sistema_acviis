const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const createItemizadoGastoPDF = require('../formatos/ficha_itemizados');

// === GET: todos los itemizados ===
router.get('/', async (req, res) => {
  try {
    const itemizados = await prisma.itemizados.findMany({
      select: {
        id: true,
        nombre: true,
        monto_disponible: true
      }
    });
    res.json(itemizados);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener itemizados' });
  }
});

// === GET: itemizados por obra ===
router.get('/obra/:obraId', async (req, res) => {
  const { obraId } = req.params;
  try {
    const itemizados = await prisma.itemizados.findMany({
      where: { obraId },
      select: {
        id: true,
        nombre: true,
        cantidad: true,
        monto_total: true,
        monto_disponible: true,
      },
    });

    res.json(itemizados);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener itemizados de la obra' });
  }
});

// POST /itemizados
router.post('/', async (req, res) => {
  const { nombre, cantidad, monto_total, obraId } = req.body;

  if (!nombre || !cantidad || !monto_total || !obraId) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    const nuevoItemizado = await prisma.itemizados.create({
      data: {
        nombre,
        cantidad,
        monto_total,
        monto_disponible: monto_total,
        obraId,
      },
    });

    res.status(201).json(nuevoItemizado);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear itemizado' });
  }
});

// GET PDF por obra
router.get('/:obraId/pdf', async (req, res) => {
  const obraId = req.params.obraId;

  try {
    const obra = await prisma.obras.findUnique({
      where: { id: obraId },
      include: {
        itemizados: {
          include: {
            ordenes: true   
          }
        }
      }
    });

    if (!obra) return res.status(404).json({ error: 'Obra no encontrada' });
    if (!obra.itemizados.length) return res.status(404).json({ error: 'No hay itemizados para esta obra' });

    const items = obra.itemizados.map(it => ({
      nombre: it.nombre,
      cantidad: it.cantidad,
      valorTotal: it.monto_total,
      gastoActual: it.ordenes.reduce((acc, o) => acc + (o?.valor || 0), 0),
    }));

    const pdfBuffer = await createItemizadoGastoPDF({
      nombreObra: obra.nombre,
      items
    });

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=itemizado_${obra.nombre}.pdf`);
    res.send(pdfBuffer);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al generar PDF' });
  }
});

module.exports = router;