const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// GET Obtener configuración
router.get('/configuracion-notificaciones', async (req, res) => {
  try {
    const config = await prisma.configuracion_notificaciones.findFirst();
    if (!config) return res.json({ diasantes: 3, diasdespues: 0 });
    res.json(config);
  } catch (error) {
    console.error('Error obtener configuración:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// POST Guardar configuración
router.post('/configurar-notificaciones', async (req, res) => {
  try {
    const { diasantes, diasdespues } = req.body;

    if (diasantes == null || diasdespues == null) {
      return res.status(400).json({ error: 'Faltan datos' });
    }

    let config = await prisma.configuracion_notificaciones.findFirst();

    if (config) {
      config = await prisma.configuracion_notificaciones.update({
        where: { id: config.id },
        data: { diasantes, diasdespues },
      });
    } else {
      config = await prisma.configuracion_notificaciones.create({
        data: { diasantes, diasdespues },
      });
    }

    return res.json({ message: 'Configuración guardada', config });
  } catch (error) {
    console.error('Error guardar configuración:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router;
