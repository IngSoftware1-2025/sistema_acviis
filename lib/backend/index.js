const supabase = require('./supabaseClient');
const express = require('express');
const { PrismaClient } = require('@prisma/client');
const cors = require('cors');

console.log('[INFO] Cargando variables de entorno...');
require('dotenv').config({ path: './lib/backend/.env' }); // Para cuando se lanza automáticamente por tasks.json

const prisma = new PrismaClient();
const app = express();
const port = process.env.PORT || 3000;

console.log('[INFO] Iniciando servidor...');
app.use(express.json());
app.use(cors());

// --------- RUTA POST: CREAR PERSONA ---------
app.post('/personas', async (req, res) => {
  console.log('[POST] /personas → Datos recibidos:', req.body);
  const { nombre, apellido, email, edad } = req.body;

  if (!nombre || !email) {
    console.warn('[WARN] Nombre o email no proporcionado');
    return res.status(400).json({ error: 'Nombre y email son campos requeridos.' });
  }

  try {
    const nuevaPersona = await prisma.persona.create({
      data: {
        nombre,
        apellido: apellido || null,
        email,
        edad: edad ? parseInt(edad, 10) : null,
      },
    });

    console.log('[SUCCESS] Persona creada:', nuevaPersona);
    res.status(201).json(nuevaPersona);
  } catch (error) {
    console.error('[ERROR] Al crear persona:', error);
    if (error.code === 'P2002' && error.meta?.target?.includes('email')) {
      return res.status(409).json({ error: 'El email ya está registrado para otra persona.' });
    }
    res.status(500).json({ error: 'No se pudo crear la persona.', details: error.message });
  }
});

// --------- RUTA GET: OBTENER TRABAJADORES ---------
app.get('/getTrabajadores', async (req, res) => {
  console.log('[GET] /getTrabajadores → Intentando obtener trabajadores...');
  try {
    const personas = await prisma.persona.findMany({
      orderBy: { createdAt: 'desc' },
    });

    console.log(`[SUCCESS] ${personas.length} trabajadores encontrados.`);
    res.json(personas);
  } catch (err) {
    console.error('[ERROR] Al obtener trabajadores:', err);
    res.status(500).json({ error: 'Error al obtener trabajadores' });
  }
});

// --------- RUTA GET: RUTA PROTEGIDA ---------
app.get('/protected-route', async (req, res) => {
  console.log('[GET] /protected-route → Verificando token...');
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    console.warn('[WARN] No se proporcionó token de autorización');
    return res.status(401).json({ error: 'No se proporcionó token de autorización' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const { data: user, error } = await supabase.auth.getUser(token);

    if (error) {
      console.warn('[WARN] Token inválido:', error.message);
      return res.status(401).json({ error: 'Token inválido', details: error.message });
    }

    console.log('[SUCCESS] Token verificado. Usuario:', user.user?.email || 'sin email');
    res.json({ message: 'Acceso autorizado', user: user.user });
  } catch (error) {
    console.error('[ERROR] Verificando token:', error);
    res.status(500).json({ error: 'Error interno del servidor al autenticar' });
  }
});

// --------- INICIAR SERVIDOR ---------
app.listen(port, () => {
  console.log(`[READY] Servidor escuchando en http://localhost:${port}`);
});

// --------- CIERRE GRACIOSO ---------
process.on('beforeExit', async () => {
  console.log('[INFO] Cerrando conexión con Prisma...');
  await prisma.$disconnect();
});
