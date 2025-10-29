const nodemailer = require('nodemailer');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function verificarCajasChicas() {
  console.log('[INFO] Verificando estado de cajas chicas...');

  // 1. Configurar el transportador de nodemailer con las credenciales del .env
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  try {
    // 2. Buscar todas las cajas chicas activas
    const cajasChicas = await prisma.obra_finanza.findMany({
      where: {
        tipo: 'caja chica',
        estado: 'activa',
      },
      include: {
        obra: {
          select: {
            nombre: true,
            responsable_email: true,
          }
        }
      }
    });

    if (cajasChicas.length === 0) {
      console.log('[INFO] No hay cajas chicas activas para verificar.');
      return;
    }

    console.log(`[INFO] Se encontraron ${cajasChicas.length} cajas chicas activas.`);

    // 3. Iterar sobre cada caja chica y verificar el porcentaje de uso
    for (const caja of cajasChicas) {
      const detalles = caja.detalles || {};
      const montoAsignado = detalles.montoTotalAsignado || 0;
      const montoUtilizado = detalles.montoTotalUtilizado || 0;
      const notificacionEnviada = detalles.notificacion80Enviada || false;

      // Calcular porcentaje de utilización
      const porcentajeUtilizado = montoAsignado > 0 
        ? (montoUtilizado / montoAsignado) * 100 
        : 0;

      // 4. Si alcanza el 80% o más y no se ha notificado
      if (porcentajeUtilizado >= 80 && !notificacionEnviada) {
        // Verificar que la obra tenga responsable con email
        if (!caja.obra.responsable_email || caja.obra.responsable_email === '') {
          console.log(`[WARN] La caja chica ${caja.id} de la obra "${caja.obra.nombre}" no tiene responsable con email.`);
          continue;
        }

        // Formatear montos para el correo
        const formatoMoneda = (monto) => {
          return `$${monto.toLocaleString('es-CL', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
        };

        const montoDisponible = montoAsignado - montoUtilizado;
        const montoImpago = detalles.montoUtilizadoImpago || 0;

        // Determinar nivel de alerta
        let nivelAlerta = 'ADVERTENCIA';
        let colorAlerta = '#FFA500'; // Naranja
        if (porcentajeUtilizado >= 95) {
          nivelAlerta = 'CRÍTICO';
          colorAlerta = '#FF0000'; // Rojo
        } else if (porcentajeUtilizado >= 90) {
          nivelAlerta = 'ALTO';
          colorAlerta = '#FF6600'; // Naranja oscuro
        }

        // 5. Preparar y enviar el correo
        const mailOptions = {
          from: `"Sistema Acviis - Finanzas" <${process.env.EMAIL_USER}>`,
          to: caja.obra.responsable_email,
          subject: `⚠️ ${nivelAlerta}: Caja Chica al ${porcentajeUtilizado.toFixed(1)}% - "${caja.obra.nombre}"`,
          html: `
            <!DOCTYPE html>
            <html>
            <head>
              <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: ${colorAlerta}; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
                .content { background-color: #f9f9f9; padding: 20px; border: 1px solid #ddd; }
                .alert-box { background-color: #fff3cd; border-left: 4px solid ${colorAlerta}; padding: 15px; margin: 15px 0; }
                .info-box { background-color: white; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 4px; }
                .info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }
                .info-label { font-weight: bold; color: #666; }
                .info-value { color: #333; }
                .progress-bar { width: 100%; height: 30px; background-color: #e0e0e0; border-radius: 15px; overflow: hidden; margin: 15px 0; }
                .progress-fill { height: 100%; background-color: ${colorAlerta}; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; }
                .warning-icon { font-size: 48px; text-align: center; margin: 10px 0; }
                .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
                .highlight { color: ${colorAlerta}; font-weight: bold; font-size: 1.2em; }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="header">
                  <div class="warning-icon">⚠️</div>
                  <h1 style="margin: 0; text-align: center;">ALERTA DE CAJA CHICA</h1>
                  <p style="margin: 10px 0 0 0; text-align: center; font-size: 18px;">Nivel: ${nivelAlerta}</p>
                </div>
                
                <div class="content">
                  <div class="alert-box">
                    <h2 style="margin-top: 0; color: ${colorAlerta};">
                      La caja chica ha alcanzado el <span class="highlight">${porcentajeUtilizado.toFixed(1)}%</span> de utilización
                    </h2>
                    <p>Se ha detectado que el uso de la caja chica está próximo al límite asignado. Es necesario tomar acción inmediata.</p>
                  </div>

                  <div class="info-box">
                    <h3 style="margin-top: 0;">Información de la Obra</h3>
                    <div class="info-row">
                      <span class="info-label">Obra:</span>
                      <span class="info-value">${caja.obra.nombre}</span>
                    </div>
                    <div class="info-row">
                      <span class="info-label">Propósito:</span>
                      <span class="info-value">${caja.proposito}</span>
                    </div>
                  </div>

                  <div class="info-box">
                    <h3 style="margin-top: 0;">Resumen Financiero</h3>
                    <div class="progress-bar">
                      <div class="progress-fill" style="width: ${Math.min(porcentajeUtilizado, 100)}%;">
                        ${porcentajeUtilizado.toFixed(1)}%
                      </div>
                    </div>
                    
                    <div class="info-row">
                      <span class="info-label">Monto Total Asignado:</span>
                      <span class="info-value">${formatoMoneda(montoAsignado)}</span>
                    </div>
                    <div class="info-row">
                      <span class="info-label">Monto Utilizado:</span>
                      <span class="info-value" style="color: ${colorAlerta};">${formatoMoneda(montoUtilizado)}</span>
                    </div>
                    <div class="info-row">
                      <span class="info-label">Monto Disponible:</span>
                      <span class="info-value" style="font-weight: bold;">${formatoMoneda(montoDisponible)}</span>
                    </div>
                    ${montoImpago > 0 ? `
                    <div class="info-row" style="background-color: #fff3cd;">
                      <span class="info-label">⚠️ Monto Sin Pagar:</span>
                      <span class="info-value" style="color: #d9534f; font-weight: bold;">${formatoMoneda(montoImpago)}</span>
                    </div>
                    ` : ''}
                  </div>

                  <div class="alert-box">
                    <h3 style="margin-top: 0;">Acciones Recomendadas:</h3>
                    <ul>
                      <li>Revisar los gastos realizados hasta el momento</li>
                      <li>Evaluar la necesidad de solicitar ampliación del monto</li>
                      <li>Priorizar únicamente gastos esenciales</li>
                      ${montoImpago > 0 ? '<li><strong>Resolver pagos pendientes para liberar fondos</strong></li>' : ''}
                      <li>Considerar el cierre de la caja chica si no se requieren más fondos</li>
                    </ul>
                  </div>
                </div>

                <div class="footer">
                  <p>Este es un correo automático generado por el Sistema de Gestión Acviis.</p>
                  <p>Para más información, ingrese al sistema y revise la sección de Gestión Financiera de la obra.</p>
                  <p style="margin-top: 15px; font-size: 10px; color: #999;">
                    Fecha de envío: ${new Date().toLocaleString('es-CL', { timeZone: 'America/Santiago' })}
                  </p>
                </div>
              </div>
            </body>
            </html>
          `,
        };

        // 6. Enviar el correo y actualizar la base de datos
        await transporter.sendMail(mailOptions);
        console.log(`[SUCCESS] Correo de alerta enviado a ${caja.obra.responsable_email} para la caja chica ID: ${caja.id} (${porcentajeUtilizado.toFixed(1)}%)`);

        // Marcar la caja como notificada
        await prisma.obra_finanza.update({
          where: { id: caja.id },
          data: {
            detalles: {
              ...detalles,
              notificacion80Enviada: true,
              fechaNotificacion80: new Date().toISOString(),
            },
          },
        });
        console.log(`[INFO] Caja chica ${caja.id} marcada como notificada.`);
      } else if (porcentajeUtilizado < 80 && notificacionEnviada) {
        // Si el porcentaje baja del 80% y ya se había notificado, resetear la notificación
        // Esto permite que se vuelva a notificar si sube nuevamente
        console.log(`[INFO] Reseteando notificación para caja chica ${caja.id} (uso actual: ${porcentajeUtilizado.toFixed(1)}%)`);
        await prisma.obra_finanza.update({
          where: { id: caja.id },
          data: {
            detalles: {
              ...detalles,
              notificacion80Enviada: false,
              fechaNotificacion80: null,
            },
          },
        });
      }
    }

    console.log('[INFO] Verificación de cajas chicas completada.');
  } catch (error) {
    console.error('[ERROR] Ocurrió un error en el proceso de verificación de cajas chicas:', error);
  } finally {
    await prisma.$disconnect();
  }
}

module.exports = { verificarCajasChicas };