
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
          child: DropdownButtonFormField<int>(
            value: fechaDesde.day,
            decoration: InputDecoration(labelText: 'Día'),
            items: List.generate(31, (i) => DropdownMenuItem(
              value: i + 1,
              child: Text((i + 1).toString().padLeft(2, '0')),
            )),
            onChanged: (value) {
              if (value != null) {
                fechaDesde = DateTime(fechaDesde.year, fechaDesde.month, value);
                controllers['fecha_desde']?.text =
                  '${fechaDesde.day.toString().padLeft(2, '0')}-${_nombreMes(fechaDesde.month)}-${fechaDesde.year}';
              }
            },
            validator: (value) => value == null ? 'Campo obligatorio' : null,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: fechaDesde.month,
            decoration: InputDecoration(labelText: 'Mes'),
            items: List.generate(12, (i) => DropdownMenuItem(
              value: i + 1,
              child: Text(_nombreMes(i + 1)),
            )),
            onChanged: (value) {
              if (value != null) {
                fechaDesde = DateTime(fechaDesde.year, value, fechaDesde.day);
                controllers['fecha_desde']?.text =
                  '${fechaDesde.day.toString().padLeft(2, '0')}-${_nombreMes(fechaDesde.month)}-${fechaDesde.year}';
              }
            },
            validator: (value) => value == null ? 'Campo obligatorio' : null,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: fechaDesde.year,
            decoration: InputDecoration(labelText: 'Año'),
            items: List.generate(6, (i) {
              int year = now.year + i;
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                fechaDesde = DateTime(value, fechaDesde.month, fechaDesde.day);
                controllers['fecha_desde']?.text =
                  '${fechaDesde.day.toString().padLeft(2, '0')}-${_nombreMes(fechaDesde.month)}-${fechaDesde.year}';
              }
            },
            validator: (value) => value == null ? 'Campo obligatorio' : null,
          ),
        ),
      ],
    ),
    SizedBox(height: 16),
    // FECHA HASTA
    Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: fechaHasta.day,
            decoration: InputDecoration(labelText: 'Día'),
            items: List.generate(31, (i) => DropdownMenuItem(
              value: i + 1,
              child: Text((i + 1).toString().padLeft(2, '0')),
            )),
            onChanged: (value) {
              if (value != null) {
                fechaHasta = DateTime(fechaHasta.year, fechaHasta.month, value);
                controllers['fecha_hasta']?.text =
                  '${fechaHasta.day.toString().padLeft(2, '0')}-${_nombreMes(fechaHasta.month)}-${fechaHasta.year}';
              }
            },
            validator: (value) => value == null ? 'Campo obligatorio' : null,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: fechaHasta.month,
            decoration: InputDecoration(labelText: 'Mes'),
            items: List.generate(12, (i) => DropdownMenuItem(
              value: i + 1,
              child: Text(_nombreMes(i + 1)),
            )),
            onChanged: (value) {
              if (value != null) {
                fechaHasta = DateTime(fechaHasta.year, value, fechaHasta.day);
                controllers['fecha_hasta']?.text =
                  '${fechaHasta.day.toString().padLeft(2, '0')}-${_nombreMes(fechaHasta.month)}-${fechaHasta.year}';
              }
            },
            validator: (value) => value == null ? 'Campo obligatorio' : null,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: fechaHasta.year,
            decoration: InputDecoration(labelText: 'Año'),
            items: List.generate(6, (i) {
              int year = now.year + i;
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                fechaHasta = DateTime(value, fechaHasta.month, fechaHasta.day);
                controllers['fecha_hasta']?.text =
                  '${fechaHasta.day.toString().padLeft(2, '0')}-${_nombreMes(fechaHasta.month)}-${fechaHasta.year}';
              }
            },
            validator: (value) => value == null ? 'Campo obligatorio' : null,
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
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
    ),
    TextFormField(
      controller: controllers['comuna'],
      decoration: InputDecoration(labelText: 'Comuna trabajador'),
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
    ),
    SizedBox(height: 8),
    Text('Intervalo Fechas (Inicio - Fin):', style: TextStyle(fontWeight: FontWeight.bold)),
    ...camposFechas,
    SizedBox(height: 8),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controllers['comentario'],
        decoration: InputDecoration(
          labelText: 'Comentario del anexo',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
        minLines: 3,
        validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
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
