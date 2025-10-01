const { create } = require('domain');
const PDFDocument = require('pdfkit');
const { reajuste_de_sueldo } = require('../anexos/reajuste_de_sueldo')

// Esta funcion decidira el anexo que se creara en cuestion
function createAnexo(tipoAnexo, parametros){
    switch (tipoAnexo){ 
        case "Anexo Reajuste de Sueldo":
            console.log("Llego al createAnexo")
            return reajuste_de_sueldo(parametros);

        case "Anexo Jornada laboral":
            
            break;
        
        case "Anexo Maestro a cargo":
            break;

        case "Anexo Renovacion":
            break;

        case "Anexo Salida de la obra":
            break;

        case "Anexo Traslado":
            break;

        case "Formulario Pacto Horas extraordinarias":
            break;
        
        default:
            console.log("Anexo no existente");
            return false
    }
}


function createAnexoTemporal(body) {
    const doc = new PDFDocument();
    let buffers = [];

    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {});

    doc.fontSize(20).text('Anexo', { align: 'center' });
    doc.moveDown();

    doc.fontSize(12).text(`Nombre: ${body.nombre_completo || 'Nombre_no_proporcionado'}`);
    doc.text(`Estado civil: ${body.estado_civil || 'Estado_civil_no_proporcionado'}`);
    doc.text(`Rut: ${body.rut || 'Rut_no_proporcionado'}`);
    doc.text(`Fecha de nacimiento: ${body.fecha_de_nacimiento || 'Fecha_de_nacimiento_no_proporcionada'}`);
    doc.text(`Direccion: ${body.direccion || 'Direccion_no_proporcionado'}`);
    doc.text(`Correo electronico: ${body.correo_electronico || 'Correo_electronico_no_proporcionado'}`);
    doc.text(`Sistema de salud: ${body.sistema_de_salud || 'Sistema_de_salud_no_proporcionado'}`);
    doc.text(`Prevision / AFP: ${body.prevision_afp || 'Prevision/afp_no_proporcionado'}`);
    doc.text(`Obra en la que trabajara: ${body.obra_en_la_que_trabajara || 'Obra_en_la_que_trabajara_no_proporcionado'}`);
    doc.text(`Rol que asume en la obra: ${body.rol_que_asume_en_la_obra || 'Rol_que_asume_en_la_obra_no_proporcionado'}`);
    doc.text(`Estado: ${body.estado || 'Estado_no_proporcionado'}`);
    //doc.text(`Fecha: ${body.fecha_de_creacion || 'Fecha_no_proporcionada'}`);
    doc.text(`Id de contrato: ${body.id_contrato || 'id_contrato_no_proporcionada'}`);
    doc.text(`Tipo de anexo: ${body.tipo || 'tipo_de_anexo_no_proporcionado'}`);
    doc.text(`Duracion: ${body.duracion || 'duracion_no_proporcionada'}`);
    doc.text(`Parametros: ${body.parametros || 'parametros_no_proporcionados'}`);
    doc.text(`Comentario: ${body.comentario || 'comentario_no_proporcionado'}`);
    
    doc.end();

    return new Promise((resolve, reject) => {
        doc.on('end', () => {
            const pdfData = Buffer.concat(buffers);
            resolve(pdfData);
        });
        doc.on('error', reject);
    });
}

module.exports = {
    createAnexo,
    createAnexoTemporal
};