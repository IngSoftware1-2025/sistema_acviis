
import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';

List<Widget> camposPactoHorasExtraordinarias(
  Trabajador trabajador,
  Map<String, TextEditingController> controllers,
) {
  DateTime now = DateTime.now();
  controllers.putIfAbsent('fecha', () => TextEditingController(text: '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}'));
  controllers.putIfAbsent('nombre', () => TextEditingController(text: trabajador?.nombreCompleto ?? ''));
  controllers.putIfAbsent('rut', () => TextEditingController(text: trabajador?.rut ?? ''));
  controllers.putIfAbsent('direccion', () => TextEditingController(text: trabajador?.direccion ?? ''));
  controllers.putIfAbsent('comuna', () => TextEditingController());

  // Variables que viven fuera del build del List<Widget>
  DateTime fechaDesde = DateTime.now();
  DateTime fechaHasta = DateTime.now();

  // Controladores iniciales
  controllers.putIfAbsent('fecha_desde', () => TextEditingController(
    text: '${fechaDesde.day.toString().padLeft(2, '0')}-${_nombreMes(fechaDesde.month)}-${fechaDesde.year}'
  ));

  controllers.putIfAbsent('fecha_hasta', () => TextEditingController(
    text: '${fechaHasta.day.toString().padLeft(2, '0')}-${_nombreMes(fechaHasta.month)}-${fechaHasta.year}'
  ));

  // Ahora construyes tu lista de widgets
  List<Widget> camposFechas = [

    // FECHA DESDE
    Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: 'Día'),
            keyboardType: TextInputType.number,
            initialValue: fechaDesde.day.toString().padLeft(2, '0'),
            onChanged: (value) {
              int? diaDesde = int.tryParse(value);
              if (diaDesde != null) {
                fechaDesde = DateTime(fechaDesde.year, fechaDesde.month, diaDesde);
                controllers['fecha_desde']?.text =
                  '${fechaDesde.day.toString().padLeft(2, '0')}-${_nombreMes(fechaDesde.month)}-${fechaDesde.year}';
              }
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: fechaDesde.month,
            decoration: InputDecoration(labelText: 'Mes'),
            items: List.generate(
              12,
              (iDesde) => DropdownMenuItem(
                value: iDesde + 1,
                child: Text(_nombreMes(iDesde + 1)),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                fechaDesde = DateTime(fechaDesde.year, value, fechaDesde.day);
                controllers['fecha_desde']?.text =
                  '${fechaDesde.day.toString().padLeft(2, '0')}-${_nombreMes(fechaDesde.month)}-${fechaDesde.year}';
              }
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: 'Año'),
            keyboardType: TextInputType.number,
            initialValue: fechaDesde.year.toString(),
            onChanged: (value) {
              int? year = int.tryParse(value);
              if (year != null) {
                fechaDesde = DateTime(year, fechaDesde.month, fechaDesde.day);
                controllers['fecha_desde']?.text =
                  '${fechaDesde.day.toString().padLeft(2, '0')}-${_nombreMes(fechaDesde.month)}-${fechaDesde.year}';
              }
            },
          ),
        ),
      ],
    ),

    SizedBox(height: 16),

    // FECHA HASTA
    Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: 'Día'),
            keyboardType: TextInputType.number,
            initialValue: fechaHasta.day.toString().padLeft(2, '0'),
            onChanged: (value) {
              int? dia = int.tryParse(value);
              if (dia != null) {
                fechaHasta = DateTime(fechaHasta.year, fechaHasta.month, dia);
                controllers['fecha_hasta']?.text =
                  '${fechaHasta.day.toString().padLeft(2, '0')}-${_nombreMes(fechaHasta.month)}-${fechaHasta.year}';
              }
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: fechaHasta.month,
            decoration: InputDecoration(labelText: 'Mes'),
            items: List.generate(
              12,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(_nombreMes(i + 1)),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                fechaHasta = DateTime(fechaHasta.year, value, fechaHasta.day);
                controllers['fecha_hasta']?.text =
                  '${fechaHasta.day.toString().padLeft(2, '0')}-${_nombreMes(fechaHasta.month)}-${fechaHasta.year}';
              }
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: 'Año'),
            keyboardType: TextInputType.number,
            initialValue: fechaHasta.year.toString(),
            onChanged: (value) {
              int? year = int.tryParse(value);
              if (year != null) {
                fechaHasta = DateTime(year, fechaHasta.month, fechaHasta.day);
                controllers['fecha_hasta']?.text =
                  '${fechaHasta.day.toString().padLeft(2, '0')}-${_nombreMes(fechaHasta.month)}-${fechaHasta.year}';
              }
            },
          ),
        ),
      ],
    ),
  ];


  // Fecha actual (no editable, estilo reajuste de sueldo)
  Widget fechaActualRow = Row(
    children: [
      Expanded(
        child: TextFormField(
          initialValue: now.day.toString().padLeft(2, '0'),
          decoration: InputDecoration(labelText: 'Día'),
          enabled: false,
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: TextFormField(
          initialValue: _nombreMes(now.month),
          decoration: InputDecoration(labelText: 'Mes'),
          enabled: false,
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: TextFormField(
          initialValue: now.year.toString(),
          decoration: InputDecoration(labelText: 'Año'),
          enabled: false,
        ),
      ),
    ],
  );

  return [
    Text('Fecha actual:', style: TextStyle(fontWeight: FontWeight.bold)),
    fechaActualRow,
    SizedBox(height: 8),
    TextFormField(
      controller: controllers['nombre'],
      decoration: InputDecoration(labelText: 'Nombre trabajador'),
      enabled: false,
    ),
    TextFormField(
      controller: controllers['rut'],
      decoration: InputDecoration(labelText: 'RUT trabajador'),
      enabled: false,
    ),
    TextFormField(
      controller: controllers['direccion'],
      decoration: InputDecoration(labelText: 'Dirección trabajador'),
    ),
    TextFormField(
      controller: controllers['comuna'],
      decoration: InputDecoration(labelText: 'Comuna trabajador'),
    ),
    SizedBox(height: 8),
    Text('Fecha desde:', style: TextStyle(fontWeight: FontWeight.bold)),
    ...camposFechas,
    SizedBox(height: 8),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controllers['comentario'],
        decoration: InputDecoration(
          labelText: 'Comentario del anexo',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
        minLines: 3,
      ),
    ),
  ];
}

// Helper para obtener el nombre del mes en español
String _nombreMes(int mes) {
  const meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  return meses[mes - 1];
}
