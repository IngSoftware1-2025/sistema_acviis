import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';

List<Widget> camposSalidaDeLaObra(
	Trabajador trabajador,
	Map<String, TextEditingController> controllers,
) {
			controllers.putIfAbsent('nombre', () => TextEditingController(text: trabajador.nombreCompleto));
			controllers.putIfAbsent('rut', () => TextEditingController(text: trabajador.rut));
			controllers.putIfAbsent('obra_previa', () => TextEditingController());
			controllers.putIfAbsent('direccion_obra_previa', () => TextEditingController());
			controllers.putIfAbsent('comuna_obra_previa', () => TextEditingController());
			controllers.putIfAbsent('region_obra_previa', () => TextEditingController());
			controllers.putIfAbsent('obra_nueva', () => TextEditingController());
			controllers.putIfAbsent('direccion_obra_nueva', () => TextEditingController());
			controllers.putIfAbsent('comuna_obra_nueva', () => TextEditingController());
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
					controller: controllers['obra_previa'],
					decoration: InputDecoration(labelText: 'Obra previa'),
				),
				SizedBox(height: 8),
				TextFormField(
					controller: controllers['direccion_obra_previa'],
					decoration: InputDecoration(labelText: 'Dirección obra previa'),
				),
				SizedBox(height: 8),
				TextFormField(
					controller: controllers['comuna_obra_previa'],
					decoration: InputDecoration(labelText: 'Comuna obra previa'),
				),
				SizedBox(height: 8),
				TextFormField(
					controller: controllers['region_obra_previa'],
					decoration: InputDecoration(labelText: 'Región obra previa'),
				),
				SizedBox(height: 8),
				TextFormField(
					controller: controllers['obra_nueva'],
					decoration: InputDecoration(labelText: 'Obra nueva'),
				),
				SizedBox(height: 8),
				TextFormField(
					controller: controllers['direccion_obra_nueva'],
					decoration: InputDecoration(labelText: 'Dirección obra nueva'),
				),
				SizedBox(height: 8),
				TextFormField(
					controller: controllers['comuna_obra_nueva'],
					decoration: InputDecoration(labelText: 'Comuna obra nueva'),
				),
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
