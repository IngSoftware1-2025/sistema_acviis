const PDFDocument = require('pdfkit');

async function createFichaHerramienta(h) {
  const doc = new PDFDocument();
  const buffers = [];

  doc.on('data', buffers.push.bind(buffers));

  // Función auxiliar para formatear fechas en UTC
  const formatDate = (date) => {
    if (!date) return '-';
    const d = new Date(date);
    return `${d.getUTCDate().toString().padStart(2, '0')}/${
      (d.getUTCMonth() + 1).toString().padStart(2, '0')
    }/${d.getUTCFullYear()}`;
  };

  doc.fontSize(18).text('Ficha de Herramienta', { underline: true });
  doc.moveDown();

  doc.fontSize(12).text(`Tipo: ${h.tipo}`);
  doc.text(`Estado: ${h.estado}`);
  doc.text(`Garantía: ${formatDate(h.garantia)}`);
  doc.text(`Cantidad: ${h.cantidad}`);
  doc.text(`Obra Asignada: ${h.obra_asig ?? '-'}`);
  doc.text(`Asignación Inicio: ${formatDate(h.asig_inicio)}`);
  doc.text(`Asignación Fin: ${formatDate(h.asig_fin)}`);

  doc.end();

  return new Promise((resolve, reject) => {
    doc.on('end', () => resolve(Buffer.concat(buffers)));
    doc.on('error', reject);
  });
}

module.exports = { createFichaHerramienta };

