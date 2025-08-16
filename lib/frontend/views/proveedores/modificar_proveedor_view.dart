import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:provider/provider.dart';

class ModificarProveedorView extends StatefulWidget {
  final Proveedor proveedor;
  const ModificarProveedorView({super.key, required this.proveedor});

  @override
  State<ModificarProveedorView> createState() => _ModificarProveedorViewState();
}

class _ModificarProveedorViewState extends State<ModificarProveedorView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _rutController;
  late TextEditingController _direccionController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  String _estado = 'Activo';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.proveedor.nombre);
    _rutController = TextEditingController(text: widget.proveedor.rut);
    _direccionController = TextEditingController(text: widget.proveedor.direccion);
    _correoController = TextEditingController(text: widget.proveedor.correoElectronico);
    _telefonoController = TextEditingController(text: widget.proveedor.telefono);
    _estado = widget.proveedor.estado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modificar Proveedor')),
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
              DropdownButtonFormField<String>(
                value: _estado,
                items: const [
                  DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                ],
                onChanged: (v) => setState(() => _estado = v ?? 'Activo'),
                decoration: const InputDecoration(labelText: 'Estado'),
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
                            'estado': _estado,
                          };
                          final exito = await Provider.of<ProveedoresProvider>(context, listen: false)
                              .actualizarProveedor(widget.proveedor.id, data);
                          setState(() => _isLoading = false);
                          if (exito && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Proveedor modificado correctamente')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al modificar proveedor')),
                            );
                          }
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}