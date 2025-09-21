const PDFDocument = require('pdfkit');

/**
 * Genera un PDF con los datos de pagos pendientes.
 * @param {object} pagos - Objeto pagos con los campos esperados.
 * @returns {Promise<Buffer>} - Buffer del PDF generado.
 */
function createFichaPagos(pagos) {
    const doc = new PDFDocument();
    let buffers = [];

    doc.on('data', buffers.push.bind(buffers));

    // Determina el título según el tipo de documento
    let titulo = 'Ficha Pagos pendientes';
    // Si tiene un campo que lo identifique como factura
    if (pagos.esFactura === true || pagos.tipo === 'factura' || pagos.tipo_pago === 'factura') {
        titulo = 'Ficha de la Factura';
    }
    doc.fontSize(20).text(titulo, { align: 'center' });
    doc.moveDown();

    doc.fontSize(12).text(`ID: ${pagos.id || ''}`);
    doc.text(`Mandante: ${pagos.nombre_mandante || ''}`);
    doc.text(`RUT: ${pagos.rut_mandante || ''}`);
    doc.text(`Dirección: ${pagos.direccion_comercial || ''}`);
    doc.text(`Servicio: ${pagos.servicio_ofrecido || ''}`);
    doc.text(`Código de Factura: ${pagos.codigo || ''}`);
    doc.text(`Valor: ${pagos.valor || ''}`);
    doc.text(`Plazo a pagar: ${pagos.plazo_pagar ? new Date(pagos.plazo_pagar).toLocaleDateString() : ''}`);
    doc.text(`Estado de la Factura: ${pagos.estado_pago || ''}`);
    doc.text(`Tipo de Pago: ${pagos.tipo_pago || ''}`);
    doc.text(`Sentido: ${pagos.sentido === true ? 'Pago pendiente realizado para una empresa' : 'Pago pendiente mandado para la empresa'}`);

    doc.end();

    return new Promise((resolve, reject) => {
        doc.on('end', () => {
            const pdfData = Buffer.concat(buffers);
            resolve(pdfData);
        });
        doc.on('error', reject);
    });
}

module.exports = createFichaPagos;
