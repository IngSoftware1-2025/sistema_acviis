const PDFDocument = require('pdfkit');

async function createItemizadoGastoPDF(data) {
  const { nombreObra, items = [] } = data;

  return new Promise((resolve) => {
    const doc = new PDFDocument({ margin: 50 });
    const buffers = [];

    // HEADER
    doc
      .fontSize(18)
      .font('Helvetica-Bold')
      .text(`Itemizado - ${nombreObra}`, { align: 'center' })
      .moveDown(2);

    // Agrego columna SALDO y ESTADO
    const headers = ['Ítem', 'Cant.', 'Valor Estimado ($)', 'Gasto Actual ($)', 'Saldo ($)', 'Estado'];
    const colWidths = [150, 60, 100, 100, 80, 60];
    let y = doc.y;

    doc.rect(50, y - 4, 550, 22).fill('#e6e6e6');
    doc.fillColor('#000').font('Helvetica-Bold').fontSize(10);

    let x = 50;
    headers.forEach((h, i) => {
      doc.text(h, x + 4, y, { width: colWidths[i] });
      x += colWidths[i];
    });

    y += 22;
    doc.moveTo(50, y).lineTo(600, y).stroke();

    // BODY
    doc.font('Helvetica').fontSize(10);
    let totalEstimado = 0, totalGastado = 0;
    let hayExceso = false;

    items.forEach((it, idx) => {
      const rowY = y + idx * 22;
      const saldo = (it.valorTotal || 0) - (it.gastoActual || 0);
      const estado = saldo < 0 ? 'EXCESO' : 'OK';
      if (estado === 'EXCESO') hayExceso = true;

      if (idx % 2 === 0) {
        doc.rect(50, rowY - 4, 550, 22).fill('#f9f9f9');
      }

      totalEstimado += it.valorTotal || 0;
      totalGastado += it.gastoActual || 0;

      const row = [
        it.nombre,
        it.cantidad?.toString(),
        `$${(it.valorTotal || 0).toLocaleString('es-CL')}`,
        `$${(it.gastoActual || 0).toLocaleString('es-CL')}`,
        `$${(saldo).toLocaleString('es-CL')}`,
        estado
      ];

      let cx = 50;
      row.forEach((t, i) => {
        if (i === 4 && saldo < 0) {
          doc.fillColor('red'); // SOLO saldo en rojo
        } else if (i === 5 && estado === 'EXCESO') {
          doc.fillColor('red');
        } else {
          doc.fillColor('#000');
        }
        doc.text(t, cx + 4, rowY, { width: colWidths[i] });
        cx += colWidths[i];
      });

      doc.moveTo(50, rowY + 20).lineTo(600, rowY + 20).stroke();
    });

    y += items.length * 22 + 30;
    doc.font('Helvetica-Bold').fontSize(12);
    doc.fillColor('#000').text(`Total Estimado: $${totalEstimado.toLocaleString('es-CL')}`, 50, y);
    doc.text(`Gasto Actual: $${totalGastado.toLocaleString('es-CL')}`, 300, y);

    // Mensaje si hay exceso (C)
    if (hayExceso) {
      doc.moveDown(2);
      doc.fillColor('red').fontSize(12).text('Existen ítems con exceso de gasto.', { align: 'left' });
    }

    doc.end();
    doc.on('data', b => buffers.push(b));
    doc.on('end', () => resolve(Buffer.concat(buffers)));
  });
}

module.exports = createItemizadoGastoPDF;
