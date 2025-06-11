import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/ui/widgets/scaffold.dart';


class ModificarTrabajadoresView extends StatefulWidget {
  final Object? trabajadores; // Por temas practicos es Object, pero deberia ser List<Trabajadores>
  const ModificarTrabajadoresView({
    super.key,
    required this.trabajadores
  });
  @override
  State<ModificarTrabajadoresView> createState() => _ModificarTrabajadoresViewState();
}

class _ModificarTrabajadoresViewState extends State<ModificarTrabajadoresView> {
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
          // Contrato
          'plazoDeContrato': TextEditingController(text: contrato['plazo_de_contrato']?.toString() ?? ''),
          'estadoContrato': TextEditingController(text: contrato['estado']?.toString() ?? ''),
          'documentoVacaciones': TextEditingController(text: contrato['documento_de_vacaciones_del_trabajador']?.toString() ?? ''),
          'comentarioAdicional': TextEditingController(text: contrato['comentario_adicional_acerca_del_trabajador']?.toString() ?? ''),
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
                      // --- DATOS DE CONTRATO ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['plazoDeContrato'],
                          decoration: const InputDecoration(labelText: 'Plazo de Contrato'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: estadoContratoActual,
                          decoration: const InputDecoration(
                            labelText: 'Estado (Contrato)',
                          ),
                          items: estadosContrato
                              .map((estado) => DropdownMenuItem(
                                    value: estado,
                                    child: Text(estado),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              c['estadoContrato']!.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['documentoVacaciones'],
                          decoration: const InputDecoration(labelText: 'Documento de Vacaciones'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['comentarioAdicional'],
                          decoration: const InputDecoration(labelText: 'Comentario Adicional'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          enabled: false,
                          controller: c['fechaContratacion'],
                          decoration: const InputDecoration(labelText: 'Fecha de Contratación'),
                        ),
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