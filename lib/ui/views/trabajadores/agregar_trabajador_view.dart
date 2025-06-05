import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/create_trabajador.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';
import 'package:sistema_acviis/ui/views/bottom_navigation_bar.dart';

class AgregarTrabajadorView extends StatefulWidget {
  const AgregarTrabajadorView({super.key});

  @override
  State<AgregarTrabajadorView> createState() => _AgregarTrabajadorViewState();
}

class _AgregarTrabajadorViewState extends State<AgregarTrabajadorView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _estadoCivilController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _correoElectronicoController = TextEditingController();
  final TextEditingController _sistemaSaludController = TextEditingController();
  final TextEditingController _previsionAfpController = TextEditingController();
  final TextEditingController _obraController = TextEditingController();
  final TextEditingController _rolController = TextEditingController();

  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await createTrabajador(
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trabajador creado exitosamente')),
          );
          _formKey.currentState!.reset();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear trabajador: $e')),
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
