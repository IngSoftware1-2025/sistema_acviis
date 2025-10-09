import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';

List<Widget> camposMaestroACargo(
  Trabajador trabajador,
  Map<String, TextEditingController> controllers,
) {
  controllers.putIfAbsent('nombre', () => TextEditingController(text: trabajador.nombreCompleto));
  controllers.putIfAbsent('rut', () => TextEditingController(text: trabajador.rut));
  controllers.putIfAbsent('cargo', () => TextEditingController(text: "Maestro a Cargo"));
  controllers.putIfAbsent('obra', () => TextEditingController());
  controllers.putIfAbsent('direccion_obra', () => TextEditingController());
  controllers.putIfAbsent('comuna_obra', () => TextEditingController());
  controllers.putIfAbsent('region_obra', () => TextEditingController());
  controllers.putIfAbsent('comentario', () => TextEditingController());

  return [
    TextFormField(
      controller: controllers['nombre'],
      decoration: InputDecoration(labelText: 'Nombre'),
      enabled: false,
    ),
    SizedBox(height: 8),
    TextFormField(
      controller: controllers['rut'],
      decoration: InputDecoration(labelText: 'RUT'),
      enabled: false,
    ),
    SizedBox(height: 8),
    TextFormField(
      controller: controllers['cargo'],
      decoration: InputDecoration(labelText: 'Cargo'),
      enabled: false,
    ),
    SizedBox(height: 8),
    TextFormField(
      controller: controllers['obra'],
      decoration: InputDecoration(labelText: 'Obra'),
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
    ),
    SizedBox(height: 8),
    TextFormField(
      controller: controllers['direccion_obra'],
      decoration: InputDecoration(labelText: 'Ubicación obra'),
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
    ),
    SizedBox(height: 8),
    TextFormField(
      controller: controllers['comuna_obra'],
      decoration: InputDecoration(labelText: 'Comuna obra'),
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
    ),
    SizedBox(height: 8),
    TextFormField(
      controller: controllers['region_obra'],
      decoration: InputDecoration(labelText: 'Región'),
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
    ),
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
