import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/itemizados_provider.dart';
import 'package:sistema_acviis/backend/controllers/ordenes/create_ordenes.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';

class AgregarOrdenesView extends StatefulWidget {
  const AgregarOrdenesView({super.key});

  @override
  State<AgregarOrdenesView> createState() => _AgregarOrdenesViewState();
}

class _AgregarOrdenesViewState extends State<AgregarOrdenesView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numeroOrdenController = TextEditingController();
  final TextEditingController _fechaEmisionController = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  final TextEditingController _proveedorIdController = TextEditingController();
  final TextEditingController _centroCostoController = TextEditingController();
  final TextEditingController _numeroCotizacionController = TextEditingController();
  final TextEditingController _numeroContactoController = TextEditingController();
  final TextEditingController _nombreServicioController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _notasAdicionalesController = TextEditingController();

  String? _selectedItemizadoId;
  bool _descuentoSwitch = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final proveedorProvider = Provider.of<ProveedoresProvider>(context, listen: false);
    proveedorProvider.precargarProveedores();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemizadosProvider = Provider.of<ItemizadosProvider>(context, listen: false);
      itemizadosProvider.precargarItemizados();
    });
  }

  void _submitFormOrden() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedItemizadoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar un itemizado')),
        );
        return;
      }
      setState(() => _isLoading = true);

      try {
        final ordenesProvider = Provider.of<OrdenesProvider>(context, listen: false);
        final itemizadosProvider = Provider.of<ItemizadosProvider>(context, listen: false);

        await createOrden(
          numeroOrden: _numeroOrdenController.text,
          fechaEmision: DateTime.parse(_fechaEmisionController.text),
          proveedorId: _proveedorIdController.text,
          centroCosto: _centroCostoController.text,
          itemizadoId: _selectedItemizadoId!,
          numeroCotizacion: _numeroCotizacionController.text.isNotEmpty
              ? _numeroCotizacionController.text
              : '',
          numeroContacto: _numeroContactoController.text.isNotEmpty
              ? _numeroContactoController.text
              : '',
          nombreServicio: _nombreServicioController.text,
          valor: int.parse(_valorController.text),
          descuento: _descuentoSwitch,
          notasAdicionales: _notasAdicionalesController.text.isNotEmpty
              ? _notasAdicionalesController.text
              : null,
        );

        // ✅ refrescar órdenes e itemizados después de crear
        await ordenesProvider.fetchOrdenes();
        await itemizadosProvider.fetchItemizados();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Orden agregada exitosamente')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home_page/logistica_view/ordenes_view',
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar orden: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Agregar Orden de Compra',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _numeroOrdenController,
                decoration: const InputDecoration(labelText: 'Número de orden'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _fechaEmisionController,
                decoration: const InputDecoration(labelText: 'Fecha de emisión (YYYY-MM-DD)'),
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
              // Dropdown de Proveedores
              Consumer<ProveedoresProvider>(
                builder: (context, proveedorProvider, child) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Proveedor'),
                    value: _proveedorIdController.text.isNotEmpty
                        ? _proveedorIdController.text
                        : null,
                    items: proveedorProvider.proveedores.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.nombre_vendedor),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _proveedorIdController.text = value ?? '';
                      });
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  );
                },
              ),
              TextFormField(
                controller: _centroCostoController,
                decoration: const InputDecoration(labelText: 'Centro de costo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              Consumer<ItemizadosProvider>(
                builder: (context, itemizadosProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Itemizado'),
                        value: _selectedItemizadoId,
                        items: itemizadosProvider.itemizados.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.nombre),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedItemizadoId = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                      ),
                      if (_selectedItemizadoId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Builder(
                            builder: (context) {
                              final item = itemizadosProvider.itemizados.firstWhere(
                                (i) => i.id == _selectedItemizadoId,
                              );
                              return Text(
                                'Monto disponible: ${item.montoDisponible}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
              TextFormField(
                controller: _numeroCotizacionController,
                decoration: const InputDecoration(labelText: 'Número de cotización (opcional)'),
              ),
              TextFormField(
                controller: _numeroContactoController,
                decoration: const InputDecoration(labelText: 'Número de contacto (opcional)'),
              ),
              TextFormField(
                controller: _nombreServicioController,
                decoration: const InputDecoration(labelText: 'Nombre del servicio'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número entero';
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('¿Aplicar descuento?'),
                value: _descuentoSwitch,
                onChanged: (value) => setState(() => _descuentoSwitch = value),
              ),
              TextFormField(
                controller: _notasAdicionalesController,
                decoration: const InputDecoration(labelText: 'Notas adicionales (opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitFormOrden,
                      child: const Text('Guardar orden'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
