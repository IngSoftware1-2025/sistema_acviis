import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';

List<Widget> camposJornadaLaboral(
	Trabajador trabajador,
	Map<String, TextEditingController> controllers,
) {
	controllers.putIfAbsent('nombre', () => TextEditingController(text: trabajador.nombreCompleto));
	controllers.putIfAbsent('rut', () => TextEditingController(text: trabajador.rut));
	controllers.putIfAbsent('dia_inicio', () => TextEditingController());
	controllers.putIfAbsent('dia_fin', () => TextEditingController());
	controllers.putIfAbsent('hora_inicio', () => TextEditingController());
	controllers.putIfAbsent('hora_fin', () => TextEditingController());
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
		Row(
			children: [
				Expanded(
					child: TextFormField(
						controller: controllers['dia_inicio'],
						decoration: InputDecoration(labelText: 'Día inicio'),
						keyboardType: TextInputType.number,
					),
				),
				SizedBox(width: 8),
				Expanded(
					child: TextFormField(
						controller: controllers['dia_fin'],
						decoration: InputDecoration(labelText: 'Día fin'),
						keyboardType: TextInputType.number,
					),
				),
			],
		),
		SizedBox(height: 8),
		Row(
			children: [
				Expanded(
					child: TextFormField(
						controller: controllers['hora_inicio'],
						decoration: InputDecoration(labelText: 'Hora inicio'),
						keyboardType: TextInputType.datetime,
					),
				),
				SizedBox(width: 8),
				Expanded(
					child: TextFormField(
						controller: controllers['hora_fin'],
						decoration: InputDecoration(labelText: 'Hora fin'),
						keyboardType: TextInputType.datetime,
					),
				),
			],
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
