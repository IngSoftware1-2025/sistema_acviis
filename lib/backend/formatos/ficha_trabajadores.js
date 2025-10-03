const PDFDocument = require('pdfkit');

/**
 * Genera un PDF con los datos del trabajador.
 * @param {object} trabajador - Objeto trabajador con los campos esperados.
 * @returns {Promise<Buffer>} - Buffer del PDF generado.
 */
function createFichaTrabajador(trabajador) {
    const doc = new PDFDocument();
    let buffers = [];

    doc.on('data', buffers.push.bind(buffers));

    doc.fontSize(20).text('Ficha del Trabajador', { align: 'center' });
    doc.moveDown();

    doc.fontSize(12).text(`ID: ${trabajador.id || ''}`);
    doc.text(`Nombre: ${trabajador.nombre_completo || ''}`);
    doc.text(`Estado Civil: ${trabajador.estado_civil || ''}`);
    doc.text(`RUT: ${trabajador.rut || ''}`);
    doc.text(`Fecha de Nacimiento: ${trabajador.fecha_de_nacimiento ? new Date(trabajador.fecha_de_nacimiento).toISOString().split('T')[0] : ''}`);
    doc.text(`Dirección: ${trabajador.direccion || ''}`);
    doc.text(`Correo Electrónico: ${trabajador.correo_electronico || ''}`);
    doc.text(`Sistema de Salud: ${trabajador.sistema_de_salud || ''}`);
    doc.text(`Previsión AFP: ${trabajador.prevision_afp || ''}`);
    doc.text(`Obra en la que trabaja: ${trabajador.obra_en_la_que_trabaja || ''}`);
    doc.text(`Rol que asume en la obra: ${trabajador.rol_que_asume_en_la_obra || ''}`);
    doc.text(`Estado en la empresa: ${trabajador.estado || ''}`);

    doc.end();

    return new Promise((resolve, reject) => {
        doc.on('end', () => {
            const pdfData = Buffer.concat(buffers);
            resolve(pdfData);
        });
        doc.on('error', reject);
    });
}

module.exports = createFichaTrabajador;
