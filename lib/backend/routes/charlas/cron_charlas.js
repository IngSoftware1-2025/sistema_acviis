const nodemailer = require('nodemailer');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function enviarRecordatoriosCharlas() {
  console.log('[INFO] Verificando recordatorios de charlas...');

  // 1. Configurar el transportador de nodemailer con las credenciales del .env
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  // 2. Calcular el rango de fechas para "mañana"
  const hoy = new Date();
  const manana = new Date();
  manana.setDate(hoy.getDate() + 1);

  const inicioManana = new Date(manana.setHours(0, 0, 0, 0));
  const finManana = new Date(manana.setHours(23, 59, 59, 999));

  try {
    // 3. Buscar charlas programadas para mañana que no tengan recordatorio enviado
    const charlasParaNotificar = await prisma.charlas.findMany({
      where: {
        fecha_programada: {
          gte: inicioManana,
          lte: finManana,
        },
        recordatorio_enviado: false,
        obra: {
          // Solo incluir charlas de obras que tengan un responsable con email
          responsable_email: {
            not: null,
            not: '',
          },
        },
      },
      include: {
        obra: {
          select: {
            nombre: true,
            responsable_email: true,
          },
        },
      },
    });

    if (charlasParaNotificar.length === 0) {
      console.log('[INFO] No hay recordatorios de charlas para enviar.');
      return;
    }

    console.log(`[INFO] Se encontraron ${charlasParaNotificar.length} charlas para notificar.`);

    // 4. Iterar sobre cada charla y enviar el correo
    for (const charla of charlasParaNotificar) {
      const mailOptions = {
        from: `"Sistema Acviis" <${process.env.EMAIL_USER}>`,
        to: charla.obra.responsable_email,
        subject: `Recordatorio: Charla de Seguridad en Obra "${charla.obra.nombre}"`,
        html: `
          <h1>Recordatorio de Charla de Seguridad</h1>
          <p>Hola,</p>
          <p>Este es un recordatorio de que hay una charla de seguridad programada para mañana.</p>
          <ul>
            <li><strong>Obra:</strong> ${charla.obra.nombre}</li>
            <li><strong>Fecha y Hora:</strong> ${new Date(charla.fecha_programada).toLocaleString('es-CL', { timeZone: 'America/Santiago' })}</li>
          </ul>
          <p>Por favor, asegúrese de que todo esté preparado.</p>
          <br>
          <p>Atentamente,<br>Sistema de Gestión Acviis</p>
        `,
      };

      // 5. Enviar el correo y actualizar la base de datos
      await transporter.sendMail(mailOptions);
      console.log(`[SUCCESS] Correo de recordatorio enviado a ${charla.obra.responsable_email} para la charla ID: ${charla.id}`);

      // Marcar la charla como notificada para no volver a enviarla
      await prisma.charlas.update({
        where: { id: charla.id },
        data: { recordatorio_enviado: true },
      });
    }
  } catch (error) {
    console.error('[ERROR] Ocurrió un error en el proceso de envío de recordatorios de charlas:', error);
  }
}

module.exports = { enviarRecordatoriosCharlas };
