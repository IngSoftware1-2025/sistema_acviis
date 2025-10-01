const PDFDocument = require('pdfkit');

function pacto_horas_extraordinarias(parametros) {
    //console.log("Parametros: ", parametros);
    const doc = new PDFDocument({ margin: 50 });
    let buffers = [];
    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {});

    // Logo (opcional)
    // doc.image("logo.png", 400, 20, { width: 100 });

    doc.font("Times-Bold").fontSize(14).text("FORMULARIO PACTO HORAS EXTRAORDINARIAS", { align: "center" });
    doc.moveDown();

    // Encabezado
    doc.font("Times-Roman").fontSize(12)
      .text("En Santiago, ", { continued: true })
      .font("Times-Bold").text(parametros.fecha || "____", { continued: true })
      .font("Times-Roman").text(", entre A y C Instalaciones y Montajes Eléctricos SpA., RUT 77.134.913-7, representada por Don Patricio Andrés Lara Lara, RUN 17.610.898-3 y el trabajador: ", { continued: true })
      .font("Times-Bold").text(parametros.nombre || "________", { continued: true })
      .font("Times-Roman").text(", RUN ", { continued: true })
      .font("Times-Bold").text(parametros.rut || "________", { continued: true })
      .font("Times-Roman").text(", domiciliado en ", { continued: true })
      .font("Times-Bold").text(parametros.direccion || "________", { continued: true })
      .font("Times-Roman").text(", Comuna de ", { continued: true })
      .font("Times-Bold").text(parametros.comuna || "________", { continued: true })
      .font("Times-Roman").text(" vienen a formular el siguiente pacto:", { continued: false });
    doc.moveDown();

    const [diaDesde, mesDesde, yearDesde] = (parametros.fecha_desde || '').split('-');
    const [diaHasta, mesHasta, yearHasta] = (parametros.fecha_hasta || '').split('-');
    // Cláusulas
    doc.font("Times-Roman").text(
      "1.- El trabajador mediante este acuerdo se compromete a trabajar dos horas extraordinarias diarias durante el período comprendido entre el ",
      { continued: true }
    )
    .font("Times-Bold").text(`${diaDesde}`, { continued: true })
    .font("Times-Roman").text(" del ", { continued: true })
    .font("Times-Bold").text(`${mesDesde}`, { continued: true })
    .font("Times-Roman").text(" de ", { continued: true })
    .font("Times-Bold").text(`${yearDesde}`, { continued: true })
    .font("Times-Roman").text(" y el ", { continued: true })
    .font("Times-Bold").text(`${diaHasta}`, { continued: true })
    .font("Times-Roman").text(" del ", { continued: true })
    .font("Times-Bold").text(`${mesHasta}`, { continued: true })
    .font("Times-Roman").text(" de ", { continued: true })
    .font("Times-Bold").text(`${yearHasta}`, { continued: true })
    .font("Times-Roman").text(", las cuales se trabajarán como una prolongación de su horario normal de trabajo.", { continued: false });

    doc.moveDown();
    doc.font("Times-Roman").text("2.- Las horas extraordinarias deberán quedar registradas en el sistema de control de asistencia (libro o reloj control), y se pagarán con un recargo del 50% sobre su remuneración ordinaria.");
    doc.moveDown();
    doc.font("Times-Roman").text("3.- Este acuerdo consignado en este documento y mientras dure, se considerará como un anexo del contrato de trabajo para todas las consideraciones de orden legal o contractual.");
    doc.moveDown();
    doc.font("Times-Roman").text("4.- Para constancia y en señal de mutuo acuerdo, firman las partes en duplicado quedando un ejemplar en poder del trabajador, y el otro en poder del empleador.");

    
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
    pacto_horas_extraordinarias
};
