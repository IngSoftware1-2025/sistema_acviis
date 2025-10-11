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

router.post('/asignar-trabajador', async (req, res) => {
  try {
    const { obraId, trabajadorId, rolEnObra } = req.body;

    console.log(`Asignando trabajador ${trabajadorId} a obra ${obraId}, rol: ${rolEnObra || 'No especificado'}`);

    // Validaciones
    if (!obraId || !trabajadorId) {
      return res.status(400).json({ error: 'ID de obra y trabajador son requeridos.' });
    }

    // Verificar que la obra existe
    const obra = await prisma.obras.findUnique({
      where: { id: obraId }
    });

    if (!obra) {
      return res.status(404).json({ error: 'Obra no encontrada.' });
    }

    // Verificar que el trabajador existe y no está despedido
    const trabajador = await prisma.trabajadores.findUnique({
      where: { id: trabajadorId }
    });

    if (!trabajador) {
      return res.status(404).json({ error: 'Trabajador no encontrado.' });
    }

    if (trabajador.estado.toLowerCase() === 'despedido') {
      return res.status(400).json({ error: 'No se puede asignar un trabajador despedido a una obra.' });
    }

    // Verificar si ya existe una asignación activa
    const asignacionExistente = await prisma.trabajador_obra.findFirst({
      where: {
        trabajador_id: trabajadorId,
        obra_id: obraId,
        fecha_desasignacion: null // Sin fecha de desasignación significa que está activo
      }
    });

    if (asignacionExistente) {
      return res.status(400).json({ error: 'El trabajador ya está asignado a esta obra.' });
    }

    // Crear la asignación
    const asignacion = await prisma.trabajador_obra.create({
      data: {
        trabajador_id: trabajadorId,
        obra_id: obraId,
        fecha_asignacion: new Date(),
        rol_en_obra: rolEnObra || 'No especificado',
        estado: 'activo'
      }
    });

    console.log(`Trabajador asignado correctamente. ID de asignación: ${asignacion.id}`);

    res.status(201).json({
      message: 'Trabajador asignado a la obra exitosamente.',
      asignacion
    });
  } catch (error) {
    console.error('Error al asignar trabajador a obra:', error);
    res.status(500).json({ error: `Error interno del servidor: ${error.message}` });
  }
});

router.put('/quitar-trabajador', async (req, res) => {
  try {
    const { obraId, trabajadorId } = req.body;

    console.log(`Quitando trabajador ${trabajadorId} de obra ${obraId}`);

    // Validaciones
    if (!obraId || !trabajadorId) {
      return res.status(400).json({ error: 'ID de obra y trabajador son requeridos.' });
    }

    // Buscar la asignación activa
    const asignacion = await prisma.trabajador_obra.findFirst({
      where: {
        trabajador_id: trabajadorId,
        obra_id: obraId,
        fecha_desasignacion: null // Sin fecha de desasignación significa que está activo
      }
    });

    console.log('Asignación encontrada:', asignacion);

    // Verificar si existe la asignación
    if (!asignacion) {
      return res.status(404).json({ error: 'No se encontró una asignación activa de este trabajador a esta obra.' });
    }

    // Actualizar la asignación con la fecha de desasignación
    const asignacionActualizada = await prisma.trabajador_obra.update({
      where: { id: asignacion.id },
      data: {
        fecha_desasignacion: new Date(),
        estado: 'inactivo'
      }
    });

    console.log('Trabajador desasignado correctamente. Datos actualizados:', asignacionActualizada);

    res.json({
      message: 'Trabajador desasignado de la obra exitosamente.',
      asignacion: asignacionActualizada
    });
  } catch (error) {
    console.error('Error al quitar trabajador de obra:', error);
    res.status(500).json({ error: `Error interno del servidor: ${error.message}` });
  }
});


router.get('/:obraId/trabajadores', async (req, res) => {
  try {
    const { obraId } = req.params;

    // Validación
    if (!obraId) {
      return res.status(400).json({ error: 'ID de obra es requerido.' });
    }

    console.log(`Obteniendo trabajadores para la obra ${obraId}`);

    // Verificar que la obra existe
    const obra = await prisma.obras.findUnique({
      where: { id: obraId }
    });

    if (!obra) {
      return res.status(404).json({ error: 'Obra no encontrada.' });
    }

    // Buscar todas las asignaciones activas para esta obra
    const asignaciones = await prisma.trabajador_obra.findMany({
      where: {
        obra_id: obraId,
        fecha_desasignacion: null, // Solo asignaciones activas
        estado: 'activo'
      },
      include: {
        trabajadores: true // Incluir información del trabajador
      }
    });

    console.log(`Encontradas ${asignaciones.length} asignaciones activas`);

    // Formatear la respuesta para enviar solo la información necesaria
    const trabajadores = asignaciones.map(asignacion => {
      // Verificar si la relación trabajadores existe
      if (!asignacion.trabajadores) {
        console.error(`Advertencia: Asignación ${asignacion.id} no tiene relación trabajadores`);
        return null;
      }

      return {
        id: asignacion.trabajador_id,
        nombreCompleto: asignacion.trabajadores.nombre_completo,
        rut: asignacion.trabajadores.rut,
        rolEnObra: asignacion.rol_en_obra || 'No especificado',
        fechaAsignacion: asignacion.fecha_asignacion,
        estado: asignacion.trabajadores.estado,
        // Incluimos la información del objeto trabajadorObra
        asignacionId: asignacion.id
      };
    }).filter(Boolean); // Filtrar elementos nulos

    res.json({
      cantidad: trabajadores.length,
      trabajadores
    });
  } catch (error) {
    console.error('Error al obtener trabajadores de la obra:', error);
    res.status(500).json({ error: 'Error interno del servidor.' });
  }
});

module.exports = router;