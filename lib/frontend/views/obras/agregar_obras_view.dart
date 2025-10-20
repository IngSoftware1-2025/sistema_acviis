import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/backend/controllers/obras/create_obra.dart';

class AgregarObrasView extends StatefulWidget {
  const AgregarObrasView({super.key});

  @override
  State<AgregarObrasView> createState() => _AgregarObrasViewState();
}

class _AgregarObrasViewState extends State<AgregarObrasView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _responsableEmailController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _obraInicioController = TextEditingController();
  final TextEditingController _obraFinController = TextEditingController();
  final TextEditingController _jornadaController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    // Limpiar controladores al salir
    _nombreController.dispose();
    _descripcionController.dispose();
    _responsableEmailController.dispose();
    _direccionController.dispose();
    _obraInicioController.dispose();
    _obraFinController.dispose();
    _jornadaController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Convertir fechas a DateTime si existen
        DateTime? obraInicio;
        if (_obraInicioController.text.isNotEmpty) {
          obraInicio = DateTime.parse(_obraInicioController.text);
        }
        
        DateTime? obraFin;
        if (_obraFinController.text.isNotEmpty) {
          obraFin = DateTime.parse(_obraFinController.text);
        }

        // Llamar al controlador para crear la obra
        final result = await createObra(
          nombre: _nombreController.text,
          descripcion: _descripcionController.text,
          responsableEmail: _responsableEmailController.text,
          direccion: _direccionController.text,
          obraInicio: obraInicio,
          obraFin: obraFin,
          jornada: _jornadaController.text,
        );

        if (mounted) {
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Obra creada exitosamente')),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home_page/obras_view',
              (Route<dynamic> route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${result['error']}')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear obra: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Agregar obra',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la obra',
                  hintText: 'Ingrese el nombre de la obra',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Descripción de la obra (opcional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _responsableEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email del responsable',
                  hintText: 'correo@ejemplo.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return null; // Es opcional
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  return emailRegex.hasMatch(value) ? null : 'Ingrese un email válido';
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  hintText: 'Ingrese la dirección de la obra',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'La dirección es requerida' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _obraInicioController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de inicio (YYYY-MM-DD)',
                  hintText: 'Ej. 2025-10-15',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null; // Opcional
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _obraFinController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de finalización (YYYY-MM-DD)',
                  hintText: 'Ej. 2026-02-28',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null; // Opcional
                  try {
                    final fechaFin = DateTime.parse(value);
                    if (_obraInicioController.text.isNotEmpty) {
                      final fechaInicio = DateTime.parse(_obraInicioController.text);
                      if (fechaFin.isBefore(fechaInicio)) {
                        return 'La fecha de fin debe ser posterior a la fecha de inicio';
                      }
                    }
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _jornadaController,
                decoration: const InputDecoration(
                  labelText: 'Jornada',
                  hintText: 'Diurna/Vespertina/Nocturna',
                ),
              ),
              const SizedBox(height: 24),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Guardar obra',
                      onPressed: _submitForm,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}