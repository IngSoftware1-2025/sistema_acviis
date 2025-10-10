const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// TODO: Configurar Multer para la subida de archivos y el cliente de Supabase Storage.

// --- Gestión de Obras ---

// GET todas las obras con sus charlas
router.get('/', async (req, res) => {
  try {
    const obras = await prisma.obras.findMany({
      orderBy: { createdat: 'desc' },
      include: {
        charlas: {
          orderBy: { fecha_programada: 'asc' },
          include: {
            asistencias_charlas: true,
          },
        },
      },
    });
    res.json(obras);
  } catch (error) {
    console.error('Error al obtener obras:', error);
    res.status(500).json({ error: 'Error interno del servidor.' });
  }
});

// GET una obra por ID
router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
      const obra = await prisma.obras.findUnique({
        where: { id },
        include: {
          charlas: {
            orderBy: { fecha_programada: 'asc' },
            include: {
              asistencias_charlas: true,
            },
          },
        },
      });
      if (!obra) {
        return res.status(404).json({ error: 'Obra no encontrada.' });
      }
      res.json(obra);
    } catch (error) {
      console.error(`Error al obtener la obra ${id}:`, error);
      res.status(500).json({ error: 'Error interno del servidor.' });
    }
});

// POST para crear una nueva obra
router.post('/', async (req, res) => {
    const { nombre, descripcion, estado, responsable_email } = req.body;
    if (!nombre) {
        return res.status(400).json({ error: 'El nombre de la obra es requerido.' });
    }
    try {
        const nuevaObra = await prisma.obras.create({
            data: {
                nombre,
                descripcion,
                estado,
                responsable_email,
            },
        });
        res.status(201).json(nuevaObra);
    } catch (error) {
        console.error('Error al crear la obra:', error);
        res.status(500).json({ error: 'No se pudo crear la obra.' });
    }
});


// --- Gestión de Charlas (CU075) ---

// POST para agregar una nueva charla a una obra
router.post('/:obraId/charlas', async (req, res) => {
    const { obraId } = req.params;
    const { fecha_programada, tipo_programacion, intervalo_dias } = req.body;

    if (!fecha_programada) {
        return res.status(400).json({ error: 'La fecha de la charla es requerida.' });
    }

    try {
        const nuevaCharla = await prisma.charlas.create({
            data: {
                obra_id: obraId,
                fecha_programada: new Date(fecha_programada), // Asegurarse que sea un objeto Date
                tipo_programacion,
                intervalo_dias,
                estado: 'Programada',
            },
        });
        res.status(201).json(nuevaCharla);
    } catch (error) {
        console.error(`Error al crear charla para la obra ${obraId}:`, error);
        res.status(500).json({ error: 'No se pudo programar la charla.' });
    }
});

// POST para subir archivo de asistencia a una charla (CU075)
// Este es un placeholder. La implementación real requiere 'multer' y 'supabase-js'
router.post('/charlas/:charlaId/asistencia', async (req, res) => {
    const { charlaId } = req.params;
    // Lógica para recibir el archivo con multer, subirlo a Supabase Storage,
    // obtener la URL y guardarla en la tabla 'asistencias_charlas'.
    console.log(`Recibida petición para subir asistencia a charla ${charlaId}`);
    res.status(501).json({ message: 'Endpoint no implementado. Se requiere configuración de subida de archivos.' });
});

module.exports = router;