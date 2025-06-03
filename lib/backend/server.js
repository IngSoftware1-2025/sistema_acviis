const supabase = require('./supabaseClient');
const express = require('express');
const { PrismaClient } = require('@prisma/client');
const cors = require('cors');

require('dotenv').config(); // Cargar variables de entorno

const prisma = new PrismaClient();
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json()); // Habilitar el parsing de JSON en las solicitudes
app.use(cors()); // Habilitar CORS para todas las rutas

//de aqui para abajo es el codigo de prueba que hice para verificar que el backend funciona correctamente
app.post('/personas', async (req, res) => {
  const { nombre, apellido, email, edad } = req.body;

  // Validación básica
  if (!nombre || !email) {
    return res.status(400).json({ error: 'Nombre y email son campos requeridos.' });
  }

  try {
    const nuevaPersona = await prisma.persona.create({
      data: {
        nombre: nombre,
        apellido: apellido || null, // Guarda null si está vacío
        email: email,
        edad: edad ? parseInt(edad, 10) : null, // Convierte a número o null
      },
    });
    res.status(201).json(nuevaPersona); // 201 Created
  } catch (error) {
    console.error('Error al crear persona:', error);
    // Manejo de error para email duplicado (código de error de Prisma P2002)
    if (error.code === 'P2002' && error.meta?.target?.includes('email')) {
      return res.status(409).json({ error: 'El email ya está registrado para otra persona.' });
    }
    res.status(500).json({ error: 'No se pudo crear la persona.', details: error.message });
  }
});
// --- Ruta de ejemplo con middleware de autenticación (manteniendo tu código) ---
app.get('/protected-route', async (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ error: 'No se proporcionó token de autorización' });
  }

  const token = authHeader.split(' ')[1]; // Asume formato "Bearer <token>"

  try {
    // Asegúrate de que `supabaseClient` esté configurado correctamente para verificar JWT.
    // Esto podría ser `supabase.auth.admin.verifyJWT(token)` si estás usando la clave de servicio
    // o `supabase.auth.getUser(token)` si el token ya es un token de sesión de usuario y no de servicio.
    // Si usas verifyJWT, necesitarás la clave de servicio. Si es getUser, basta con la clave anon.
    const { data: user, error } = await supabase.auth.getUser(token);

    if (error) {
      return res.status(401).json({ error: 'Token inválido', details: error.message });
    }

    res.json({ message: 'Acceso autorizado', user: user.user });
  } catch (error) {
    console.error('Error al verificar token:', error);
    res.status(500).json({ error: 'Error interno del servidor al autenticar' });
  }
});
//de aqui para arriba es el codigo de prueba que hice para verificar que el backend funciona correctamente
//no lo quise borrar porque es un ejemplo de como hacer una ruta protegida con supabase y porque puede que falle

// Iniciar el servidor
app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});

// Manejo de cierre de la conexión de Prisma cuando la aplicación se detenga
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});

