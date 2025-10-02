import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/ordenes.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';

class ModificarOrdenesView extends StatefulWidget {
  final List<OrdenCompra> ordenes;
  const ModificarOrdenesView({super.key, required this.ordenes});

  @override
  State<ModificarOrdenesView> createState() => _ModificarOrdenesViewState();
}

class _ModificarOrdenesViewState extends State<ModificarOrdenesView> {
  late List<Map<String, dynamic>> _controllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<ProveedoresProvider>(context, listen: false).precargarProveedores();

    _controllers = widget.ordenes.map((orden) {
      return {
        'id': orden.id,
        'numeroOrdenController': TextEditingController(text: orden.numeroOrden),
        'fechaEmisionController': TextEditingController(text: orden.fechaEmision.toIso8601String().split('T')[0]),
        'proveedorIdController': TextEditingController(text: orden.proveedorId),
        'centroCostoController': TextEditingController(text: orden.centroCosto),
        'seccionItemizadoController': TextEditingController(text: orden.seccionItemizado ?? ''),
        'numeroCotizacionController': TextEditingController(text: orden.numeroCotizacion ?? ''),
        'numeroContactoController': TextEditingController(text: orden.numeroContacto ?? ''),
        'nombreServicioController': TextEditingController(text: orden.nombreServicio),
        'valorController': TextEditingController(text: orden.valor.toString()),
        'notasAdicionalesController': TextEditingController(text: orden.notasAdicionales ?? ''),
        'descuentoSwitch': orden.descuento,
      };
    }).toList();
  }

  Future<void> _submitFormOrden(int index) async {
    setState(() => _isLoading = true);
    final ordenController = _controllers[index];

    try {
      final data = {
        'numero_orden': ordenController['numeroOrdenController'].text,
        'fecha_emision': ordenController['fechaEmisionController'].text,
        'proveedor_id': ordenController['proveedorIdController'].text,
        'centro_costo': ordenController['centroCostoController'].text,
        'seccion_itemizado': ordenController['seccionItemizadoController'].text,
        'numero_cotizacion': ordenController['numeroCotizacionController'].text,
        'numero_contacto': ordenController['numeroContactoController'].text,
        'nombre_servicio': ordenController['nombreServicioController'].text,
        'valor': int.parse(ordenController['valorController'].text),
        'descuento': ordenController['descuentoSwitch'],
        'notas_adicionales': ordenController['notasAdicionalesController'].text,
      };

      final exito = await Provider.of<OrdenesProvider>(context, listen: false)
          .actualizarOrden(ordenController['id'], data);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Orden ${ordenController['numeroOrdenController'].text} actualizada')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la orden ${ordenController['numeroOrdenController'].text}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Modificar Órdenes de Compra',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.ordenes.length,
              itemBuilder: (context, index) {
                final orden = widget.ordenes[index];
                final c = _controllers[index];

                return Card(
                  margin: const EdgeInsets.all(16),
                  child: ExpansionTile(
                    title: Text('Orden: ${orden.numeroOrden}'),
                    subtitle: Text('Proveedor: ${orden.proveedor.nombre_vendedor}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(controller: c['numeroOrdenController'], decoration: const InputDecoration(labelText: 'Número de orden')),
                            TextFormField(controller: c['fechaEmisionController'], decoration: const InputDecoration(labelText: 'Fecha de emisión (YYYY-MM-DD)')),
                            Consumer<ProveedoresProvider>(
                              builder: (context, prov, _) => DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Proveedor'),
                                value: c['proveedorIdController'].text,
                                items: prov.proveedores.map((p) => DropdownMenuItem<String>(value: p.id, child: Text(p.nombre_vendedor))).toList(),
                                onChanged: (value) => setState(() => c['proveedorIdController'].text = value ?? ''),
                              ),
                            ),
                            TextFormField(controller: c['centroCostoController'], decoration: const InputDecoration(labelText: 'Centro de costo')),
                            TextFormField(controller: c['seccionItemizadoController'], decoration: const InputDecoration(labelText: 'Sección itemizado')),
                            TextFormField(controller: c['nombreServicioController'], decoration: const InputDecoration(labelText: 'Nombre del servicio')),
                            TextFormField(controller: c['valorController'], decoration: const InputDecoration(labelText: 'Valor'), keyboardType: TextInputType.number),
                            SwitchListTile(
                              title: const Text('¿Aplicar descuento?'),
                              value: c['descuentoSwitch'],
                              onChanged: (value) => setState(() => c['descuentoSwitch'] = value),
                            ),
                            TextFormField(controller: c['notasAdicionalesController'], decoration: const InputDecoration(labelText: 'Notas adicionales'), maxLines: 2),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => _submitFormOrden(index),
                              child: const Text('Guardar Cambios'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}