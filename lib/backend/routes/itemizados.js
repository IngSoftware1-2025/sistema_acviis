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
        gasto_actual: true,  
        exceso_notificado: true,  
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
  const { obraId } = req.params;

  try {
    // 1) Traer obra con itemizados + facturas asociadas
    const obra = await prisma.obras.findUnique({
      where: { id: obraId },
      include: {
        itemizados: {
          include: {
            facturas: {  
              where: { estado_pago: 'pagada' }  
            }
          }
        }
      }
    });

    if (!obra) return res.status(404).json({ error: 'Obra no encontrada' });
    if (!obra.itemizados.length) return res.status(404).json({ error: 'No hay itemizados para esta obra' });

    // 2) Calcular el gasto actual para cada itemizado
    const items = obra.itemizados.map(it => {
      const gasto = it.facturas.reduce((acc, p) => acc + (p.valor || 0), 0);  
      const saldo = it.monto_total - gasto;

      return {
        nombre: it.nombre,
        cantidad: it.cantidad,
        valorTotal: it.monto_total,
        gastoActual: gasto,  
        saldo: saldo,
        excesoNotificado: it.exceso_notificado, 
      };
    });

    // 3) Generar el PDF con los datos actualizados
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



// === POST batch itemizados por obra ===
router.post('/obra/:obraId', async (req, res) => {
  const { obraId } = req.params;
  const { items } = req.body;

  if (!items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: "Debe enviar un arreglo de ítems" });
  }

  // Validaciones por cada item antes de tocar BD
  for (const it of items) {
    if (!it.nombre || typeof it.nombre !== 'string' || it.nombre.trim() === '') {
      return res.status(400).json({ error: "Cada ítem debe tener un nombre válido" });
    }
    if (!it.cantidad || isNaN(it.cantidad) || Number(it.cantidad) <= 0) {
      return res.status(400).json({ error: `Cantidad inválida para ítem "${it.nombre}"` });
    }
    if (!it.monto_total || isNaN(it.monto_total) || Number(it.monto_total) <= 0) {
      return res.status(400).json({ error: `Monto total inválido para ítem "${it.nombre}"` });
    }
  }

  try {
    // validar que la obra exista
    const obra = await prisma.obras.findUnique({ where: { id: obraId } });
    if (!obra) return res.status(404).json({ error: "Obra no encontrada" });

    // construir la transacción
    const tx = items.map(it => prisma.itemizados.create({
      data: {
        obraId,
        nombre: it.nombre.trim(),
        cantidad: Number(it.cantidad),
        monto_total: Number(it.monto_total),
        monto_disponible: Number(it.monto_total),
      }
    }));

    const created = await prisma.$transaction(tx);

    res.status(201).json({
      ok: true,
      message: "Itemizado registrado correctamente",
      count: created.length,
      data: created
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al crear los itemizados" });
  }
});

module.exports = router;