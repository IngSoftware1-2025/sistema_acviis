// lib/backend/generarContrato.js
const PDFDocument = require('pdfkit');
const fs = require('fs');

function crearPDF(infoContrato, path) {
    return new Promise((resolve, reject) => {
        const doc = new PDFDocument();
        const stream = fs.createWriteStream(path);

        doc.pipe(stream);

        doc.fontSize(20).text('Contrato de Trabajo', { align: 'center' });
        doc.moveDown();
        doc.fontSize(12).text(`Nombre: ${infoContrato.nombre}`);
        doc.text(`Cargo: ${infoContrato.cargo}`);
        doc.text(`Fecha inicio: ${infoContrato.fechaInicio}`);
        doc.text(`Salario: ${infoContrato.salario}`);
        doc.end();

        stream.on('finish', () => resolve());
        stream.on('error', reject);
    });
}

module.exports = { crearPDF };
