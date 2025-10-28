const nodemailer = require('nodemailer');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Función de notificación de excesos
async function EnviarNotificacionesItemizados() {
  console.log('[INFO] Verificando exceso de gasto en itemizados...');

  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  const itemizados = await prisma.itemizados.findMany({
    include: {
      facturas: true,
      obra: true,
    },
  });

  // Solo imprimir la cantidad de ítems procesados
  console.log(`[INFO] Se encontraron ${itemizados.length} itemizados`);

  for (const it of itemizados) {
    const gasto = it.facturas.reduce((a, f) => a + (f.valor || 0), 0);

    // Solo imprimir log cuando haya un exceso
    if (gasto > it.monto_total && it.obra?.responsable_email) {
      console.log(`[INFO] Exceso detectado en ítem: ${it.nombre}`);

      // Si ya fue notificado, no lo volvemos a hacer
      if (it.exceso_notificado) {
        console.log(`[INFO] El ítem ${it.nombre} ya fue notificado previamente`);
        continue;
      }

      // Enviar correo de notificación
      await transporter.sendMail({
        from: `"Sistema Acviis" <${process.env.EMAIL_USER}>`,
        to: process.env.EMAIL_USER,  // Usar el correo configurado en .env
        subject: `⚠ Exceso de gasto en ítem: ${it.nombre}`,
        html: `
          <p>Se ha detectado un exceso de gasto en:</p>
          <ul>
            <li><b>Obra:</b> ${it.obra.nombre}</li>
            <li><b>Ítem:</b> ${it.nombre}</li>
            <li><b>Presupuesto:</b> $${it.monto_total.toLocaleString('es-CL')}</li>
            <li><b>Gasto actual:</b> $${gasto.toLocaleString('es-CL')}</li>
          </ul>
          <p>Por favor revise en el sistema.</p>
        `,
      });

      // Marcar que el ítem ha sido notificado
      await prisma.itemizados.update({
        where: { id: it.id },
        data: { exceso_notificado: true },
      });

      console.log(`[MAIL OK] Notificado exceso en item ${it.nombre}`);
    } else if (gasto <= it.monto_total && it.exceso_notificado) {
      // Si el gasto es menor al monto total y fue notificado previamente, resetear el campo
      await prisma.itemizados.update({
        where: { id: it.id },
        data: { exceso_notificado: false },
      });
    }
  }
}

const cron = require('node-cron');

cron.schedule('0 9 * * *', async () => {
  console.log('[INFO] Ejecutando verificación de excesos de gasto en itemizados...');
  await EnviarNotificacionesItemizados();
});

module.exports = { EnviarNotificacionesItemizados };
