const { create } = require('domain');
const PDFDocument = require('pdfkit');

function createContract(body) {
    const doc = new PDFDocument();
    let buffers = [];

    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {});

    doc.fontSize(20).text('Contrato', { align: 'center' });
    doc.moveDown();

    doc.fontSize(12).text(`Nombre: ${body.nombre_completo || 'Nombre_no_proporcionado'}`);
    doc.text(`Estado civil: ${body.estado_civil || 'Estado_civil_no_proporcionado'}`);
    doc.text(`Rut: ${body.rut || 'Rut_no_proporcionado'}`);
    doc.text(`Fecha de nacimiento: ${body.fecha_de_nacimiento || 'Fecha_de_nacimiento_no_proporcionada'}`);
    doc.text(`Direccion: ${body.direccion || 'Direccion_no_proporcionado'}`);
    doc.text(`Correo electronico: ${body.correo_electronico || 'Correo_electronico_no_proporcionado'}`);
    doc.text(`Sistema de salud: ${body.sistema_de_salud || 'Sistema_de_salud_no_proporcionado'}`);
    doc.text(`Prevision / AFP: ${body.prevision_afp || 'Prevision/afp_no_proporcionado'}`);
    doc.text(`Obra en la que trabajaran: ${body.obra_en_la_que_trabajaran || 'Obra_en_la_que_trabajaran_no_proporcionado'}`);
    doc.text(`Rol que asume en la obra: ${body.rol_que_asume_en_la_obra || 'Rol_que_asume_en_la_obra_no_proporcionado'}`);
    doc.text(`Plazo de contrato: ${body.plazo_de_contrato || 'Plazo_de_contrato_no_proporcionado'}`);
    doc.text(`Estado: ${body.estado || 'Estado_no_proporcionado'}`);
    doc.text(`Comentario adicional acerca del trabajador: ${body.comentario_adicional_acerca_del_trabajador || 'Comentario_adicional_acerca_del_trabajador_no_proporcionado'}`)
    doc.text(`Fecha: ${body.fecha_de_contratacion || 'Fecha_no_proporcionada'}`);
    
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