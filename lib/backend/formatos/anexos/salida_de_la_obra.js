const PDFDocument = require('pdfkit');
const path = require('path');

function salida_de_la_obra(parametros) {
	//console.log("Parametros: ", parametros);
	const doc = new PDFDocument({ margin: 50 });
	let buffers = [];
	doc.on('data', buffers.push.bind(buffers));
	doc.on('end', () => {});

	// Logo arriba a la derecha, sin alineamiento especial
	doc.image(path.join(__dirname, '../../../frontend/assets/logos_acviis/Logo Anexos.png'), 420, 0, { width: 120 });

	doc.moveDown(2);
	doc.font("Times-Bold").fontSize(14).text("ANEXO CONTRATO DE TRABAJO", { align: "center" });
	doc.moveDown();

	// Encabezado
    // Obtener la fecha actual
    const fecha = new Date();
    const dia = fecha.getDate();
    const meses = [
      "enero", "febrero", "marzo", "abril", "mayo", "junio",
      "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
    ];
    const mes = meses[fecha.getMonth()];
    const anio = fecha.getFullYear();

		doc.font("Times-Roman").fontSize(12)
			.text("En Santiago, ", { continued: true })
			.font("Times-Bold").text(`${dia}`, { continued: true })
			.font("Times-Roman").text(" de ", { continued: true })
			.font("Times-Bold").text(`${mes}`, { continued: true })
			.font("Times-Roman").text(" de ", { continued: true })
			.font("Times-Bold").text(`${anio}`, { continued: true })
			.font("Times-Roman").text(", entre la empresa ", { continued: true })
		.font("Times-Bold").text("A y C Montajes e instalaciones SpA., RUT 77.134.913-7", { continued: true })
		.font("Times-Roman").text(", representada por ", { continued: true })
		.font("Times-Bold").text("Patricio Andrés Lara Lara, RUN 17.610.898-3", { continued: true })
		.font("Times-Roman").text(" en adelante ", { continued: true })
		.font("Times-Bold").text('"El Empleador"', { continued: true })
		.font("Times-Roman").text(" con domicilio comercial en ", { continued: true })
			.font("Times-Bold").text("Pedro León Ugalde N°1153", { continued: true })
			.font("Times-Roman").text(", comuna de Santiago y don ", { continued: true })
			.font("Times-Bold").text(parametros.nombre, { continued: true })
			.font("Times-Roman").text(", RUN ", { continued: true })
		.font("Times-Bold").text(parametros.rut, { continued: true })
		.font("Times-Roman").text(", en adelante ", { continued: true })
		.font("Times-Bold").text("El Trabajador", { continued: true })
		.font("Times-Roman").text(" se ha convenido la celebración del siguiente anexo de Contrato de Trabajo.", { continued: false });
	doc.moveDown();

	// Cláusula Primera
	doc.font("Times-Bold").text("CLÁUSULA PRIMERA:", { continued: true });
	doc.font("Times-Roman").text(" Que se modifica la ", { continued: true });
	doc.font("Times-Bold").text("PRIMERA", { continued: true });
	doc.font("Times-Roman").text(" del contrato de trabajo vigente, donde se especifica que:", { continued: false });
	doc.moveDown();

	// Párrafo principal (sin resaltar lo amarillo)
	doc.font("Times-Roman").text("El trabajador, deja de prestar servicios en la obra ", { continued: true });
	doc.font("Times-Bold").text(`"${parametros.obra_previa}"`, { continued: true });
	doc.font("Times-Roman").text(", ubicada en ", { continued: true });
	doc.font("Times-Bold").text(parametros.direccion_obra_previa, { continued: true });
	doc.font("Times-Roman").text(", comuna de ", { continued: true });
	doc.font("Times-Bold").text(parametros.comuna_obra_previa, { continued: true });
	doc.font("Times-Roman").text(", Región ", { continued: true });
	doc.font("Times-Bold").text(parametros.region_obra_previa, { continued: true });
	doc.font("Times-Roman").text(", siendo trasladado a ", { continued: true });
	doc.font("Times-Bold").text(`"${parametros.obra_nueva}"`, { continued: true });
	doc.font("Times-Roman").text(", ubicada en ", { continued: true });
	doc.font("Times-Bold").text(parametros.direccion_obra_nueva, { continued: true });
	doc.font("Times-Roman").text(", comuna de ", { continued: true });
	doc.font("Times-Bold").text(parametros.comuna_obra_nueva, { continued: true });
	doc.font("Times-Roman").text(". Por el tiempo que se estime conveniente, pudiendo ser trasladado a otro domicilio, o labores similares, dentro y fuera de la zona geográfica, por causa justificada, sin que ello importe menoscabo para el trabajador.", { continued: false });
	doc.moveDown();

	// Cláusula Segunda
	doc.font("Times-Bold").text("CLÁUSULA SEGUNDA:", { continued: false });
	doc.font("Times-Roman").text(" Se firma en tres copias de idéntico tenor, declarando El Trabajador haber recibido uno de dichos ejemplares.", { continued: false });
	//doc.moveDown(4);

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
	salida_de_la_obra
};
