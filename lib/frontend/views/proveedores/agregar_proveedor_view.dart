import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:uuid/uuid.dart';

class AgregarProveedorView extends StatefulWidget {
  const AgregarProveedorView({super.key});

  @override
  State<AgregarProveedorView> createState() => _AgregarProveedorViewState();
}

class _AgregarProveedorViewState extends State<AgregarProveedorView> {
  final _formKey = GlobalKey<FormState>();
  final _rutController = TextEditingController();
  final _direccionController = TextEditingController();
  final _nombreVendedorController = TextEditingController();
  final _productoServicioController = TextEditingController();
  final _correoVendedorController = TextEditingController();
  final _telefonoVendedorController = TextEditingController();
  final _creditoDisponibleController = TextEditingController();

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
      appBar: AppBar(title: const Text('Agregar Proveedor')),
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
                  // Expresión regular para validar el formato XXXXXXXX-X (o K)
                  final rutRegExp = RegExp(r'^\d{8}-[0-9kK]$', caseSensitive: false);
                  if (!rutRegExp.hasMatch(v)) {
                    return 'Formato de RUT inválido (ej: 12345678-9)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección (región, ciudad, comuna, casa)'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese la dirección' : null,
              ),
              TextFormField(
                controller: _nombreVendedorController,
                decoration: const InputDecoration(labelText: 'Nombre completo del vendedor'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre del vendedor' : null,
              ),
              TextFormField(
                controller: _productoServicioController,
                decoration: const InputDecoration(labelText: 'Producto o servicio'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el producto o servicio' : null,
              ),
              TextFormField(
                controller: _correoVendedorController,
                decoration: const InputDecoration(labelText: 'Correo del vendedor'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingrese el correo';
                  }
                  // Expresión regular para validar un formato de correo general.
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
                decoration: const InputDecoration(labelText: 'Crédito disponible (pesos chilenos)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el crédito disponible' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final proveedor = Proveedor(
                      id: const Uuid().v4(),
                      rut: _rutController.text,
                      direccion: _direccionController.text,
                      nombreVendedor: _nombreVendedorController.text,
                      productoServicio: _productoServicioController.text,
                      correoVendedor: _correoVendedorController.text,
                      telefonoVendedor: '+56 9 ${_telefonoVendedorController.text}',
                      creditoDisponible: int.tryParse(_creditoDisponibleController.text) ?? 0,
                      fechaRegistro: DateTime.now(),
                    );
                    final exito = await Provider.of<ProveedoresProvider>(context, listen: false)
                        .agregarProveedor(proveedor);
                    if (exito) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al registrar proveedor')),
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