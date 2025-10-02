const PDFDocument = require('pdfkit');

/**
 * Genera un PDF con los datos del proveedor.
 * @param {object} proveedor - Objeto proveedor con los campos esperados.
 * @returns {Promise<Buffer>} - Buffer del PDF generado.
 */
function createFichaProveedor(proveedor) {
    const doc = new PDFDocument();
    let buffers = [];

    doc.on('data', buffers.push.bind(buffers));

    doc.fontSize(20).text('Ficha del Proveedor', { align: 'center' });
    doc.moveDown();

    // doc.fontSize(12).text(`ID: ${proveedor.id || ''}`); // ID eliminado de la ficha
    doc.text(`RUT: ${proveedor.rut || ''}`);
    doc.text(`Dirección: ${proveedor.direccion || ''}`);
    doc.text(`Nombre del vendedor: ${proveedor.nombre_vendedor || ''}`);
    doc.text(`Producto o servicio: ${proveedor.producto_servicio || ''}`);
    doc.text(`Correo del vendedor: ${proveedor.correo_vendedor || ''}`);
    doc.text(`Teléfono del vendedor: ${proveedor.telefono_vendedor || ''}`);
    doc.text(`Crédito disponible: $${proveedor.credito_disponible != null ? proveedor.credito_disponible : ''}`);
    doc.text(`Fecha de registro: ${proveedor.fecha_registro ? new Date(proveedor.fecha_registro).toLocaleDateString() : ''}`);

    doc.end();

    return new Promise((resolve, reject) => {
        doc.on('end', () => {
            const pdfData = Buffer.concat(buffers);
            resolve(pdfData);
        });
        doc.on('error', reject);
    });
}

module.exports = createFichaProveedor;