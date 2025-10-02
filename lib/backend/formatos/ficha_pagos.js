/**
 * Genera un PDF con los datos de pagos pendientes, facturas o caja chica.
 * @param {object} pagos - Objeto pagos con los campos esperados.
 * @returns {Promise<Buffer>} - Buffer del PDF generado.
 */
const PDFDocument = require('pdfkit');
function createFichaPagos(pagos) {
    const doc = new PDFDocument();
    let buffers = [];

    doc.on('data', buffers.push.bind(buffers));

    // Determina el título según el tipo de documento
    let titulo = 'Ficha Pagos pendientes';
    if (pagos.esFactura === true || pagos.tipo === 'factura' || pagos.tipo_pago === 'factura') {
        titulo = 'Ficha de la Factura';
    } else if (pagos.tipo_pago === 'caja_chica') {
        titulo = 'Ficha de Factura Caja Chica';
    }

    // Encabezado del documento
    doc.fontSize(20).text(titulo, { align: 'center' });
    doc.moveDown();

    // Información específica para caja chica
    if (pagos.tipo_pago === 'caja_chica') {
        doc.fontSize(14).text('REGISTRO DE GASTO CAJA CHICA', { align: 'center' });
        doc.moveDown();
        
        // Campos principales para caja chica
        doc.fontSize(12).text(`Número de Factura: ${pagos.codigo || 'N/A'}`);
        doc.text(`Concepto del Gasto: ${pagos.servicio_ofrecido || 'N/A'}`);
        doc.text(`Monto: $${pagos.valor || '0'}`);
        doc.text(`Fecha: ${pagos.plazo_pagar ? new Date(pagos.plazo_pagar).toLocaleDateString() : 'N/A'}`);
        doc.text(`Estado: ${pagos.estado_pago || 'N/A'}`);
        
        if (pagos.rut_mandante && pagos.rut_mandante !== 'N/A') {
            doc.text(`RUT Proveedor: ${pagos.rut_mandante}`);
        }
        
        doc.moveDown();
        doc.text(`ID Sistema: ${pagos.id || ''}`);
        doc.text(`Tipo: Caja Chica`);
        
        // Información adicional
        doc.moveDown();
        doc.fontSize(10).text('Este registro corresponde a un gasto de caja chica de la empresa.', { align: 'center', italics: true });
        
    } else {
        // Formato original para facturas normales y otros pagos
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
    }

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
