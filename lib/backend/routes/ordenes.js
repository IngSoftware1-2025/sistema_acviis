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
        numero_cotizacion: true,
        numero_contacto: true,
        nombre_servicio: true,
        valor: true,
        descuento: true,
        notas_adicionales: true,
        estado: true,
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
        },
        itemizado: {  
          select: {
            id: true,
            nombre: true,
            monto_disponible: true,
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
      itemizadoId,
      numero_cotizacion,
      numero_contacto,
      nombre_servicio,
      valor,
      descuento,
      notas_adicionales,
      estado,
    } = req.body;

    try {
      const itemizado = await prisma.itemizados.findUnique({
        where: { id: itemizadoId },
      });
      if (!itemizado) {
        return res.status(404).json({ error: 'Itemizado no encontrado' });
      }
      if (itemizado.monto_disponible < valor) {
        return res.status(400).json({ error: 'Monto disponible insuficiente en el itemizado' });
      }

      const [nuevo, _] = await prisma.$transaction([
        prisma.ordenes_de_compra.create({
          data: {
            proveedorId,
            numero_orden,
            fecha_emision: new Date(fecha_emision),
            centro_costo,
            itemizadoId,
            numero_cotizacion,
            numero_contacto,
            nombre_servicio,
            valor,
            descuento,
            notas_adicionales,
            estado,
          }
        }),
        prisma.itemizados.update({
          where: { id: itemizadoId },
          data: {
            monto_disponible: { decrement: valor }
          }
        })
      ]);
      res.status(201).json(nuevo);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al crear la orden de compra y actualizar itemizado' });
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

// PUT actualizar orden de compra
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const {
    proveedorId,
    numero_orden,
    fecha_emision,
    centro_costo,
    itemizadoId,
    numero_cotizacion,
    numero_contacto,
    nombre_servicio,
    valor,
    descuento,
    notas_adicionales,
    estado,
  } = req.body;

  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

  if (!uuidRegex.test(id)) {
    return res.status(400).json({ error: 'ID de orden inválido (debe ser UUID v4)' });
  }
  if (!uuidRegex.test(proveedorId)) {
    return res.status(400).json({ error: 'proveedorId inválido (debe ser UUID v4)' });
  }
  if (itemizadoId && !uuidRegex.test(itemizadoId)) {
    return res.status(400).json({ error: 'itemizadoId inválido (debe ser UUID v4)' });
  }

  if (!numero_orden || !fecha_emision || !centro_costo || !nombre_servicio || valor === undefined) {
    return res.status(400).json({ error: 'Faltan campos obligatorios.' });
  }

  try {
    const proveedor = await prisma.proveedores.findUnique({ where: { id: proveedorId } });
    if (!proveedor) return res.status(404).json({ error: 'Proveedor no encontrado.' });

    let itemizado;
    if (itemizadoId) {
      itemizado = await prisma.itemizados.findUnique({ where: { id: itemizadoId } });
      if (!itemizado) return res.status(404).json({ error: 'Itemizado no encontrado.' });
      if (itemizado.monto_disponible < valor) {
        return res.status(400).json({ error: 'Monto disponible insuficiente en el itemizado.' });
      }
    }

    const transaction = [
      prisma.ordenes_de_compra.update({
        where: { id },
        data: {
          numero_orden,
          fecha_emision: new Date(fecha_emision),
          proveedor: { connect: { id: proveedorId } },
          centro_costo,
          itemizado: itemizadoId ? { connect: { id: itemizadoId } } : undefined,
          numero_cotizacion,
          numero_contacto,
          nombre_servicio,
          valor,
          descuento,
          notas_adicionales,
          estado,
        },
      }),
    ];
    if (itemizadoId) {
      transaction.push(
        prisma.itemizados.update({
          where: { id: itemizadoId },
          data: { monto_disponible: { decrement: valor } },
        })
      );
    }

    const [ordenActualizada] = await prisma.$transaction(transaction);

    res.status(200).json({
      mensaje: 'Orden actualizada correctamente',
      orden: ordenActualizada,
    });

  } catch (error) {
    console.error('Error al actualizar la orden de compra:', error);

    if (error.code === 'P2025') {
      return res.status(404).json({ error: `No se encontró la orden de compra con ID: ${id}` });
    }
    if (error.code === 'P2002') {
      return res.status(400).json({ error: 'Número de orden duplicado.' });
    }

    res.status(500).json({ error: 'Error interno del servidor al actualizar la orden.' });
  }
});



module.exports = router;
