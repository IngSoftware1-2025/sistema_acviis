

import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';

List<String> diasSemana = [
	'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'
];

typedef JornadaLaboralValidator = String? Function(Map<String, TextEditingController> controllers);

String? validar40HorasJornada(Map<String, TextEditingController> controllers) {
	final diaInicio = controllers['dia_inicio']?.text;
	final diaFin = controllers['dia_fin']?.text;
	final horaInicio = controllers['hora_inicio']?.text;
	final horaFin = controllers['hora_fin']?.text;
	if ([diaInicio, diaFin, horaInicio, horaFin].any((v) => v == null || v.isEmpty)) return null;

	final idxInicio = diasSemana.indexOf(diaInicio!);
	final idxFin = diasSemana.indexOf(diaFin!);
	if (idxInicio == -1 || idxFin == -1 || idxFin < idxInicio) return 'Rango de días inválido';
	final diasLaborales = idxFin - idxInicio + 1;
	TimeOfDay? parseHora(String h) {
		final parts = h.split(":");
		if (parts.length != 2) return null;
		int? hour = int.tryParse(parts[0]);
		int? minute = int.tryParse(parts[1]);
		if (hour == null || minute == null) return null;
		return TimeOfDay(hour: hour, minute: minute);
	}
	TimeOfDay? hi = parseHora(horaInicio ?? "");
	TimeOfDay? hf = parseHora(horaFin ?? "");
	if (hi == null || hf == null) return 'Formato de hora inválido';
	double horasPorDia = (hf.hour + hf.minute / 60.0) - (hi.hour + hi.minute / 60.0);
	if (horasPorDia <= 0) return 'Hora fin debe ser mayor que hora inicio';
	double totalHoras = (horasPorDia * diasLaborales) - (1.0 * diasLaborales);
	if (totalHoras < 40) return 'La jornada debe sumar al menos 40 horas (descontando colación). Actualmente suma ${totalHoras.toStringAsFixed(1)} horas.';
	return null;
}

List<Widget> camposJornadaLaboral(
	Trabajador trabajador,
	Map<String, TextEditingController> controllers,
	{void Function(String error)? onCustomError}
) {
	controllers.putIfAbsent('nombre', () => TextEditingController(text: trabajador.nombreCompleto));
	controllers.putIfAbsent('rut', () => TextEditingController(text: trabajador.rut));
	controllers.putIfAbsent('dia_inicio', () => TextEditingController());
	controllers.putIfAbsent('dia_fin', () => TextEditingController());
	controllers.putIfAbsent('hora_inicio', () => TextEditingController());
	controllers.putIfAbsent('hora_fin', () => TextEditingController());
	controllers.putIfAbsent('comentario', () => TextEditingController());


		// Helper para mostrar el selector de hora
		Widget buildHoraField({required String key, required String label}) {
			return Builder(
				builder: (context) {
					return TextFormField(
						controller: controllers[key],
						readOnly: true,
						decoration: InputDecoration(
							labelText: label,
							suffixIcon: Icon(Icons.access_time),
						),
						onTap: () async {
							final picked = await showTimePicker(
								context: context,
								initialTime: TimeOfDay.now(),
							);
							if (picked != null) {
								controllers[key]!.text = picked.format(context);
							}
						},
						validator: (value) {
							if (value == null || value.isEmpty) return 'Campo obligatorio';
							return null;
						},
					);
				},
			);
		}

		// Validación personalizada de 40 horas mínimas

		return [
		TextFormField(
			controller: controllers['nombre'],
			decoration: InputDecoration(labelText: 'Nombre'),
			enabled: false,
			validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
		),
		SizedBox(height: 8),
		TextFormField(
			controller: controllers['rut'],
			decoration: InputDecoration(labelText: 'RUT'),
			enabled: false,
			validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
		),
		SizedBox(height: 8),
		Row(
			children: [
				Expanded(
					child: DropdownButtonFormField<String>(
						value: controllers['dia_inicio']!.text.isNotEmpty ? controllers['dia_inicio']!.text : null,
						decoration: InputDecoration(labelText: 'Día inicio'),
						items: diasSemana.map((dia) => DropdownMenuItem(
							value: dia,
							child: Text(dia),
						)).toList(),
						onChanged: (value) {
							controllers['dia_inicio']!.text = value ?? '';
						},
						validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
					),
				),
				SizedBox(width: 8),
				Expanded(
					child: DropdownButtonFormField<String>(
						value: controllers['dia_fin']!.text.isNotEmpty ? controllers['dia_fin']!.text : null,
						decoration: InputDecoration(labelText: 'Día fin'),
						items: diasSemana.map((dia) => DropdownMenuItem(
							value: dia,
							child: Text(dia),
						)).toList(),
						onChanged: (value) {
							controllers['dia_fin']!.text = value ?? '';
						},
						validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
					),
				),
			],
		),
		SizedBox(height: 8),
				Row(
					children: [
						Expanded(child: buildHoraField(key: 'hora_inicio', label: 'Hora inicio')),
						SizedBox(width: 8),
						Expanded(child: buildHoraField(key: 'hora_fin', label: 'Hora fin')),
					],
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
