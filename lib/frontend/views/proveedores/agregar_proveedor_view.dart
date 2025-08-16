import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/create_proveedor.dart';

class AgregarProveedorView extends StatefulWidget {
  const AgregarProveedorView({super.key});

  @override
  State<AgregarProveedorView> createState() => _AgregarProveedorViewState();
}

class _AgregarProveedorViewState extends State<AgregarProveedorView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _rutController = TextEditingController();
  final _direccionController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Proveedor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _rutController,
                decoration: const InputDecoration(labelText: 'RUT'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          final data = {
                            'nombre': _nombreController.text,
                            'rut': _rutController.text,
                            'direccion': _direccionController.text,
                            'correo_electronico': _correoController.text,
                            'telefono': _telefonoController.text,
                            'estado': 'Activo',
                            'fecha_registro': DateTime.now().toIso8601String(),
                          };
                          final exito = await createProveedor(data);
                          setState(() => _isLoading = false);
                          if (exito && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Proveedor registrado correctamente')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al registrar proveedor')),
                            );
                          }
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}