import 'package:flutter/material.dart';
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
    _telefonoVendedorController = TextEditingController(text: widget.proveedor.telefonoVendedor);
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
          child: ListView(
            children: [
              TextFormField(
                controller: _rutController,
                decoration: const InputDecoration(labelText: 'RUT (XXXXXXXX-X)'),
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextFormField(
                controller: _nombreVendedorController,
                decoration: const InputDecoration(labelText: 'Nombre vendedor'),
              ),
              TextFormField(
                controller: _productoServicioController,
                decoration: const InputDecoration(labelText: 'Producto o servicio'),
              ),
              TextFormField(
                controller: _correoVendedorController,
                decoration: const InputDecoration(labelText: 'Correo vendedor'),
              ),
              TextFormField(
                controller: _telefonoVendedorController,
                decoration: const InputDecoration(labelText: 'Teléfono vendedor'),
              ),
              TextFormField(
                controller: _creditoDisponibleController,
                decoration: const InputDecoration(labelText: 'Crédito disponible'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Guardar cambios'),
                onPressed: () async {
                  final data = {
                    'rut': _rutController.text,
                    'direccion': _direccionController.text,
                    'nombre_vendedor': _nombreVendedorController.text,
                    'producto_servicio': _productoServicioController.text,
                    'correo_vendedor': _correoVendedorController.text,
                    'telefono_vendedor': _telefonoVendedorController.text,
                    'credito_disponible': int.tryParse(_creditoDisponibleController.text) ?? 0,
                  };
                  final exito = await Provider.of<ProveedoresProvider>(context, listen: false)
                      .actualizarProveedor(widget.proveedor.id, data);
                  if (exito) {
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al modificar proveedor')),
                    );
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