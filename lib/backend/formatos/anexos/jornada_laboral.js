const PDFDocument = require('pdfkit');

function jornada_laboral(parametros) {
    console.log("Parametros: ", parametros);
	const doc = new PDFDocument({ margin: 40, size: 'A4' });
	let buffers = [];

	doc.on('data', buffers.push.bind(buffers));
	doc.on('end', () => {});

	// Logo (descomentar si tienes la ruta)
	// doc.image('lib/backend/formatos/assets/logo_acviis.png', 420, 30, { width: 120 });

	// Título centrado
	doc.font('Times-Bold').fontSize(14).text('ANEXO CONTRATO DE TRABAJO', { align: 'center', underline: false });
	doc.moveDown(1.5);

	// Fecha actual
	const fecha = new Date();
	const dia = fecha.getDate();
	const meses = [
		"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
		"Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
	];
	const mesTexto = meses[fecha.getMonth()];
	const año = fecha.getFullYear();

    doc.fontSize(12);
    doc.font('Times-Roman').text('En ', { continued: true });
    doc.font('Times-Bold').text('Santiago', { continued: true });
    doc.font('Times-Roman').text(', ', { continued: true });
    doc.font('Times-Bold').text(`${dia}`, { continued: true });
    doc.font('Times-Roman').text(' de ', { continued: true });
    doc.font('Times-Bold').text(`${mesTexto}`, { continued: true });
    doc.font('Times-Roman').text(' ', { continued: true });
    doc.font('Times-Bold').text(`${año}`, { continued: true });
    doc.font('Times-Roman').text(', entre la ', { continued: true });
    doc.font('Times-Bold').text('empresa A y C Montajes e Instalaciones SpA., RUT 77.134.913-7', { continued: true });
    doc.font('Times-Roman').text(', representada por ', { continued: true });
    doc.font('Times-Bold').text('Patricio Andrés Lara Lara, RUN 17.610.898-3', { continued: true });
    doc.font('Times-Roman').text(', en adelante "', { continued: true });
    doc.font('Times-Bold').text('El Empleador', { continued: true });
    doc.font('Times-Roman').text('" con domicilio comercial en ', { continued: true });
    doc.font('Times-Bold').text('Pedro León Ugalde N°1153', { continued: true });
    doc.font('Times-Roman').text(', comuna de ', { continued: true });
    doc.font('Times-Bold').text('Santiago', { continued: true });
    doc.font('Times-Roman').text(' y don ', { continued: true });
    doc.font('Times-Bold').text(`${parametros.nombre}`, { continued: true });
    doc.font('Times-Roman').text(', RUN ', { continued: true });
    doc.font('Times-Bold').text(`${parametros.rut}`, { continued: true });
    doc.font('Times-Roman').text(', en adelante "El Trabajador" se ha convenido la celebración del siguiente anexo de Contrato de Trabajo.', { continued: false });

	doc.moveDown(1);
    // Cláusula Primera
    doc.font('Times-Bold').text('CLÁUSULA PRIMERA:', { continued: true});
    doc.font('Times-Roman').text(' Que se modifica la ', { continued: true});
    doc.font('Times-Bold').text('TERCERA ', { continued: true});
    doc.font('Times-Roman').text(' del contrato de trabajo vigente, donde vigente, donde se especifica que:', { continued: false});

    doc.moveDown(0.5);
    doc.font('Times-Roman').text('El Trabajador, cumplirá una jornada laboral de 40 horas semanales, distribuidas de ', { continued: true});
    doc.font('Times-Bold').text(`${parametros.dia_inicio}`, {continued: true});
    doc.font('Times-Roman').text(' a ', { continued: true});
    doc.font('Times-Bold').text(`${parametros.dia_fin}`, { continued: true});
    doc.font('Times-Roman').text(' de ', { continued: true});
    doc.font('Times-Bold').text(`${parametros.hora_inicio}`, { continued: true});
    doc.font('Times-Roman').text(' hasta las ', { continued: true});
    doc.font('Times-Bold').text(`${parametros.hora_fin}`, { continued: true});
    doc.font('Times-Roman').text(', teniendo 60 minutos diarios de colación no imputable a la jornada de trabajo.', { continued: false});

    doc.moveDown(1);

    // Cláusula Segunda
    doc.font('Times-Bold').text('CLÁUSULA SEGUNDA ', { continued: true});
    doc.font('Times-Roman').text('Se firma en cuatro copias de idéntico tenor, declarando El Trabajador haber recibido dichos ejemplares.', { align: 'justify' });

	doc.moveDown(6);
    // Espacio para firmas al pie de página
    const pageHeight = doc.page.height;
    const marginBottom = 40;
    const firmaY = pageHeight - marginBottom - 60; // 60px alto de las firmas

    doc.text("---------------------------------------------", 50, firmaY);
    doc.text("FIRMA TRABAJADOR", 15, firmaY + 15, { width: 250, align: "center" });
    doc.text("NOMBRE TRABAJADOR", 15, firmaY + 30, { width: 250, align: "center" });
    doc.text("RUN TRABAJADOR", 15, firmaY + 45, { width: 250, align: "center" });

    doc.text("---------------------------------------------", 350, firmaY);
    doc.text("FIRMA EMPLEADOR", 320, firmaY + 15, { width: 250, align: "center" });
    doc.text("ACVIIS SpA.", 320, firmaY + 30, { width: 250, align: "center" });
    doc.text("77.134.913-7", 320, firmaY + 45, { width: 250, align: "center" });

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
	jornada_laboral
};
