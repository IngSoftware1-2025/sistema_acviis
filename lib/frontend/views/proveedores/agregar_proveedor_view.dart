import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/create_proveedor.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:uuid/uuid.dart'; // Agrega esto arriba

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
                onPressed: () async {
                  final nuevoProveedor = Proveedor(
                    id: const Uuid().v4(), // Genera un UUID único
                    nombre: _nombreController.text,
                    rut: _rutController.text,
                    direccion: _direccionController.text,
                    correoElectronico: _correoController.text,
                    telefono: _telefonoController.text,
                    estado: 'Activo',
                    fechaRegistro: DateTime.now(), // Usa DateTime, no String
                  );
                  final exito = await Provider.of<ProveedoresProvider>(context, listen: false)
                      .agregarProveedor(nuevoProveedor);
                  if (exito) {
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al registrar proveedor')),
                    );
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