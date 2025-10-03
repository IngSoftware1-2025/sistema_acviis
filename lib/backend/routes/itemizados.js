const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// GET todos los itemizados
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

module.exports = router;
