import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/ordenes.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:sistema_acviis/providers/itemizados_provider.dart';
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
    Provider.of<ProveedoresProvider>(context, listen: false)
        .precargarProveedores();
    Provider.of<ItemizadosProvider>(context, listen: false)
        .precargarItemizados();

    _controllers = widget.ordenes.map((orden) {
      return {
        'id': orden.id,
        'numeroOrdenController':
            TextEditingController(text: orden.numeroOrden),
        'fechaEmisionController': TextEditingController(
          text: orden.fechaEmision.toIso8601String().split('T')[0],
        ),
        'proveedorIdController':
            TextEditingController(text: orden.proveedorId),
        'centroCostoController':
            TextEditingController(text: orden.centroCosto),
        'seccionItemizadoController':
            TextEditingController(text: orden.itemizado.id),
        'numeroCotizacionController':
            TextEditingController(text: orden.numeroCotizacion),
        'numeroContactoController':
            TextEditingController(text: orden.numeroContacto ?? ''),
        'nombreServicioController':
            TextEditingController(text: orden.nombreServicio),
        'valorController':
            TextEditingController(text: orden.valor.toString()),
        'notasAdicionalesController':
            TextEditingController(text: orden.notasAdicionales ?? ''),
        'descuentoSwitch': orden.descuento,
      };
    }).toList();
  }

  Future<void> _submitFormOrden(int index) async {
    setState(() => _isLoading = true);
    final ordenController = _controllers[index];

    try {
      final fechaEmision = DateTime.parse(
          ordenController['fechaEmisionController'].text);

      final data = {
        'numero_orden': ordenController['numeroOrdenController'].text,
        'fecha_emision': fechaEmision.toIso8601String(),
        'proveedorId': ordenController['proveedorIdController'].text,
        'centro_costo': ordenController['centroCostoController'].text,
        'itemizadoId':
            ordenController['seccionItemizadoController'].text.isNotEmpty
                ? ordenController['seccionItemizadoController'].text
                : null,
        'numero_cotizacion':
            ordenController['numeroCotizacionController'].text,
        'numero_contacto':
            ordenController['numeroContactoController'].text,
        'nombre_servicio':
            ordenController['nombreServicioController'].text,
        'valor':
            int.tryParse(ordenController['valorController'].text) ?? 0,
        'descuento': ordenController['descuentoSwitch'],
        'notas_adicionales':
            ordenController['notasAdicionalesController'].text,
      };

      final exito = await Provider.of<OrdenesProvider>(context, listen: false)
          .actualizarOrden(ordenController['id'], data);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Orden ${ordenController['numeroOrdenController'].text} actualizada'),
          ),
        );
        Navigator.pushNamed(
            context, '/home_page/logistica_view/ordenes_view');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al actualizar la orden ${ordenController['numeroOrdenController'].text}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
    );
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
                    title: Text('Orden: ${orden.nombreServicio}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Proveedor: ${orden.proveedor.nombreVendedor}'),
                        Text('Valor: \$${orden.valor}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // 1) Número de orden
                            TextFormField(
                              controller: c['numeroOrdenController'],
                              decoration: _inputDecoration(
                                label: 'Número de orden',
                                icon: Icons.confirmation_number_outlined,
                              ),
                            ),

                            // 2) Número de cotización (opcional)
                            TextFormField(
                              controller: c['numeroCotizacionController'],
                              decoration: _inputDecoration(
                                label: 'Número de cotización (opcional)',
                                icon: Icons.tag_outlined,
                              ),
                            ),

                            // 3) Fecha con selector + cursor clic
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () async {
                                  FocusScope.of(context).unfocus();

                                  DateTime initialDate;
                                  try {
                                    initialDate = DateTime.parse(
                                        c['fechaEmisionController'].text);
                                  } catch (_) {
                                    initialDate = DateTime.now();
                                  }

                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.fromSeed(
                                            seedColor:
                                                const Color(0xFF6750A4),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedDate != null) {
                                    setState(() {
                                      c['fechaEmisionController'].text =
                                          pickedDate
                                              .toIso8601String()
                                              .split('T')[0];
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller:
                                        c['fechaEmisionController'],
                                    decoration: _inputDecoration(
                                      label: 'Fecha de emisión',
                                      icon:
                                          Icons.calendar_today_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 4) Proveedor
                            Consumer<ProveedoresProvider>(
                              builder:
                                  (context, prov, _) {
                                final proveedores = prov.proveedores;
                                final currentId =
                                    c['proveedorIdController'].text;

                                return DropdownButtonFormField<String>(
                                  decoration: _inputDecoration(
                                    label: 'Proveedor',
                                    icon: Icons
                                        .store_mall_directory_outlined,
                                  ),
                                  value: proveedores.any(
                                          (p) => p.id == currentId)
                                      ? currentId
                                      : null,
                                  items: proveedores.map((p) {
                                    return DropdownMenuItem<String>(
                                      value: p.id,
                                      child: Text(p.nombreVendedor),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      c['proveedorIdController'].text =
                                          value ?? '';
                                    });
                                  },
                                );
                              },
                            ),

                            // 5) Número de contacto
                            TextFormField(
                              controller:
                                  c['numeroContactoController'],
                              decoration: _inputDecoration(
                                label:
                                    'Número de contacto (opcional)',
                                icon: Icons.phone_outlined,
                              ),
                            ),

                            // 6) Centro de costo
                            TextFormField(
                              controller:
                                  c['centroCostoController'],
                              decoration: _inputDecoration(
                                label: 'Centro de costo',
                                icon: Icons.apartment_outlined,
                              ),
                            ),

                            // 7) Itemizado + monto disponible
                            Consumer<ItemizadosProvider>(
                              builder:
                                  (context, itemProv, _) {
                                final itemizados =
                                    itemProv.itemizados;
                                final selectedId =
                                    c['seccionItemizadoController']
                                        .text;

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      decoration: _inputDecoration(
                                        label: 'Itemizado',
                                        icon: Icons
                                            .view_list_outlined,
                                      ),
                                      value: selectedId.isNotEmpty
                                          ? selectedId
                                          : null,
                                      items: itemizados.map((i) {
                                        return DropdownMenuItem<
                                            String>(
                                          value: i.id,
                                          child: Text(i.nombre),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          c['seccionItemizadoController']
                                                  .text =
                                              value ?? '';
                                        });
                                      },
                                    ),
                                    if (selectedId.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          top: 8,
                                          bottom: 12,
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            final matches = itemizados
                                                .where((i) =>
                                                    i.id ==
                                                    selectedId)
                                                .toList();
                                            if (matches.isEmpty) {
                                              return const SizedBox();
                                            }
                                            final item =
                                                matches.first;
                                            return Text(
                                              'Monto disponible: ${item.montoDisponible}',
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),

                            // 8) Nombre del servicio
                            TextFormField(
                              controller:
                                  c['nombreServicioController'],
                              decoration: _inputDecoration(
                                label: 'Nombre del servicio',
                                icon: Icons.work_outline,
                              ),
                            ),

                            // 9) Valor
                            TextFormField(
                              controller: c['valorController'],
                              decoration: _inputDecoration(
                                label: 'Valor',
                                icon: Icons.attach_money_outlined,
                              ),
                              keyboardType: TextInputType.number,
                            ),

                            // 10) Descuento
                            SwitchListTile(
                              title: const Text(
                                  '¿Aplicar descuento?'),
                              secondary: const Icon(
                                  Icons.percent_outlined),
                              value: c['descuentoSwitch'] as bool,
                              onChanged: (value) => setState(
                                () =>
                                    c['descuentoSwitch'] = value,
                              ),
                            ),

                            // 11) Notas adicionales
                            TextFormField(
                              controller:
                                  c['notasAdicionalesController'],
                              decoration: _inputDecoration(
                                label:
                                    'Notas adicionales (opcional)',
                                icon: Icons.note_alt_outlined,
                              ),
                              maxLines: 3,
                            ),

                            const SizedBox(height: 20),

                            // Botón guardar cambios
                            ElevatedButton(
                              onPressed: () =>
                                  _submitFormOrden(index),
                              child:
                                  const Text('Guardar cambios'),
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
