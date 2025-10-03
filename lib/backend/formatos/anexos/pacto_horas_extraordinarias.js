const PDFDocument = require('pdfkit');
const path = require('path');

function pacto_horas_extraordinarias(parametros) {
    //console.log("Parametros: ", parametros);
    const doc = new PDFDocument({ margin: 50 });
    let buffers = [];
    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {});

  // Logo arriba a la derecha, sin alineamiento especial
  doc.image(path.join(__dirname, '../../../frontend/assets/logos_acviis/Logo Anexos.png'), 420, 0, { width: 120 });

  doc.moveDown(2);
  doc.font("Times-Bold").fontSize(14).text("FORMULARIO PACTO HORAS EXTRAORDINARIAS", { align: "center" });
  doc.moveDown();

  // Encabezado
  const fecha = parametros.fecha ? parametros.fecha : null;
  let dia = "____", mes = "____", year = "____";
  if (fecha) {
    // Espera formato DD-MM-YYYY o similar
    const partes = fecha.split("-");
    if (partes.length === 3) {
      dia = partes[0];
      const meses = [
        "enero", "febrero", "marzo", "abril", "mayo", "junio",
        "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
      ];
      const mesNum = parseInt(partes[1], 10);
      mes = meses[mesNum - 1] || "____";
      year = partes[2];
    }
  } else {
    // Si no hay fecha, usar la actual
    const now = new Date();
    dia = now.getDate().toString().padStart(2, '0');
    const meses = [
      "enero", "febrero", "marzo", "abril", "mayo", "junio",
      "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
    ];
    mes = meses[now.getMonth()];
    year = now.getFullYear().toString();
  }
  doc.font("Times-Roman").fontSize(12)
    .text("En Santiago, ", { continued: true })
    .font("Times-Bold").text(dia, { continued: true })
    .font("Times-Roman").text(" de ", { continued: true })
    .font("Times-Bold").text(mes, { continued: true })
    .font("Times-Roman").text(" de ", { continued: true })
    .font("Times-Bold").text(year, { continued: true })
    .font("Times-Roman").text(", entre ", { continued: true })
    .font("Times-Bold").text("A y C Instalaciones y Montajes  Eléctricos SpA.,  RUT 77.134.913-7", { continued: true })
    .font("Times-Roman").text(", representada por Don ", { continued: true })
    .font("Times-Bold").text("Patricio Andrés Lara Lara, RUN 17.610.898-3", { continued: true })
    .font("Times-Roman").text(" y el trabajador: ", { continued: true })
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
