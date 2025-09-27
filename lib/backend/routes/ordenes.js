const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();


// GET todas las órdenes de compra 
router.get('/', async (req, res) => {
  try {
    const ordenes = await prisma.ordenes_de_compra.findMany({
      orderBy: { id: 'desc' },
      select: {
        id: true,
        numero_orden: true,
        fecha_emision: true,
        centro_costo: true,
        seccion_itemizado: true,
        numero_cotizacion: true,
        numero_contacto: true,
        nombre_servicio: true,
        valor: true,
        descuento: true,
        notas_adicionales: true,
        estado: true,
        createdAt: true,
        updatedAt: true,
        proveedor: {
          select: {
            id: true,
            rut: true,
            nombre_vendedor: true,
            direccion: true,
            telefono_vendedor: true,
            correo_vendedor: true,
            estado: true,
            fecha_registro: true,
          }
        }
      },
    });
    res.json(ordenes);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener órdenes de compra' });
  }
});

// GET orden de compra por ID (UUID) 
router.get('/:id', async (req, res) => {
  const id = req.params.id;
  const uuidV4Regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  if (!uuidV4Regex.test(id)) {
    return res.status(400).json({ error: 'ID de orden inválido (no es UUID v4)' });
  }
  try {
    const orden = await prisma.ordenes_de_compra.findUnique({
      where: { id },
    });
    if (!orden) return res.status(404).json({ error: 'Orden de compra no encontrada' });
    res.json(orden);
  } catch (err) {
    console.error(`Error al buscar orden con id ${id}:`, err);
    res.status(500).json({
      error: `No se pudo obtener la orden de compra con id: ${id}`,
      details: err instanceof Error ? err.message : String(err)
    });
  }
});

// POST crear orden de compra
router.post('/', async (req, res) => {
    const {
      proveedorId,
      numero_orden,
      fecha_emision,
      centro_costo,
      seccion_itemizado,
      numero_cotizacion,
      numero_contacto,
      nombre_servicio,
      valor,
      descuento,
      notas_adicionales,
      estado,
    } = req.body;

    if (!proveedorId || !numero_orden || !fecha_emision) {
      return res.status(400).json({ error: "Faltan campos requeridos" });
    }


    try{
        const nuevo = await prisma.ordenes_de_compra.create({
          data: {
            proveedorId,
            numero_orden,
            fecha_emision: new Date(fecha_emision),
            centro_costo,
            seccion_itemizado,
            numero_cotizacion,
            numero_contacto,
            nombre_servicio,
            valor,
            descuento,
            notas_adicionales,
            estado,
          }
        });
    res.status(201).json(nuevo);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear la orden de compra' });
  }
});

// PUT dar de baja varias órdenes de compra
router.put('/:id/dar-de-baja', async (req, res) => {
    const { id } = req.params;

    try {
        const ordenActualizada = await prisma.ordenes_de_compra.update({
            where: { id },
            data: {
                estado: 'De baja',
            }
        });

        res.status(200).json({
            mensaje: 'Orden dada de baja correctamente',
            orden: ordenActualizada
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al dar de baja la orden' });
    }
});



module.exports = router;
