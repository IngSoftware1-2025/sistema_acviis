const PDFDocument = require('pdfkit');

function maestro_a_cargo(parametros) {
    //console.log("Parametros: ", parametros);
	const doc = new PDFDocument({ margin: 40, size: 'A4' });
	let buffers = [];

	doc.on('data', buffers.push.bind(buffers));
	doc.on('end', () => {});

	// Logo
	//doc.image('lib/backend/formatos/assets/logo_acviis.png', 420, 30, { width: 120 });

	// Título centrado
	doc.font('Times-Bold').fontSize(14).text('ANEXO CONTRATO DE TRABAJO', { align: 'center', underline: false });
	doc.moveDown(1.5);

    // Primer párrafo
    const fecha = new Date();
    const dia = fecha.getDate();
    const meses = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    const mesTexto = meses[fecha.getMonth()];
    const año = fecha.getFullYear();

    doc.fontSize(12);

    // Primer fragmento
    doc.font('Times-Roman').text('En Santiago, ', { continued: true });
    // Día
    doc.font('Times-Bold').text(`${dia}`, { continued: true });
    // " de "
    doc.font('Times-Roman').text(' de ', { continued: true });
    // Mes
    doc.font('Times-Bold').text(`${mesTexto}`, { continued: true });
    // " "
    doc.font('Times-Roman').text(' ', { continued: true });
    // Año
    doc.font('Times-Bold').text(`${año}`, { continued: true });
    // ", entre la empresa A y C Instalaciones y Montajes Eléctricos SpA., RUT 77.134.913-7, representada por Patricio Andrés Lara Lara, RUT 17.610.898-3 en adelante El Empleador con domicilio comercial en Pedro León Ugalde N°1153, comuna de Santiago y don "
    doc.font('Times-Roman').text(', entre la empresa A y C Instalaciones y Montajes Eléctricos SpA., RUT 77.134.913-7, representada por Patricio Andrés Lara Lara, RUT 17.610.898-3 en adelante El Empleador con domicilio comercial en Pedro León Ugalde N°1153, comuna de Santiago y don ', { continued: true });
    // Nombre
    doc.font('Times-Bold').text(`${parametros.nombre}`, { continued: true });
    // ", RUN "
    doc.font('Times-Roman').text(', RUN ', { continued: true });
    // RUT
    doc.font('Times-Bold').text(`${parametros.rut}`, { continued: true });
    // ", en adelante El Trabajador se ha convenido la celebración del siguiente anexo de Contrato de Trabajo."
    doc.font('Times-Roman').text(', en adelante El Trabajador se ha convenido la celebración del siguiente anexo de Contrato de Trabajo.', { continued: false });

    doc.moveDown(1);

    // Cláusula Primera (bold)
    doc.font('Times-Bold').text('CLÁUSULA PRIMERA:', { continued: false });
    doc.font('Times-Roman').text(' Que se modifica el cargo del trabajador y se compromete y se obliga a desempeñar funciones como ', { continued: true });
    doc.font('Times-Bold').text(`${parametros.cargo || ''}`, { continued: true });
    doc.font('Times-Roman').text(' en la obra ', { continued: true });
    doc.font('Times-Roman').text(' en la obra ', { continued: true });
    doc.font('Times-Bold').text(`${parametros.obra}`, { continued: true });
    doc.font('Times-Roman').text(` ubicada en `, { continued: true });
    doc.font('Times-Bold').text(`${parametros.direccion_obra}`, { continued: true });
    doc.font('Times-Roman').text(`, comuna de `, { continued: true });
    doc.font('Times-Bold').text(`${parametros.comuna_obra}`, { continued: true });
    doc.font('Times-Roman').text(`, Región de `, { continued: true });
    doc.font('Times-Bold').text(`${parametros.region_obra}.`, { continued: false });
    doc.moveDown(0.5);

    // Funciones del cargo (bold)
    doc.font('Times-Roman').text('Dentro de las funciones del cargo se encuentran:');

	// Lista de funciones (letra normal)
	doc.font('Times-Roman').fontSize(11);
	const funciones = [
		'a) Dirigir un grupo de trabajadores no superior a seis personas, liderando una tarea encomendada por su superior jerárquico inmediato.',
		'b) Lectura de planos en físico y digital, capacidad para resolver problemas y entregar directrices a sus colegas.',
		'c) Organizar la mano de obra y el trabajo diariamente, identificando las herramientas y materiales que se necesiten para ejecutar los trabajos y comunicar oportunamente, es decir, lo más pronto posible a su superior inmediato o a quien se le indique, por escrito.',
		'd) Procurar que los equipos y herramientas para el trabajo sean adecuados, en cuanto a su funcionalidad y condiciones de seguridad.',
		'e) Acatar cada una de las solicitudes, referentes a su labor, dadas por su superior inmediato.',
		'f) Resolver todos aquellos conflictos que se presenten con ocasión de la ejecución de la obra.',
		'g) Respetar y velar por el cumplimiento de las normas de prevención, encargándose de difundir charlas, solicitando asesoría para los distintos trabajos a ejecutar, controlando el buen uso de los elementos de protección personal y haciendo prevención con el ejemplo.',
		'h) Velar porque las programaciones semanales de construcción en la obra y difusión de dichos programas a los trabajadores se cumplan, además de informar las actualizaciones de los programas según los requerimientos de esta a los trabajadores.',
		'i) Supervisar que los equipos y herramientas para la ejecución de los trabajos sean adecuados, en cuanto a su funcionalidad y condiciones de seguridad y avisar a superior jerárquico inmediato y/o prevencionista, por escrito, o por cualquier medio idóneo cuando los mismos presenten desperfectos o deficiencias que pudiesen poner en riesgo la seguridad de los trabajadores y de la obra.',
		'j) Procurar la limpieza del área de trabajo en forma previa al inicio de la jornada laboral, para que este tenga las condiciones seguras para la ejecución de las actividades a desarrollar.',
		'k) Entregar información a su superior jerárquico inmediato respecto a la necesidad de análisis de riesgo en la obra o generación de procedimientos de trabajo seguro, todo lo anterior por escrito.',
		'l) Velar porque la ejecución de los trabajos se realice en forma segura, incentivando y promoviendo la prevención de riesgos. Identificar problemas y asistir a los maestros y ayudantes para solucionarlos, solicitando en su caso información al Asesor en prevención de Riesgos o Supervisor cuando requiera orientación referente a diversas situaciones que no pueda resolver por sí mismo.',
		'k) Velar por el correcto desempeño de las funciones de los trabajadores a su cargo, así como supervisar que las mismas se desarrollen de manera eficiente y segura, informando si se requiere amonestar a aquellos trabajadores que generen riesgos que expongan al personal y que puedan ir en perjuicio del trabajador mismo o de la obra y/o la empresa.',
		'l) Mantener trato directo con los subcontratistas, en caso de ser necesario, velando por el cumplimiento efectivo de las normas y estándares de seguridad y calidad impuestos por ACVIIS Spa. y el mandante.',
		'm) Cuidar los recursos materiales, velando por el uso eficiente de los mismos, así como tener un trato cordial y ameno tanto con el personal de la empresa como con los mandantes de la obra.',
		'n) Informar diariamente a su superior inmediato de los avances de la obra y requerimientos de esta de forma verbal y/o escrita.'
	];
	funciones.forEach(f => doc.text(f, { paragraphGap: 2 }));
	doc.moveDown(0.5);

	doc.font('Times-Roman').text('En el desempeño de sus funciones el trabajador podrá ser trasladado a otra dependencia u agencia del empleador, para ejecutar labores similares, en la misma ciudad o una ciudad distinta y sin que ello importe un menoscabo para el trabajador.');
	doc.moveDown(1);

	// Cláusula Segunda (bold)
	doc.font('Times-Bold').text('CLÁUSULA SEGUNDA ', { continued: true });
	doc.font('Times-Roman').text('Se firma en cuatro copias de idéntico tenor, declarando El Trabajador haber recibido uno de dichos ejemplares.');
	doc.moveDown(2);


    // Espacio para firmas: si no hay suficiente espacio, saltar a nueva página
    const espacioFirmas = 120; // px aproximado para las firmas
    if (doc.y + espacioFirmas > doc.page.height - doc.page.margins.bottom) {
        doc.addPage();
    } else {
        doc.moveDown(6); // Asegura que las firmas estén debajo del texto
    }

    // Coordenadas base para la fila de firmas
    const firmaY = doc.y;

    // Firma Trabajador (columna izquierda)
    doc.text("---------------------------------------------", 50, firmaY);
    doc.text("FIRMA TRABAJADOR", 15, firmaY + 15, { width: 250, align: "center" });
    doc.text("NOMBRE TRABAJADOR", 15, firmaY + 30, { width: 250, align: "center" });
    doc.text("RUN TRABAJADOR", 15, firmaY + 45, { width: 250, align: "center" });

    // Firma Empleador (columna derecha)
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
	maestro_a_cargo
};
