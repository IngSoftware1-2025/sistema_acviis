const PDFDocument = require('pdfkit');

function traslado(parametros) {
    console.log("Parametros: ", parametros);
	const doc = new PDFDocument({ margin: 50 });
	let buffers = [];
	doc.on('data', buffers.push.bind(buffers));
	doc.on('end', () => {});

	// Logo (opcional)
	// doc.image("logo.png", 400, 20, { width: 100 });

	doc.font("Times-Bold").fontSize(14).text("ANEXO CONTRATO DE TRABAJO", { align: "center" });
	doc.moveDown();

	// Encabezado
    const fecha = new Date();
    const dia = fecha.getDate();
    const meses = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    const mes = meses[fecha.getMonth()];
    const anio = fecha.getFullYear();

    doc.font("Times-Roman").fontSize(12)
      .text("En Santiago, ", { continued: true })
      .font("Times-Bold").text(dia, { continued: true })
      .font("Times-Roman").text(" de ", { continued: true })
      .font("Times-Bold").text(mes, { continued: true })
      .font("Times-Roman").text(" de ", { continued: true })
      .font("Times-Bold").text(anio, { continued: true })
      .font("Times-Roman").text(", entre la empresa ", { continued: true })
      .font("Times-Bold").text("A y C Instalaciones y Montajes Eléctricos SpA., RUT 77.134.913-7, representada por Patricio Andrés Lara Lara, RUN 17.610.898-3", { continued: true })
      .font("Times-Roman").text(" en adelante ", { continued: true })
      .font("Times-Bold").text("El Empleador", { continued: true })
      .font("Times-Roman").text(" con domicilio comercial en ", { continued: true })
      .font("Times-Bold").text("Pedro León Ugalde N°1153", { continued: true })
      .font("Times-Roman").text(", comuna de Santiago y don ", { continued: true })
      .font("Times-Bold").text(parametros.nombre || "___________", { continued: true })
      .font("Times-Roman").text(", RUN ", { continued: true })
      .font("Times-Bold").text(parametros.rut || "___________", { continued: true })
      .font("Times-Roman").text(", en adelante El Trabajador se ha convenido la celebración del siguiente anexo de Contrato de Trabajo.", { continued: false });
	doc.moveDown();

	// Cláusula Primera
	doc.font("Times-Bold").text("CLÁUSULA PRIMERA:", { continued: true });
	doc.font("Times-Roman").text(" Que se modifica la ", { continued: true });
    doc.font("Times-Bold").text("CLÁUSULA PRIMERA", { continued: true});
    doc.font("Times-Roman").text("del contrato de trabajo vigente, donde se especifica que:", { continued: false });  
	doc.moveDown();

	// Párrafo principal (sin resaltar lo amarillo)
	doc.font("Times-Roman").text("A contar de esta fecha el trabajador será trasladado desde obra ", { continued: true });
	doc.font("Times-Bold").text(parametros.obra_previa || '"Oficina Central"', { continued: true });
	doc.font("Times-Roman").text(" ubicada en ", { continued: true });
	doc.font("Times-Bold").text(parametros.direccion_obra_previa || "Pedro León Ugalde N°1153", { continued: true });
	doc.font("Times-Roman").text(" comuna de ", { continued: true });
	doc.font("Times-Bold").text(parametros.comuna_obra_previa || "Santiago", { continued: true });
	doc.font("Times-Roman").text(" a obra ", { continued: true });
	doc.font("Times-Bold").text(parametros.obra_nueva || '"SUPER 10 RENCA"', { continued: true });
	doc.font("Times-Roman").text(" ubicada en ", { continued: true });
	doc.font("Times-Bold").text(parametros.direccion_obra_nueva || "Av. Domingo Santa María N°4120", { continued: true });
	doc.font("Times-Roman").text(", comuna de ", { continued: true });
	doc.font("Times-Bold").text(parametros.comuna_obra_nueva || "Renca", { continued: true });
	doc.font("Times-Roman").text(`, ${parametros.region_obra_nueva || "Región Metropolitana"}.`, { continued: false });
	doc.moveDown();

	// Cláusula Segunda
	doc.font("Times-Bold").text("CLÁUSULA SEGUNDA", { continued: true });
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
	traslado
};
