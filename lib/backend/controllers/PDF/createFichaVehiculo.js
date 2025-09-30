// controllers/pdf/createFichaVehiculo.js
const PDFDocument = require('pdfkit');

function formatDateNoTZ(d) {
  if (!d) return '-';
  // d puede ser Date o string
  const date = d instanceof Date ? d : new Date(d);
  if (isNaN(date)) return '-';

  // Usar componentes UTC para evitar desfase de zona horaria
  const yyyy = date.getUTCFullYear();
  const mm = String(date.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(date.getUTCDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`; // YYYY-MM-DD
}

async function createFichaVehiculo(vehiculo) {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ margin: 40 });
      const chunks = [];

      doc.on('data', (chunk) => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      // Título
      doc.fontSize(20).text('Ficha de Vehículo', { align: 'center' });
      doc.moveDown();

      // Datos del vehículo (usando exactamente los campos que me mostraste)
      doc.fontSize(12).text(`Patente: ${vehiculo.patente ?? '-'}`);
      doc.text(`Permiso de Circulación: ${vehiculo.permiso_circ ?? '-'}`);
      doc.text(`Revisión Técnica: ${formatDateNoTZ(vehiculo.revision_tecnica)}`);
      doc.text(`Revisión de Gases: ${formatDateNoTZ(vehiculo.revision_gases)}`);
      doc.text(`Última Mantención: ${formatDateNoTZ(vehiculo.ultima_mantencion)}`);
      doc.text(`Descripción Mantención: ${vehiculo.descripcion_mant ?? '-'}`);
      doc.text(`Capacidad (Kg): ${vehiculo.capacidad_kg ?? '-'}`);
      doc.text(`Neumáticos: ${vehiculo.neumaticos ?? '-'}`);
      doc.text(`Rueda de repuesto: ${typeof vehiculo.rueda_repuesto === 'boolean' ? (vehiculo.rueda_repuesto ? 'Sí' : 'No') : '-'}`);
      doc.text(`Observaciones: ${vehiculo.observaciones ?? '-'}`);
      doc.text(`Estado: ${vehiculo.estado ?? '-'}`);
      doc.text(`Próxima Mantención: ${formatDateNoTZ(vehiculo.proxima_mantencion)}`);

      doc.moveDown(1);
      doc.fontSize(10).fillColor('gray').text(`ID: ${vehiculo.id}`, { align: 'right' });

      doc.end();
    } catch (err) {
      reject(err);
    }
  });
}

module.exports = { createFichaVehiculo };


