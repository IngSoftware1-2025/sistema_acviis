console.log('[INFO] Cargando variables de entorno...');
require('dotenv').config({ path: '.env' }); // Para cuando se lanza automáticamente por tasks.json

// Supabase
const supabase = require('./services/supabaseClient');
const express = require('express');
const { PrismaClient } = require('@prisma/client');

// Prisma
const prisma = new PrismaClient();
const app = express();
const port = process.env.PORT || 3000;

// Seguridad 
const cors = require('cors');


console.log('[INFO] Iniciando servidor...');
app.use(express.json());
app.use(cors());

// Importar rutas modularizadas
const trabajadoresRoutes = require('./routes/trabajadores');
const protectedRoutes = require('./routes/protected');
const contratosSupabaseRoutes = require('./routes/contratos/c_supabase');
const contratosMongoRoutes = require('./routes/contratos/c_mongoDB');
const anexosSupabaseRoutes = require('./routes/anexos/a_supabase');
const anexosMongoRoutes = require('./routes/anexos/a_mongoDB');
const comentariosRouter = require('./routes/comentarios');

// Usar rutas
app.use('/trabajadores', trabajadoresRoutes); // /trabajadores y /trabajadores/:id
app.use('/auth', protectedRoutes);           // /auth/protected-route

app.use('/contratos/supabase', contratosSupabaseRoutes);     // /contratos y /contratos/:id
app.use('/contratos/mongo', contratosMongoRoutes);

app.use('/anexos/supabase', anexosSupabaseRoutes);
app.use('/anexos/mongo', anexosMongoRoutes);

app.use('/comentarios', comentariosRouter); // /comentarios y /comentarios/:id

// --------- INICIAR SERVIDOR ---------
app.listen(port, () => {
  console.log(`[READY] Servidor escuchando en http://localhost:${port}`);
});



/*
// --------- CIERRE GRACIOSO ---------
process.on('beforeExit', async () => {
  console.log('[INFO] Cerrando conexión con Prisma...');
  await prisma.$disconnect();
});
*/