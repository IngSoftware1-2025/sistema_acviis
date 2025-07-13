import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';


class ModificarTrabajadoresView extends StatefulWidget {
  final Object? trabajadores; // Por temas practicos es Object, pero deberia ser List<Trabajadores>
  const ModificarTrabajadoresView({
    super.key,
    required this.trabajadores
  });
  @override
  State<ModificarTrabajadoresView> createState() => _ModificarTrabajadoresViewState();
  // Dummy implementation for updateTrabajador
  Future<void> updateTrabajador(Map<String, dynamic> trabajadorData) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Dummy implementation for updateContrato
  Future<void> updateContrato(Map<String, dynamic> contratoData, int trabajadorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class _ModificarTrabajadoresViewState extends State<ModificarTrabajadoresView> {
  // Dummy implementation for createContratoMongo
  Future<void> createContratoMongo(Map<String, dynamic> contratoData, int trabajadorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Dummy implementation for createContratoSupabase
  Future<void> createContratoSupabase(Map<String, dynamic> contratoData, String trabajadorId) async {
  await Future.delayed(const Duration(milliseconds: 500));
}

  @override
  Widget build(BuildContext context) {
    final List<Trabajador> trabajadores = (widget.trabajadores as List).cast<Trabajador>();

    // Opciones para los dropdowns
    final estadoCivilOptions = ['Soltero', 'Casado'];
    final sistemaSaludOptions = ['Isapre', 'Fonasa'];
    final previsionAfpOptions = ['Cuprum', 'Provida', 'Habitat', 'PlanVital'];
    final obras = ['Obra Norte', 'Obra Sur', 'Obra Este', 'Obra Oeste'];
    final roles = ['Ayudante', 'Maestro', 'Oficina tecnica', 'Electricista', 'Jornal'];
    final estadosContrato = ['Activo', 'Inactivo', 'Despedido', 'Renuncio'];

    // Controladores para cada trabajador y campo
    final List<Map<String, TextEditingController>> controllers = List.generate(
      trabajadores.length,
      (i) {
        final contrato = trabajadores[i].contratos.isNotEmpty ? trabajadores[i].contratos.last : {};
        return {
          'nombreCompleto': TextEditingController(text: trabajadores[i].nombreCompleto),
          'estadoCivil': TextEditingController(text: trabajadores[i].estadoCivil),
          'rut': TextEditingController(text: trabajadores[i].rut),
          'fechaDeNacimiento': TextEditingController(text: trabajadores[i].fechaDeNacimiento.toLocal().toString().split(' ')[0]),
          'direccion': TextEditingController(text: trabajadores[i].direccion),
          'correoElectronico': TextEditingController(text: trabajadores[i].correoElectronico ?? ''),
          'sistemaDeSalud': TextEditingController(text: trabajadores[i].sistemaDeSalud ?? ''),
          'previsionAfp': TextEditingController(text: trabajadores[i].previsionAfp ?? ''),
          'obraEnLaQueTrabaja': TextEditingController(text: trabajadores[i].obraEnLaQueTrabaja ?? ''),
          'rolQueAsumeEnLaObra': TextEditingController(text: trabajadores[i].rolQueAsumeEnLaObra ?? ''),
          'estado': TextEditingController(text: trabajadores[i].estado ?? ''),
          // Contrato
          'plazoDeContrato': TextEditingController(text: contrato['plazo_de_contrato']?.toString() ?? ''),
          'estadoContrato': TextEditingController(text: contrato['estado']?.toString() ?? ''),
          'fechaContratacion': TextEditingController(
            text: contrato['fecha_de_contratacion'] != null
                ? contrato['fecha_de_contratacion'].toString().split('T').first
                : '',
          ),
        };
      },
    );

    return PrimaryScaffold(
      title: 'Modificar Trabajadores',
      body: ListView.builder(
        itemCount: trabajadores.length,
        itemBuilder: (context, index) {
          final t = trabajadores[index];
          final c = controllers[index];

          // Valores actuales para los dropdowns (si no está, usa el primero)
          final estadoCivilActual = estadoCivilOptions.contains(c['estadoCivil']!.text)
              ? c['estadoCivil']!.text
              : estadoCivilOptions.first;
          final sistemaSaludActual = sistemaSaludOptions.contains(c['sistemaDeSalud']!.text)
              ? c['sistemaDeSalud']!.text
              : sistemaSaludOptions.first;
          final previsionAfpActual = previsionAfpOptions.contains(c['previsionAfp']!.text)
              ? c['previsionAfp']!.text
              : previsionAfpOptions.first;
          final obraActual = obras.contains(c['obraEnLaQueTrabaja']!.text)
              ? c['obraEnLaQueTrabaja']!.text
              : obras.first;
          final rolActual = roles.contains(c['rolQueAsumeEnLaObra']!.text)
              ? c['rolQueAsumeEnLaObra']!.text
              : roles.first;
          final estadoContratoActual = estadosContrato.contains(c['estadoContrato']!.text)
              ? c['estadoContrato']!.text
              : estadosContrato.first;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              title: Text(t.nombreCompleto),
              subtitle: Text('ID: ${t.id}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: c['nombreCompleto'],
                        decoration: const InputDecoration(labelText: 'Nombre Completo'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: estadoCivilActual,
                          decoration: const InputDecoration(labelText: 'Estado Civil'),
                          items: estadoCivilOptions
                              .map((ec) => DropdownMenuItem(value: ec, child: Text(ec)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              c['estadoCivil']!.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      TextField(
                        enabled: false,
                        controller: c['rut'],
                        decoration: const InputDecoration(labelText: 'RUT'),
                      ),
                      TextField(
                        enabled: false,
                        controller: c['fechaDeNacimiento'],
                        decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
                      ),
                      TextField(
                        controller: c['direccion'],
                        decoration: const InputDecoration(labelText: 'Dirección'),
                      ),
                      TextField(
                        controller: c['correoElectronico'],
                        decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: sistemaSaludActual,
                          decoration: const InputDecoration(labelText: 'Sistema de Salud'),
                          items: sistemaSaludOptions
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              c['sistemaDeSalud']!.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: previsionAfpActual,
                          decoration: const InputDecoration(labelText: 'Previsión AFP'),
                          items: previsionAfpOptions
                              .map((afp) => DropdownMenuItem(value: afp, child: Text(afp)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              c['previsionAfp']!.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField(
                          value: obraActual,
                          decoration: const InputDecoration(
                            labelText: 'Obra en la que trabaja',
                          ),
                          items: obras
                              .map((obra) => DropdownMenuItem(
                                    value: obra,
                                    child: Text(obra),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              c['obraEnLaQueTrabaja']!.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField(
                          value: rolActual,
                          decoration: const InputDecoration(
                            labelText: 'Rol que asume en la obra'
                          ),
                          items: roles
                              .map((rol) => DropdownMenuItem(
                                    value: rol,
                                    child: Text(rol),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              c['rolQueAsumeEnLaObra']!.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: estadosContrato.contains(c['estado']!.text) ? c['estado']!.text : estadosContrato.first,
                          decoration: const InputDecoration(labelText: 'Estado'),
                          items: estadosContrato
                              .map((estado) => DropdownMenuItem(
                                    value: estado,
                                    child: Text(estado),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              c['estado']!.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      
                      // --- DATOS DE CONTRATO ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validación simple: todos los campos de contrato deben estar completos
                            if (c['plazoDeContrato']!.text.isEmpty ||
                                c['estadoContrato']!.text.isEmpty ||
                                c['fechaContratacion']!.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Completa todos los datos del contrato')),
                              );
                              return;
                            }
                            // Validar formato de fecha
                            try {
                              DateTime.parse(c['fechaContratacion']!.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Formato de fecha inválido (YYYY-MM-DD)')),
                              );
                              return;
                            }

                            final trabajadorData = {
                              'id': t.id,
                              'nombre_completo': c['nombreCompleto']!.text,
                              'estado_civil': c['estadoCivil']!.text,
                              'rut': c['rut']!.text,
                              'fecha_nacimiento': c['fechaDeNacimiento']!.text,
                              'direccion': c['direccion']!.text,
                              'correo_electronico': c['correoElectronico']!.text,
                              'sistema_de_salud': c['sistemaDeSalud']!.text,
                              'prevision_afp': c['previsionAfp']!.text,
                              'obra_en_la_que_trabaja': c['obraEnLaQueTrabaja']!.text,
                              'rol_que_asume_en_la_obra': c['rolQueAsumeEnLaObra']!.text,
                              'estado': c['estado']!.text,
                            };

                            final contratoData = {
                              'plazo_de_contrato': c['plazoDeContrato']!.text,
                              'estado': c['estadoContrato']!.text,
                              'fecha_de_contratacion': c['fechaContratacion']!.text,
                              'id_trabajadores': t.id,
                            };

                            await widget.updateTrabajador(trabajadorData);

                            // Aquí se crea una nueva fila en la tabla contratos de Supabase
                            await createContratoSupabase(contratoData, t.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Trabajador y contrato actualizados')),
                            );
                            setState(() {});
                          },
                          child: const Text('Guardar cambios'),
                        ),
                      ),

                        // Campos de contrato
                        TextField(
                          controller: c['plazoDeContrato'],
                          decoration: const InputDecoration(labelText: 'Plazo de Contrato'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: DropdownButtonFormField<String>(
                            value: estadoContratoActual,
                            decoration: const InputDecoration(labelText: 'Estado del Contrato'),
                            items: estadosContrato
                                .map((estado) => DropdownMenuItem(value: estado, child: Text(estado)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                c['estadoContrato']!.text = value ?? '';
                              });
                            },
                          ),
                        ),
                        TextField(
                          controller: c['fechaContratacion'],
                          decoration: const InputDecoration(labelText: 'Fecha de Contratación (YYYY-MM-DD)'),
                        ),
                      ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}