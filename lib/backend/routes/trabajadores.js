const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const createFichaTrabajador = require('../formatos/ficha_trabajadores');

// GET todos los trabajadores con sus contratos
router.get('/', async (req, res) => {
  try {
    const trabajadores = await prisma.trabajadores.findMany({
      orderBy: { id: 'desc' },
      include: { 
      contratos: { 
        include: { 
          anexos: { 
            include: { comentarios: true } 
          } 
        } 
      } 
      }, 
    });
    res.json(trabajadores);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener trabajadores' });
  }
});

// GET trabajador por id (UUID string)
router.get('/:id', async (req, res) => {
  const id = req.params.id;
  try {
    const trabajador = await prisma.trabajadores.findUnique({ where: { id } });
    if (!trabajador) return res.status(404).json({ error: 'Trabajador no encontrado' });
    res.json(trabajador);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener trabajador' });
  }
});

// POST crear trabajador
router.post('/', async (req, res) => {
  const {
    nombre_completo,
    estado_civil,
    rut,
    fecha_de_nacimiento,
    direccion,
    correo_electronico,
    sistema_de_salud,
    prevision_afp,
    obra_en_la_que_trabaja,
    rol_que_asume_en_la_obra,
  } = req.body;

  if (!nombre_completo || !correo_electronico) {
    return res.status(400).json({ error: 'Nombre completo y correo electrónico requeridos' });
  }

  try {
    const nuevo = await prisma.trabajadores.create({
      data: {
        nombre_completo,
        estado_civil,
        rut,
        fecha_de_nacimiento: new Date(fecha_de_nacimiento),
        direccion,
        correo_electronico,
        sistema_de_salud,
        prevision_afp,
        obra_en_la_que_trabaja,
        rol_que_asume_en_la_obra,
        estado: "Activo",
      },
    });
    res.status(201).json(nuevo);
  } catch (error) {
    if (error.code === 'P2002' && error.meta?.target?.includes('correo_electronico')) {
      return res.status(409).json({ error: 'Correo electrónico ya registrado' });
    }
    res.status(500).json({ error: 'No se pudo crear trabajador', details: error.message });
  }
});

// Actualiza los datos del trabajador
router.put('/:id/datos', async (req, res) => {
  const { id } = req.params;
  const {
    nombre_completo,
    estado_civil,
    direccion,
    correo_electronico,
    sistema_de_salud,
    prevision_afp,
    obra_en_la_que_trabaja,
    rol_que_asume_en_la_obra,
  } = req.body;
  if (
    !nombre_completo || !estado_civil ||
    !direccion || !correo_electronico || !sistema_de_salud ||
    !prevision_afp || !obra_en_la_que_trabaja || !rol_que_asume_en_la_obra
  ) {
    return res.status(400).json({ error: 'Todos los campos son obligatorios' });
  }

  try {
    const actualizado = await prisma.trabajadores.update({
      where: { id },
      data: {
        nombre_completo,
        estado_civil,
        direccion,
        correo_electronico,
        sistema_de_salud,
        prevision_afp,
        obra_en_la_que_trabaja,
        rol_que_asume_en_la_obra,
      },
    });
    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar el trabajador', details: error.message });
  }
});

// Actualiza el estado del trabajador
router.put('/:id/estado', async (req, res) => {
  const { id } = req.params;
  const { estado } = req.body;
  if (!estado) {
    return res.status(400).json({ error: 'El campo estado es obligatorio' });
  }
  try {
    const actualizado = await prisma.trabajadores.update({
      where: { id },
      data: { estado },
    });
    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar el estado', details: error.message });
  }
});

router.get('/:id/ficha-pdf', async (req, res) => {
  const { id } = req.params;
  try {
    const trabajador = await prisma.trabajadores.findUnique({ where: { id } });
    if (!trabajador) return res.status(404).send('Trabajador no encontrado');

    const pdfData = await createFichaTrabajador(trabajador);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=ficha_trabajador_${trabajador.rut || trabajador.id}.pdf`);
    res.send(pdfData);
  } catch (error) {
    res.status(500).send('Error al generar PDF');
  }
});

module.exports = router;