const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const multer = require('multer');
const supabase = require('../services/supabaseClient');

// Configuración de Multer para manejar archivos en memoria
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// --- Gestión de Obras ---

// GET todas las obras con sus charlas
router.get('/', async (req, res) => {
  try {
    const obras = await prisma.obras.findMany({
      select: {
        id: true,
        nombre: true,
        descripcion: true,
        createdat: true,
        updatedat: true,
        responsable_email: true,
        direccion: true,
        obraInicio: true,
        obraFin: true,
        jornada: true,
        charlas: {
          orderBy: { fecha_programada: 'asc' },
          include: {
            asistencias_charlas: true,
          },
        },
      },
      orderBy: { createdat: 'desc' },
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
        select: {
          id: true,
          nombre: true,
          descripcion: true,
          createdat: true,
          updatedat: true,
          responsable_email: true,
          direccion: true,
          obraInicio: true,
          obraFin: true,
          jornada: true,
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
    const { nombre, descripcion, responsable_email, direccion, obraInicio, obraFin, jornada } = req.body;
    if (!nombre || !direccion) {
        return res.status(400).json({ error: 'El nombre y la dirección de la obra son requeridos.' });
    }
    try {
        const nuevaObra = await prisma.obras.create({
            data: {
                nombre,
                descripcion,
                responsable_email,
                direccion,
                obraInicio: obraInicio ? new Date(obraInicio) : undefined,
                obraFin: obraFin ? new Date(obraFin) : undefined,
                jornada,
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
router.post('/charlas/:charlaId/asistencia', upload.single('asistencia'), async (req, res) => {
    const { charlaId } = req.params;

    if (!req.file) {
        return res.status(400).json({ error: 'No se ha subido ningún archivo.' });
    }

    try {
        const file = req.file;
        const fileName = `${charlaId}-${Date.now()}-${file.originalname}`;
        const bucketName = 'asistencias-charlas';

        // 1. Subir el archivo a Supabase Storage
        const { data: uploadData, error: uploadError } = await supabase.storage
            .from(bucketName)
            .upload(fileName, file.buffer, {
                contentType: file.mimetype,
                upsert: false,
            });

        if (uploadError) throw uploadError;

        // 2. Obtener la URL pública del archivo
        const { data: urlData } = supabase.storage.from(bucketName).getPublicUrl(fileName);

        // 3. Guardar la referencia en la base de datos
        const nuevaAsistencia = await prisma.asistencias_charlas.create({
            data: {
                charla_id: charlaId,
                nombre_archivo: file.originalname,
                url_archivo: urlData.publicUrl,
            },
        });

        res.status(201).json(nuevaAsistencia);
    } catch (error) {
        console.error(`Error al subir asistencia para la charla ${charlaId}:`, error);
        res.status(500).json({ error: 'Error interno del servidor al subir el archivo.' });
    }
});

// DELETE para eliminar un archivo de asistencia (CU075)
router.delete('/charlas/asistencia/:asistenciaId', async (req, res) => {
    const { asistenciaId } = req.params;

    try {
        // 1. Buscar el registro en la BD para obtener la URL del archivo
        const asistencia = await prisma.asistencias_charlas.findUnique({
            where: { id: asistenciaId },
        });

        if (!asistencia) {
            // Si no existe en la BD, consideramos que ya está borrado.
            return res.status(200).json({ message: 'El registro de asistencia no fue encontrado, posiblemente ya fue eliminado.' });
        }

        // 2. Extraer el nombre del archivo de la URL
        const urlParts = asistencia.url_archivo.split('/');
        const fileName = urlParts[urlParts.length - 1];
        const bucketName = 'asistencias-charlas';

        // 3. Eliminar el archivo de Supabase Storage
        await supabase.storage.from(bucketName).remove([fileName]);

        // 4. Eliminar el registro de la base de datos
        await prisma.asistencias_charlas.delete({
            where: { id: asistenciaId },
        });

        res.status(200).json({ message: 'Asistencia eliminada correctamente.' });
    } catch (error) {
        console.error(`Error al eliminar la asistencia ${asistenciaId}:`, error);
        res.status(500).json({ error: 'Error interno del servidor al eliminar la asistencia.' });
    }
});

module.exports = router;