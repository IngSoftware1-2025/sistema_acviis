import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_acviis/models/trabajador.dart';

List<Widget> camposReajusteDeSueldo(
  Trabajador trabajador,
  Map<String, TextEditingController> controllers, {
  DateTime? fechaDesde,
  void Function(DateTime)? onFechaDesdeChanged,
}) {
  DateTime now = DateTime.now();

  // Inicializa controladores si no existen
  controllers.putIfAbsent('nombre', () => TextEditingController(text: trabajador.nombreCompleto));
  controllers.putIfAbsent('rut', () => TextEditingController(text: trabajador.rut));
  controllers.putIfAbsent('nuevo_sueldo', () => TextEditingController());
  controllers.putIfAbsent('asignacion_colacion', () => TextEditingController());
  controllers.putIfAbsent('asignacion_movilizacion', () => TextEditingController());
  controllers.putIfAbsent('comentario', () => TextEditingController());
  // Controlador para fecha_desde en formato dd-mm-yyyy
  DateTime fecha = fechaDesde ?? now;
    String fechaDesdeStr = '${fecha.day.toString().padLeft(2, '0')}-${_nombreMes(fecha.month)}-${fecha.year}';
  controllers.putIfAbsent('fecha_desde', () => TextEditingController(text: fechaDesdeStr));

  // Fecha actual (no editable)
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

  // Fecha desde (editable)
  Widget fechaDesdeRow = Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<int>(
          value: fecha.day,
          decoration: InputDecoration(labelText: 'Día'),
          items: List.generate(31, (i) => DropdownMenuItem(
            value: i + 1,
            child: Text((i + 1).toString().padLeft(2, '0')),
          )),
          onChanged: (value) {
            if (value != null) {
              DateTime nuevaFecha = DateTime(fecha.year, fecha.month, value);
              String nuevaFechaStr = '${nuevaFecha.day.toString().padLeft(2, '0')}-${_nombreMes(nuevaFecha.month)}-${nuevaFecha.year}';
              controllers['fecha_desde']?.text = nuevaFechaStr;
              if (onFechaDesdeChanged != null) onFechaDesdeChanged(nuevaFecha);
            }
          },
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: DropdownButtonFormField<int>(
          value: fecha.month,
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
              DateTime nuevaFecha = DateTime(fecha.year, value, fecha.day);
              String nuevaFechaStr = '${nuevaFecha.day.toString().padLeft(2, '0')}-${_nombreMes(nuevaFecha.month)}-${nuevaFecha.year}';
              controllers['fecha_desde']?.text = nuevaFechaStr;
              if (onFechaDesdeChanged != null) onFechaDesdeChanged(nuevaFecha);
            }
          },
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: DropdownButtonFormField<int>(
          value: fecha.year,
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
              DateTime nuevaFecha = DateTime(value, fecha.month, fecha.day);
              String nuevaFechaStr = '${nuevaFecha.day.toString().padLeft(2, '0')}-${_nombreMes(nuevaFecha.month)}-${nuevaFecha.year}';
              controllers['fecha_desde']?.text = nuevaFechaStr;
              if (onFechaDesdeChanged != null) onFechaDesdeChanged(nuevaFecha);
            }
          },
        ),
      ),
    ],
  );

  return [
    // Fecha actual (solo visible, no editable)
    Text('Fecha actual:', style: TextStyle(fontWeight: FontWeight.bold)),
    fechaActualRow,
    SizedBox(height: 8),
    // Nombre
    TextField(
      controller: controllers['nombre'],
      decoration: InputDecoration(labelText: 'Nombre'),
      enabled: false,
    ),
    // Rut
    TextField(
      controller: controllers['rut'],
      decoration: InputDecoration(labelText: 'Rut'),
      enabled: false,
    ),
    // Nuevo Sueldo
    TextFormField(
      controller: controllers['nuevo_sueldo'],
      decoration: InputDecoration(labelText: 'Nuevo sueldo'),
      keyboardType: TextInputType.number,
      validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Este campo no puede estar vacío';
      }
      return null;
      },
      inputFormatters: [
      // Solo permite números
        FilteringTextInputFormatter.digitsOnly,
      ],
    ),
    // Movilizacion y Colacion (Algo grandes asi que los separamos)
    StatefulBuilder(
      builder: (context, setState) {
        // Definir las variables fuera del builder para que el estado persista
        return _ColacionMovilizacionFields(controllers: controllers);
      },
    ),
    // Fecha desde (rellenable, formato dd-mes-yyyy con mes en texto)
    Text('Fecha desde:', style: TextStyle(fontWeight: FontWeight.bold)),
    fechaDesdeRow,

    // Comentario (sección más grande)
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

class _ColacionMovilizacionFields extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  const _ColacionMovilizacionFields({required this.controllers});

  @override
  State<_ColacionMovilizacionFields> createState() => _ColacionMovilizacionFieldsState();
}

class _ColacionMovilizacionFieldsState extends State<_ColacionMovilizacionFields> {
  bool mostrarColacion = false;
  bool mostrarMovilizacion = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: mostrarColacion,
              onChanged: (value) {
                setState(() {
                  mostrarColacion = value ?? false;
                  if (!mostrarColacion) {
                    widget.controllers['asignacion_colacion']?.clear();
                  }
                });
              },
            ),
            if (!mostrarColacion)
              Text('Agregar asignación colación'),
            if (mostrarColacion)
              Expanded(
                child: TextFormField(
                  controller: widget.controllers['asignacion_colacion'],
                  decoration: InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (mostrarColacion && (value == null || value.isEmpty)) {
                      return 'Campo obligatorio';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: mostrarMovilizacion,
              onChanged: (value) {
                setState(() {
                  mostrarMovilizacion = value ?? false;
                  if (!mostrarMovilizacion) {
                    widget.controllers['asignacion_movilizacion']?.clear();
                  }
                });
              },
            ),
            if (!mostrarMovilizacion)
              Text('Agregar asignación movilización'),
            if (mostrarMovilizacion)
              Expanded(
                child: TextFormField(
                  controller: widget.controllers['asignacion_movilizacion'],
                  decoration: InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (mostrarMovilizacion && (value == null || value.isEmpty)) {
                      return 'Campo obligatorio';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
