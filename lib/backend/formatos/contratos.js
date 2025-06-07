const { create } = require('domain');
const PDFDocument = require('pdfkit');

function createContract(body) {
    const doc = new PDFDocument();
    let buffers = [];

    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {});

    doc.fontSize(20).text('Contrato', { align: 'center' });
    doc.moveDown();

    doc.fontSize(12).text(`Nombre: ${body.nombre || 'Nombr_No_incluido'}`);
    doc.text(`Fecha: ${body.fecha || 'Fecha_No_Incluida'}`);
    doc.text(`Descripción: ${body.descripcion || 'Descripcion_No_Incluida'}`);
    doc.moveDown();

    doc.text('Términos y condiciones:', { underline: true });
    doc.text(body.terminos || 'Terminos_No_Incluidos');

    doc.end();

    return new Promise((resolve, reject) => {
        doc.on('end', () => {
            const pdfData = Buffer.concat(buffers);
            resolve(pdfData);
        });
        doc.on('error', reject);
    });
}

module.exports = createContract;