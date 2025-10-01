const { create } = require('domain');
const PDFDocument = require('pdfkit');

function reajuste_de_sueldo(parametros){
    console.log("Llego al reajuste de sueldo");
    console.log("Parametros: ", parametros);
    const doc = new PDFDocument({ margin: 50 });
    let buffers = []

    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {});

    // Logo (arriba derecha)
    //doc.image("logo.png", 450, 30, { width: 100 });

    // Título centrado
    doc.font("Times-Bold")
    .fontSize(14)
    .text("ANEXO CONTRATO DE TRABAJO", { align: "center" });

    doc.moveDown();

    // Cuerpo del texto
    const fecha = new Date();
    const dia = fecha.getDate();
    const mes = fecha.toLocaleString('es-ES', { month: 'long' });
    const año = fecha.getFullYear();

            doc.font("Times-Roman").fontSize(12)
                .text("En Santiago, ", { continued: true })
                .font("Times-Bold").text(`${dia}`, { continued: true })
                .font("Times-Roman").text(" de ", { continued: true })
                .font("Times-Bold").text(`${mes}`, { continued: true })
                .font("Times-Roman").text(" de ", { continued: true })
                .font("Times-Bold").text(`${año}`, { continued: true })
                .font("Times-Roman").text(", entre la empresa A y C Montajes e Instalaciones SpA., RUT 77.134.913-7, representada por Patricio Andrés Lara Lara, RUN 17.610.898-3 en adelante “El Empleador” con domicilio comercial en Pedro León Ugalde N°1153, comuna de Santiago y don ", { continued: true })
                .font("Times-Bold").text(`${parametros.nombre || '__________'}`, { continued: true })
                .font("Times-Roman").text(", RUN ", { continued: true })
                .font("Times-Bold").text(`${parametros.rut || '__________'}`, { continued: true })
                .font("Times-Roman").text(" en adelante “El Trabajador” se ha convenido la celebración del siguiente anexo de Contrato de Trabajo.", { align: "justify", width: 480 });
    doc.moveDown();

    // Cláusula destacada
    doc.font("Times-Bold").text("CLÁUSULA PRIMERA: ", { continued: true });
    doc.font("Times-Roman").text(
    "Que se modifica la CUARTO del contrato de trabajo vigente, donde se especifica que:"
    );

    doc.moveDown();

    // Reajuste sueldo
        doc.fillColor("black")
            .font("Times-Roman").text("Para todos los efectos legales se deja constancia del nuevo reajuste al sueldo por el monto de ", { continued: true })
            .font("Times-Bold").text(`${parametros.nuevo_sueldo || '________'}.-`, { continued: true })
            .font("Times-Roman").text(" desglosado de la siguiente manera:", { align: "justify", width: 480 });

    // Detalles con alineación
    doc.moveDown();
    doc.text("Asignación Colación", { continued: true, width: 200 });
    doc.font("Times-Bold").text(` ${parametros.asignacion_colacion || 0}.-`);
    doc.font("Times-Roman");

    doc.text("Asignación Movilización", { continued: true, width: 200 });
    doc.font("Times-Bold").text(` ${parametros.asignacion_movilizacion || 0}.-`);
    doc.font("Times-Roman");

    doc.moveDown();

    const [diaDesde, mesDesde, yearDesde] = (parametros.fecha_desde || '').split('-');
    doc.font("Times-Roman").text("A contar del ", { continued: true });
    doc.font("Times-Bold").text(`${diaDesde || ''}`, { continued: true });
    doc.font("Times-Roman").text(" de ", { continued: true });
    doc.font("Times-Bold").text(`${mesDesde || ''}`, { continued: true });
    doc.font("Times-Roman").text(" de ", { continued: true });
    doc.font("Times-Bold").text(`${yearDesde || ''}`, { continued: false });

    doc.moveDown();
    doc.font("Times-Bold").text("CLÁUSULA SEGUNDA: ", { continued: true });
    doc.font("Times-Roman").text(
    "Se firma en cuatro copias de idéntico tenor, declarando El Trabajador haber recibido uno de dichos ejemplares."
    );

    doc.moveDown().moveDown().moveDown();

    // Firmas
    doc.text("---------------------------------------------", 50, 600);
    doc.text("FIRMA TRABAJADOR", 15, 615, { width: 250, align: "center" });
    doc.text("NOMBRE TRABAJADOR", 15, 630, { width: 250, align: "center" });
    doc.text("RUN TRABAJADOR", 15, 645, { width: 250, align: "center" });

    doc.text("---------------------------------------------", 350, 600);
    doc.text("FIRMA EMPLEADOR", 320, 615, { width: 250, align: "center" });
    doc.text("ACVIIS SpA.", 320, 630, { width: 250, align: "center" });
    doc.text("77.134.913-7", 320, 645, { width: 250, align: "center" });

    // Finalizar
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
    reajuste_de_sueldo
}