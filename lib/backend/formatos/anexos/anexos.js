const { create } = require('domain');
const PDFDocument = require('pdfkit');
const { reajuste_de_sueldo } = require('../anexos/reajuste_de_sueldo')
const { pacto_horas_extraordinarias } = require('../anexos/pacto_horas_extraordinarias')
const { maestro_a_cargo } = require('../anexos/maestro_a_cargo');
const { salida_de_la_obra } = require('../anexos/salida_de_la_obra');
const { traslado } = require('../anexos/traslado');

// Esta funcion decidira el anexo que se creara en cuestion
function createAnexo(tipoAnexo, parametros){
    switch (tipoAnexo){ 
        case "Anexo Reajuste de Sueldo":
            return reajuste_de_sueldo(parametros);
            
        case "Anexo Maestro a cargo":
            return maestro_a_cargo(parametros);

        case "Formulario Pacto Horas extraordinarias":
            return pacto_horas_extraordinarias(parametros);

        case "Anexo Salida de la obra":
            return salida_de_la_obra(parametros);
        
        case "Anexo Traslado":
            return traslado(parametros);

/* Anexos no entregados (formato)
        case "Anexo Jornada laboral":
            break;

        case "Anexo Renovacion":
            break;
*/       
        default:
            console.log("Anexo no existente");
            return createAnexoTemporal(parametros);
    }
}


function createAnexoTemporal(body) {
    console.log("Body: ", body)
    const doc = new PDFDocument();
    let buffers = [];
    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {});

    doc.fontSize(20).text(`Anexo ${body.tipo} (temporal)`, { align: 'center' });
    doc.moveDown();

    doc.fontSize(12).text(`Nombre: ${body.nombre_completo || 'Nombre_no_proporcionado'}`);
    doc.text(`Estado civil: ${body.estado_civil || 'Estado_civil_no_proporcionado'}`);
    doc.text(`Rut: ${body.rut || 'Rut_no_proporcionado'}`);
    doc.text(`Fecha de nacimiento: ${body.fecha_de_nacimiento || 'Fecha_de_nacimiento_no_proporcionada'}`);
    doc.text(`Direccion: ${body.direccion || 'Direccion_no_proporcionado'}`);
    doc.text(`Correo electronico: ${body.correo_electronico || 'Correo_electronico_no_proporcionado'}`);
    doc.text(`Sistema de salud: ${body.sistema_de_salud || 'Sistema_de_salud_no_proporcionado'}`);
    doc.text(`Prevision / AFP: ${body.prevision_afp || 'Prevision/afp_no_proporcionado'}`);
    doc.text(`Obra en la que trabaja: ${body.obra_en_la_que_trabaja || 'Obra_en_la_que_trabajara_no_proporcionado'}`);
    doc.text(`Rol que asume en la obra: ${body.rol_que_asume_en_la_obra || 'Rol_que_asume_en_la_obra_no_proporcionado'}`);
    doc.text(`Estado: ${body.estado || 'Estado_no_proporcionado'}`);
    //doc.text(`Fecha: ${body.fecha_de_creacion || 'Fecha_no_proporcionada'}`);

    
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
};