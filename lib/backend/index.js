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
const registrarEppRoutes = require('./routes/epp/e_supabase');
const eppCertificadosRoutes = require('./routes/epp_certificados_mongoDB');
const proveedoresRoutes = require('./routes/proveedores');
const herramientasRoutes = require('./routes/herramientas');
const vehiculosRoutes = require('./routes/vehiculos');
const ordenesRoutes = require('./routes/ordenes');
const pagosRoutes = require('./routes/finanzas/pagos');
const uploadPdf = require('./routes/finanzas/pagos_pdf_mongoDB');
const descargarPdf = require('./routes/finanzas/descargarPago_pdf_mongoDB');
const itemizadosRoutes = require('./routes/itemizados');
const {enviarNotificaciones} = require('./routes/finanzas/cron_notificaciones');
const configurarNotificacionesRouter = require('./routes/finanzas/configurar_notificaciones');
const obrasRoutes = require('./routes/obras');


// Usar rutas
app.use('/trabajadores', trabajadoresRoutes); // /trabajadores y /trabajadores/:id
app.use('/auth', protectedRoutes);           // /auth/protected-route

app.use('/contratos/supabase', contratosSupabaseRoutes);     // /contratos y /contratos/:id
app.use('/contratos/mongo', contratosMongoRoutes);

app.use('/anexos/supabase', anexosSupabaseRoutes);
app.use('/anexos/mongo', anexosMongoRoutes);

app.use('/comentarios', comentariosRouter); // /comentarios y /comentarios/:id

app.use('/api/epp', registrarEppRoutes);
app.use('/api/epp', eppCertificadosRoutes);

app.use('/proveedores', proveedoresRoutes); // /proveedores y /proveedores/:id

app.use('/herramientas', herramientasRoutes);
app.use('/vehiculos', vehiculosRoutes);

app.use('/ordenes_de_compra', ordenesRoutes);
app.use('/itemizados', itemizadosRoutes); // /itemizados y /itemizados/:id

app.use('/pagos', pagosRoutes); // /pagos
app.use('/finanzas', uploadPdf); // /finanzas/upload-pdf
app.use('/finanzas', descargarPdf); // /finanzas/download-pdf/:id
app.use('/finanzas', configurarNotificacionesRouter);
app.use('/obras', obrasRoutes);


// --------- INICIAR SERVIDOR ---------
app.listen(port, async () => {
  console.log(`[READY] Servidor escuchando en http://localhost:${port}`);

  // Notificaciones
  try {
    await enviarNotificaciones();
  } catch (error) {
    console.error('[ERROR] Enviando notificaciones al iniciar:', error);
  }
});

/*
// --------- CIERRE GRACIOSO ---------
process.on('beforeExit', async () => {
  console.log('[INFO] Cerrando conexión con Prisma...');
  await prisma.$disconnect();
});
*/
