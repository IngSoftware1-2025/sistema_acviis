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

    Provider.of<ProveedoresProvider>(context, listen: false).precargarProveedores();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemizadosProvider>(context, listen: false).precargarItemizados();
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

        await ordenesProvider.fetchOrdenes();
        await itemizadosProvider.fetchItemizados();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Orden agregada exitosamente')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home_page/logistica_view/ordenes_view',
            (route) => false,
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

  InputDecoration _inputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Agregar Orden de Compra',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Número de orden
              TextFormField(
                controller: _numeroOrdenController,
                decoration: _inputDecoration(
                  label: 'Número de orden',
                  icon: Icons.confirmation_number_outlined,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),

              // Número de cotización
              TextFormField(
                controller: _numeroCotizacionController,
                decoration: _inputDecoration(
                  label: 'Número de cotización (opcional)',
                  icon: Icons.tag_outlined,
                ),
              ),

              // FECHA CON SELECTOR + CURSOR CLICKABLE
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(_fechaEmisionController.text),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.fromSeed(
                              seedColor: const Color(0xFF6750A4),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _fechaEmisionController.text =
                            pickedDate.toIso8601String().split('T')[0];
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _fechaEmisionController,
                      decoration: _inputDecoration(
                        label: 'Fecha de emisión',
                        icon: Icons.calendar_today_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                  ),
                ),
              ),

              // Proveedor
              Consumer<ProveedoresProvider>(
                builder: (context, proveedorProvider, _) {
                  return DropdownButtonFormField<String>(
                    decoration: _inputDecoration(
                      label: 'Proveedor',
                      icon: Icons.store_mall_directory_outlined,
                    ),
                    value: _proveedorIdController.text.isNotEmpty
                        ? _proveedorIdController.text
                        : null,
                    items: proveedorProvider.proveedores.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.nombreVendedor),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      _proveedorIdController.text = value ?? '';
                    }),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  );
                },
              ),

              // Número de contacto
              TextFormField(
                controller: _numeroContactoController,
                decoration: _inputDecoration(
                  label: 'Número de contacto (opcional)',
                  icon: Icons.phone_outlined,
                ),
              ),

              // Centro de costo
              TextFormField(
                controller: _centroCostoController,
                decoration: _inputDecoration(
                  label: 'Centro de costo',
                  icon: Icons.apartment_outlined,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),

              // Itemizado
              Consumer<ItemizadosProvider>(
                builder: (context, itemizadosProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration(
                          label: 'Itemizado',
                          icon: Icons.view_list_outlined,
                        ),
                        value: _selectedItemizadoId,
                        items: itemizadosProvider.itemizados.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.nombre),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          _selectedItemizadoId = value;
                        }),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Campo requerido' : null,
                      ),

                      if (_selectedItemizadoId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Text(
                            'Monto disponible: ${itemizadosProvider.itemizados.firstWhere((i) => i.id == _selectedItemizadoId).montoDisponible}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Nombre del servicio
              TextFormField(
                controller: _nombreServicioController,
                decoration: _inputDecoration(
                  label: 'Nombre del servicio',
                  icon: Icons.work_outline,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),

              // Valor
              TextFormField(
                controller: _valorController,
                decoration: _inputDecoration(
                  label: 'Valor',
                  icon: Icons.attach_money_outlined,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número entero';
                  return null;
                },
              ),

              // Descuento
              SwitchListTile(
                title: const Text('¿Aplicar descuento?'),
                secondary: const Icon(Icons.percent_outlined),
                value: _descuentoSwitch,
                onChanged: (value) => setState(() => _descuentoSwitch = value),
              ),

              // Notas adicionales
              TextFormField(
                controller: _notasAdicionalesController,
                decoration: _inputDecoration(
                  label: 'Notas adicionales (opcional)',
                  icon: Icons.note_alt_outlined,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Botón guardar
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
