const nodemailer = require('nodemailer');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

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

  for (const it of itemizados) {
    const gasto = it.facturas.reduce((a, f) => a + (f.valor || 0), 0);

    if (gasto > it.monto_total && it.obra?.responsable_email) {
      const yaNotificado = it.facturas.every(f => f.notificado === true);
      if (yaNotificado) continue;

      await transporter.sendMail({
        from: `"Sistema Acviis" <${process.env.EMAIL_USER}>`,
        to: it.obra.responsable_email,
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

      await prisma.pagos.updateMany({
        where: { itemizadoId: it.id },
        data: { notificado: true },
      });

      console.log(`[MAIL OK] Notificado exceso en item ${it.nombre}`);
    }
  }
}

module.exports = { EnviarNotificacionesItemizados };
