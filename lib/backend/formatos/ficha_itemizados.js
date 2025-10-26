const PDFDocument = require('pdfkit');

/**
 * Genera un PDF del itemizado con formato:
 * Ítem | Cantidad | Valor unitario | Valor total | Gasto actual
 * @param {Object} data
 * @param {string} data.nombreObra
 * @param {Array}  data.items - [{ nombre, cantidad, valorUnitario, valorTotal, gastoActual }]
 * @returns {Promise<Buffer>}
 */
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

    // TABLE HEADER
    const headers = ['Ítem', 'Cantidad', 'Valor Estimado ($)', 'Gasto Actual ($)'];
    const colWidths = [180, 80, 120, 120];
    let y = doc.y;

    doc.rect(50, y - 4, 500, 22).fill('#e6e6e6');
    doc.fillColor('#000').font('Helvetica-Bold').fontSize(10);

    let x = 50;
    headers.forEach((h,i)=>{
      doc.text(h, x+4, y, { width: colWidths[i] });
      x+=colWidths[i];
    });

    y += 22;
    doc.moveTo(50,y).lineTo(550,y).stroke();

    // BODY
    doc.font('Helvetica').fontSize(10);
    let totalEstimado=0, totalGastado=0;

    items.forEach((it,idx)=>{
      const rowY = y + idx*22;

      if(idx % 2 === 0){
        doc.rect(50,rowY-4,500,22).fill('#f9f9f9');
      }

      totalEstimado+= it.valorTotal||0;
      totalGastado+= it.gastoActual||0;

      const row = [
        it.nombre,
        it.cantidad?.toString(),
        `$${(it.valorTotal||0).toLocaleString('es-CL')}`,
        `$${(it.gastoActual||0).toLocaleString('es-CL')}`
      ];

      let cx = 50;
      row.forEach((t,i)=>{
        doc.fillColor('#000').text(t, cx+4,rowY,{width:colWidths[i]});
        cx+=colWidths[i];
      });

      doc.moveTo(50,rowY+20).lineTo(550,rowY+20).stroke();
    });

    y += items.length * 22 + 30;
    doc.font('Helvetica-Bold').fontSize(12);
    doc.text(`Total Estimado: $${totalEstimado.toLocaleString('es-CL')}`, 50, y);
    doc.text(`Gasto Actual: $${totalGastado.toLocaleString('es-CL')}`, 300, y);

    doc.end();
    doc.on('data',b=>buffers.push(b));
    doc.on('end',()=>resolve(Buffer.concat(buffers)));
  });
}


module.exports = createItemizadoGastoPDF;
