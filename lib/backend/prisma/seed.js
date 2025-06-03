const dotenv = require('dotenv');
//este es un codigo para meter datos de prueba en la base de datos
// lo cual me ayudo a saber que si funciona en el backend
//para verificar que las variables de entorno se cargan correctamente
// tienes que estar en la carpeta backend y ejecutar el comando:
// node prisma/seed.js
// mientras tienes ejecutado node server.js en otra terminal
dotenv.config();

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('--- Ejecutando seed.js ---');
  console.log(`Verificando DATABASE_URL: ${process.env.DATABASE_URL ? 'Cargada correctamente' : 'ERROR: DATABASE_URL no está cargada'}`);
  console.log(process.env.DATABASE_URL);

  if (!process.env.DATABASE_URL) {
      console.error('ERROR CRÍTICO: DATABASE_URL no está definida. La siembra no puede continuar.');
      process.exit(1); // Salir si la variable no está cargada
  }

  try {
    const personasData = [
      { nombre: 'Juan', apellido: 'Perez', email: 'juan.perez@example.com', edad: 30 },
      { nombre: 'Maria', apellido: 'Gomez', email: 'maria.gomez@example.com', edad: 25 },
    ];

    console.log(`Intentando insertar ${personasData.length} personas...`);

    for (const persona of personasData) {
      console.log(`Procesando persona: ${persona.nombre} (${persona.email})`);
      const result = await prisma.persona.upsert({
        where: { email: persona.email },
        update: { nombre: persona.nombre, apellido: persona.apellido, edad: persona.edad },
        create: { nombre: persona.nombre, apellido: persona.apellido, email: persona.email, edad: persona.edad },
      });
      console.log(`Procesado: ID=${result.id}, Nombre=${result.nombre}`);
    }

    console.log('--- SIEMBRA COMPLETADA CON ÉXITO ---');

  } catch (error) {
    console.error('--- ERROR DURANTE LA SIEMBRA ---');
    console.error(error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
    console.log('Prisma Client desconectado.');
  }
}

main();