require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const createFichaPagos = require('../../formatos/ficha_pagos');
const nodemailer = require('nodemailer');
const cron = require('node-cron');

const prisma = new PrismaClient();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

async function enviarNotificaciones() {
  try {
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);

    const config = await prisma.configuracion_notificaciones.findFirst();

    const diasAntes = config?.diasantes ?? 3;  
    const diasDespues = config?.diasdespues ?? 0; 

    const limiteProximo = new Date();
    limiteProximo.setDate(hoy.getDate() + diasAntes);

    const limiteVencido = new Date();
    limiteVencido.setDate(hoy.getDate() - diasDespues);

    console.log(`[INFO] Cargando facturas a notificar:`);
    console.log(`- Próximas a vencer: dentro de ${diasAntes} días`);
    console.log(`- Vencidas: hasta ${diasDespues} días de atraso`);


    const facturas = await prisma.pagos.findMany({
      where: {
        tipo_pago: 'factura',
        estado_pago: 'Pendiente',
        notificado: false,
        OR: [
          { plazo_pagar: { gte: hoy, lte: limiteProximo } }, 
          { AND: [
              { plazo_pagar: { lte: hoy } },               
              { plazo_pagar: { gte: limiteVencido } },     
            ]
          }
        ]
      },
    });

    if (!facturas.length) {
      console.log('[INFO] No hay facturas pendientes para notificar.');
      return;
    }

    const attachments = [];
    let vencidas = 0;
    let proximas = 0;

    for (const factura of facturas) {
      const pdfBuffer = await createFichaPagos(factura);
      attachments.push({
        filename: `factura_${factura.codigo}.pdf`,
        content: pdfBuffer,
      });

      if (factura.plazo_pagar < hoy) vencidas++;
      else proximas++;
    }

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: process.env.FINANZAS_EMAIL,
      subject: `Facturas vencidas y próximas a vencer (${facturas.length})`,
      text: `Estimado encargado, se adjuntan ${facturas.length} facturas.\n` +
            `- Vencidas: ${vencidas}\n` +
            `- Próximas a vencer: ${proximas}`,
      attachments,
    });

    const ids = facturas.map(f => f.id);
    await prisma.pagos.updateMany({
      where: { id: { in: ids } },
      data: { notificado: true },
    });

    console.log(`[INFO] Correo enviado con ${facturas.length} facturas (${vencidas} vencidas, ${proximas} próximas).`);
  } catch (error) {
    console.error('[ERROR] Enviando notificaciones:', error);
  } finally {
    await prisma.$disconnect();
  }
}


// Cron diario a las 9 AM
cron.schedule('0 9 * * *', () => {
  console.log('[INFO] Ejecutando cron de notificaciones...');
  enviarNotificaciones();
});

module.exports = { enviarNotificaciones };
