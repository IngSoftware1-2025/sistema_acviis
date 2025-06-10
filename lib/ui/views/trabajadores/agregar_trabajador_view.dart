import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/create_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/contratos/create_contrato.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';
import 'package:sistema_acviis/ui/views/bottom_navigation_bar.dart';

class AgregarTrabajadorView extends StatefulWidget {
  const AgregarTrabajadorView({super.key});

  @override
  State<AgregarTrabajadorView> createState() => _AgregarTrabajadorViewState();
}

class _AgregarTrabajadorViewState extends State<AgregarTrabajadorView> {
  final _formKey = GlobalKey<FormState>();

  // Por razones de testing, se agregan valores iniciales
  final TextEditingController _nombreCompletoController = TextEditingController(
    text: 'Usuario${DateTime.now().millisecondsSinceEpoch % 1000} Prueba',
  );
  final TextEditingController _estadoCivilController = TextEditingController(
    text: ['Soltero', 'Casado', 'Divorciado', 'Viudo'][
      DateTime.now().millisecondsSinceEpoch % 4
    ],
  );
  final TextEditingController _rutController = TextEditingController(
    text: '${10000000 + DateTime.now().millisecondsSinceEpoch % 90000000}-${DateTime.now().millisecondsSinceEpoch % 10}',
  );
  // Fecha y email restringidos, se mantienen fijos
  final TextEditingController _fechaNacimientoController = TextEditingController(
    text: '${1980 + DateTime.now().millisecondsSinceEpoch % 30}-${(1 + DateTime.now().millisecondsSinceEpoch % 12).toString().padLeft(2, '0')}-${(1 + DateTime.now().millisecondsSinceEpoch % 28).toString().padLeft(2, '0')}',
  );
  final TextEditingController _direccionController = TextEditingController(
    text: 'Calle ${100 + DateTime.now().millisecondsSinceEpoch % 900}',
  );
  final TextEditingController _correoElectronicoController = TextEditingController(
    text: 'usuario${DateTime.now().millisecondsSinceEpoch % 10000}@email.com',
  );
  final TextEditingController _sistemaSaludController = TextEditingController(
    text: ['Fonasa', 'Isapre'][
      DateTime.now().millisecondsSinceEpoch % 2
    ],
  );
  final TextEditingController _previsionAfpController = TextEditingController(
    text: ['Provida', 'Cuprum', 'Habitat', 'PlanVital'][
      DateTime.now().millisecondsSinceEpoch % 4
    ],
  );
  final TextEditingController _obraController = TextEditingController(
    text: 'Obra ${['Norte', 'Sur', 'Este', 'Oeste'][
      DateTime.now().millisecondsSinceEpoch % 4
    ]}',
  );
  final TextEditingController _rolController = TextEditingController(
    text: ['Maestro', 'Ayudante', 'Supervisor', 'Jornal'][
      DateTime.now().millisecondsSinceEpoch % 4
    ],
  );

  bool _isLoading = false;
  bool _showContratoForm = false;

  // Controladores para el formulario de contrato
  final TextEditingController _plazoDeContratoController = TextEditingController();
  final TextEditingController _estadoContratoController = TextEditingController();
  final TextEditingController _documentoVacacionesController = TextEditingController();
  final TextEditingController _comentarioAdicionalController = TextEditingController();
  final TextEditingController _fechaContratacionController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Crear trabajador y obtener su id 
        final String trabajadorId = await createTrabajador(
          nombreCompleto: _nombreCompletoController.text,
          estadoCivil: _estadoCivilController.text,
          rut: _rutController.text,
          fechaNacimiento: DateTime.parse(_fechaNacimientoController.text),
          direccion: _direccionController.text,
          correoElectronico: _correoElectronicoController.text,
          sistemaDeSalud: _sistemaSaludController.text,
          previsionAfp: _previsionAfpController.text,
          obraEnLaQueTrabaja: _obraController.text,
          rolQueAsumeEnLaObra: _rolController.text,
        );
        // Si el formulario de contrato está visible, crear contrato SOLO en MongoDB (PDF)
        if (_showContratoForm) {
          final contratoData = {
            'plazo_de_contrato': _plazoDeContratoController.text,
            'estado': _estadoContratoController.text,
            'documento_de_vacaciones_del_trabajador': _documentoVacacionesController.text,
            'comentario_adicional_acerca_del_trabajador': _comentarioAdicionalController.text,
            'fecha_de_contratacion': _fechaContratacionController.text,
            'id_trabajadores': trabajadorId,
          };
          await createContratoMongo(contratoData, trabajadorId);
          await createContratoSupabase(contratoData, trabajadorId);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trabajador creado exitosamente')),
          );
          _formKey.currentState!.reset();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear trabajador o contrato: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalizedAppBar(title: 'Agregar trabajador/es'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCompletoController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _estadoCivilController,
                decoration: const InputDecoration(labelText: 'Estado civil'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _rutController,
                decoration: const InputDecoration(labelText: 'RUT'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: const InputDecoration(labelText: 'Fecha de nacimiento (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _correoElectronicoController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _sistemaSaludController,
                decoration: const InputDecoration(labelText: 'Sistema de salud'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _previsionAfpController,
                decoration: const InputDecoration(labelText: 'Previsión AFP'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _obraController,
                decoration: const InputDecoration(labelText: 'Obra en la que trabaja'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _rolController,
                decoration: const InputDecoration(labelText: 'Rol que asume en la obra'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showContratoForm = !_showContratoForm;
                  });
                },
                child: Text(_showContratoForm ? 'Ocultar contrato' : 'Generar contrato'),
              ),
              if (_showContratoForm) ...[
                const SizedBox(height: 16),
                Text('Datos del contrato', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _plazoDeContratoController,
                  decoration: const InputDecoration(labelText: 'Plazo de contrato'),
                  validator: (value) {
                    if (!_showContratoForm) return null;
                    return value == null || value.isEmpty ? 'Campo requerido' : null;
                  },
                ),
                TextFormField(
                  controller: _estadoContratoController,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  validator: (value) {
                    if (!_showContratoForm) return null;
                    return value == null || value.isEmpty ? 'Campo requerido' : null;
                  },
                ),
                TextFormField(
                  controller: _documentoVacacionesController,
                  decoration: const InputDecoration(labelText: 'Documento de vacaciones del trabajador'),
                  validator: (value) {
                    if (!_showContratoForm) return null;
                    return value == null || value.isEmpty ? 'Campo requerido' : null;
                  },
                ),
                TextFormField(
                  controller: _comentarioAdicionalController,
                  decoration: const InputDecoration(labelText: 'Comentario adicional acerca del trabajador'),
                  validator: (value) {
                    if (!_showContratoForm) return null;
                    return value == null || value.isEmpty ? 'Campo requerido' : null;
                  },
                ),
                TextFormField(
                  controller: _fechaContratacionController,
                  decoration: const InputDecoration(labelText: 'Fecha de contratación (YYYY-MM-DD)'),
                  validator: (value) {
                    if (!_showContratoForm) return null;
                    if (value == null || value.isEmpty) return 'Campo requerido';
                    try {
                      DateTime.parse(value);
                    } catch (_) {
                      return 'Formato inválido (YYYY-MM-DD)';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Guardar trabajador'),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBottomBar(),
    );
  }
}
