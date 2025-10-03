import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';

class ModificarProveedorView extends StatefulWidget {
  final Proveedor proveedor;
  const ModificarProveedorView({super.key, required this.proveedor});

  @override
  State<ModificarProveedorView> createState() => _ModificarProveedorViewState();
}

class _ModificarProveedorViewState extends State<ModificarProveedorView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _rutController;
  late TextEditingController _direccionController;
  late TextEditingController _nombreVendedorController;
  late TextEditingController _productoServicioController;
  late TextEditingController _correoVendedorController;
  late TextEditingController _telefonoVendedorController;
  late TextEditingController _creditoDisponibleController;

  @override
  void initState() {
    super.initState();
    _rutController = TextEditingController(text: widget.proveedor.rut);
    _direccionController = TextEditingController(text: widget.proveedor.direccion);
    _nombreVendedorController = TextEditingController(text: widget.proveedor.nombreVendedor);
    _productoServicioController = TextEditingController(text: widget.proveedor.productoServicio);
    _correoVendedorController = TextEditingController(text: widget.proveedor.correoVendedor);
    // Extraemos solo los 8 dígitos del número de teléfono
    final telefono = widget.proveedor.telefonoVendedor.replaceAll('+56 9 ', '');
    _telefonoVendedorController = TextEditingController(text: telefono);
    _creditoDisponibleController = TextEditingController(text: widget.proveedor.creditoDisponible.toString());
  }

  @override
  void dispose() {
    _rutController.dispose();
    _direccionController.dispose();
    _nombreVendedorController.dispose();
    _productoServicioController.dispose();
    _correoVendedorController.dispose();
    _telefonoVendedorController.dispose();
    _creditoDisponibleController.dispose();
    super.dispose();
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
                controller: _rutController,
                decoration: const InputDecoration(labelText: 'RUT (XXXXXXXX-X)'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingrese el RUT';
                  }
                  final rutRegExp = RegExp(r'^\d{8}-[0-9kK]$', caseSensitive: false);
                  if (!rutRegExp.hasMatch(v)) {
                    return 'Formato de RUT inválido (ej: 12345678-9)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese la dirección' : null,
              ),
              TextFormField(
                controller: _nombreVendedorController,
                decoration: const InputDecoration(labelText: 'Nombre vendedor'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre del vendedor' : null,
              ),
              TextFormField(
                controller: _productoServicioController,
                decoration: const InputDecoration(labelText: 'Producto o servicio'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el producto o servicio' : null,
              ),
              TextFormField(
                controller: _correoVendedorController,
                decoration: const InputDecoration(labelText: 'Correo vendedor'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingrese el correo';
                  }
                  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegExp.hasMatch(v)) {
                    return 'Formato de correo inválido (ej: correo@dominio.com)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefonoVendedorController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono del vendedor',
                  prefixText: '+56 9 ',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingrese el número';
                  }
                  if (v.length != 8) {
                    return 'El número debe tener 8 dígitos';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _creditoDisponibleController,
                decoration: const InputDecoration(labelText: 'Crédito disponible'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el crédito disponible' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Guardar cambios'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'rut': _rutController.text,
                      'direccion': _direccionController.text,
                      'nombre_vendedor': _nombreVendedorController.text,
                      'producto_servicio': _productoServicioController.text,
                      'correo_vendedor': _correoVendedorController.text,
                      'telefono_vendedor': '+56 9 ${_telefonoVendedorController.text}',
                      'credito_disponible': int.tryParse(_creditoDisponibleController.text) ?? 0,
                    };
                    final exito = await Provider.of<ProveedoresProvider>(context, listen: false)
                        .actualizarProveedor(widget.proveedor.id, data);

                    //if (!context.mounted) return; // <-- SOLUCIÓN: Verificar si el widget sigue montado

                    if (exito) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al modificar proveedor')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}