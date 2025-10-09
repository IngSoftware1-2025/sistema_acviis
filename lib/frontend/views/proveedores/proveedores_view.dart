import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:sistema_acviis/frontend/views/proveedores/agregar_proveedor_view.dart';
import 'package:sistema_acviis/frontend/views/proveedores/modificar_proveedor_view.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/utils/filtros/proveedores.dart';
// Importamos la utilidad para PDF que acabamos de crear
import 'package:sistema_acviis/frontend/utils/pdf_utils.dart';

class ProveedoresView extends StatefulWidget {
  const ProveedoresView({super.key});

  @override
  State<ProveedoresView> createState() => _ProveedoresViewState();
}

class _ProveedoresViewState extends State<ProveedoresView> {
  final _searchController = TextEditingController();
  final _rutController = TextEditingController();
  final _nombreController = TextEditingController();
  final _productoController = TextEditingController();
  final _creditoMinController = TextEditingController();
  final _creditoMaxController = TextEditingController();

  final Set<String> _seleccionados = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProveedoresProvider>(context, listen: false).fetchProveedores();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _rutController.dispose();
    _nombreController.dispose();
    _productoController.dispose();
    _creditoMinController.dispose();
    _creditoMaxController.dispose();
    super.dispose();
  }

  void _aplicarFiltros() {
    Provider.of<ProveedoresProvider>(context, listen: false).actualizarFiltros(
      // La búsqueda principal ahora usa el searchController para RUT y Nombre
      busquedaGeneral: _searchController.text,
      // Los filtros avanzados usan sus propios controllers
      rut: _rutController.text,
      nombre: _nombreController.text,
      productoServicio: _productoController.text,
      creditoMin: int.tryParse(_creditoMinController.text),
      creditoMax: int.tryParse(_creditoMaxController.text),
    );
  }

  void _navegarAAgregarProveedor() async {
    final scaffoldContext = context;
    final resultado = await Navigator.push<bool>(
      scaffoldContext,
      MaterialPageRoute(builder: (_) => const AgregarProveedorView()),
    );
    if (resultado == true && mounted) {
      Provider.of<ProveedoresProvider>(scaffoldContext, listen: false).fetchProveedores();
    }
  }

  void _eliminarSeleccionados() async {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay proveedores seleccionados')),
      );
      return;
    }

    // 1. Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación Múltiple'),
        content: Text('¿Estás seguro de que deseas eliminar ${_seleccionados.length} proveedor(es)? Esta acción cambiará su estado a "inactivo".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // 2. Si el usuario confirma, proceder con la eliminación (soft delete)
    if (confirmar == true) {
      final provider = Provider.of<ProveedoresProvider>(context, listen: false);
      for (final id in _seleccionados) {
        await provider.eliminarProveedor(id); // Esto ya hace el soft delete
      }
      setState(() {
        _seleccionados.clear();
      });
      // No es necesario llamar a fetchProveedores() aquí, porque eliminarProveedor ya lo hace.
    }
  }

  void _generarPdfSeleccionados() {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay proveedores seleccionados')),
      );
      return;
    }
    // Aquí la lógica para generar el PDF de los seleccionados
    print('Generando PDF para: $_seleccionados');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProveedoresProvider>(context);

    return PrimaryScaffold(
      title: 'Proveedores',
      body: Column(
        children: [
          // Barra superior con acciones, búsqueda y filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Botón de Acciones
                CascadeButton(
                  title: 'Acciones',
                  startRight: true,
                  offset: 0.0,
                  icon: const Icon(Icons.menu),
                  children: [
                    PrimaryButton(onPressed: _navegarAAgregarProveedor, text: 'Agregar Proveedor'),
                    const SizedBox(height: 8),
                    PrimaryButton(onPressed: _eliminarSeleccionados, text: 'Eliminar Seleccionados'),
                    const SizedBox(height: 8),
                    PrimaryButton(onPressed: _generarPdfSeleccionados, text: 'Generar PDF Seleccionados'),
                  ],
                ),
                const SizedBox(width: 10),
                // Barra de búsqueda
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por Nombre o RUT',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => _aplicarFiltros(),
                  ),
                ),
                const SizedBox(width: 10),
                // Botón de Filtros
                CascadeButton(
                  title: 'Filtros',
                  offset: 0.0,
                  icon: const Icon(Icons.filter_alt_sharp),
                  children: [
                    ProveedorFiltrosDisplay(
                      rutController: _rutController,
                      nombreController: _nombreController,
                      productoController: _productoController,
                      creditoMinController: _creditoMinController,
                      creditoMaxController: _creditoMaxController,
                      onFilter: _aplicarFiltros,
                      onClear: () {
                        _searchController.clear();
                        _rutController.clear();
                        _nombreController.clear();
                        _productoController.clear();
                        _creditoMinController.clear();
                        _creditoMaxController.clear();
                        Provider.of<ProveedoresProvider>(context, listen: false).actualizarFiltros();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Separador
          Padding(
            padding: EdgeInsets.symmetric(vertical: normalPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 5,
                color: Colors.black,
              ),
            ),
          ),
          // Lista de proveedores
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: provider.proveedores.length,
                    itemBuilder: (context, index) {
                      final p = provider.proveedores[index];
                      final seleccionado = _seleccionados.contains(p.id);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ExpansionTile(
                          leading: Checkbox(
                            value: seleccionado,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _seleccionados.add(p.id);
                                } else {
                                  _seleccionados.remove(p.id);
                                }
                              });
                            },
                          ),
                          title: Text('${p.nombreVendedor} (${p.rut})'),
                          subtitle: Text('Producto/Servicio: ${p.productoServicio}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf),
                                tooltip: 'Ver ficha PDF',
                                onPressed: () async {
                                  await PdfUtils.generarYMostrarFichaProveedor(context, p.id, p.rut);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Modificar',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ModificarProveedorView(proveedor: p),
                                    ),
                                  );
                                  provider.fetchProveedores();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Eliminar',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar eliminación'),
                                      content: const Text('¿Seguro quieres eliminar este proveedor?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final exito = await provider.eliminarProveedor(p.id);
                                    if (!exito) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Error al eliminar proveedor')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dirección: ${p.direccion}'),
                                  Text('Correo: ${p.correoVendedor}'),
                                  Text('Teléfono: ${p.telefonoVendedor}'),
                                  Text('Crédito Disponible: \$${p.creditoDisponible}'),
                                  Text('Fecha Registro: ${p.fechaRegistro.toLocal().toString().split(' ')[0]}'),
                                  Text('Estado: ${p.estado ?? 'activo'}'),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}