import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:sistema_acviis/frontend/views/proveedores/agregar_proveedor_view.dart';
import 'package:sistema_acviis/frontend/views/proveedores/modificar_proveedor_view.dart';
// Si tienes una utilidad para PDF, impórtala aquí
// import 'package:sistema_acviis/frontend/utils/pdf_utils.dart';

class ProveedoresView extends StatefulWidget {
  const ProveedoresView({super.key});

  @override
  State<ProveedoresView> createState() => _ProveedoresViewState();
}

class _ProveedoresViewState extends State<ProveedoresView> {
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
    _rutController.dispose();
    _nombreController.dispose();
    _productoController.dispose();
    _creditoMinController.dispose();
    _creditoMaxController.dispose();
    super.dispose();
  }

  void _aplicarFiltros() {
    Provider.of<ProveedoresProvider>(context, listen: false).actualizarFiltros(
      rut: _rutController.text,
      nombre: _nombreController.text,
      productoServicio: _productoController.text,
      creditoMin: int.tryParse(_creditoMinController.text),
      creditoMax: int.tryParse(_creditoMaxController.text),
    );
  }

  void _mostrarMenuAcciones() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Crear proveedor'),
              onTap: () async {
                Navigator.pop(context);
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgregarProveedorView()),
                );
                if (resultado == true) {
                  Provider.of<ProveedoresProvider>(context, listen: false)
                      .fetchProveedores();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar seleccionados'),
              onTap: () async {
                Navigator.pop(context);
                final provider = Provider.of<ProveedoresProvider>(context,
                    listen: false);
                for (final id in _seleccionados) {
                  await provider.eliminarProveedor(id);
                }
                _seleccionados.clear();
                provider.fetchProveedores();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Generar ficha PDF de seleccionados'),
              onTap: () async {
                Navigator.pop(context);
                // Aquí deberías llamar a tu función para generar PDF de todos los seleccionados
                // await PdfUtils.generarFichaProveedoresSeleccionados(_seleccionados);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProveedoresProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
      ),
      body: Column(
        children: [
          // Filtros arriba
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _rutController,
                    decoration: const InputDecoration(labelText: 'RUT'),
                    onChanged: (_) => _aplicarFiltros(),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre vendedor'),
                    onChanged: (_) => _aplicarFiltros(),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _productoController,
                    decoration: const InputDecoration(labelText: 'Producto/Servicio'),
                    onChanged: (_) => _aplicarFiltros(),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _creditoMinController,
                    decoration: const InputDecoration(labelText: 'Crédito min'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _aplicarFiltros(),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _creditoMaxController,
                    decoration: const InputDecoration(labelText: 'Crédito max'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _aplicarFiltros(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _aplicarFiltros,
                  child: const Text('Filtrar'),
                ),
                TextButton(
                  onPressed: () {
                    _rutController.clear();
                    _nombreController.clear();
                    _productoController.clear();
                    _creditoMinController.clear();
                    _creditoMaxController.clear();
                    Provider.of<ProveedoresProvider>(context, listen: false).actualizarFiltros();
                  },
                  child: const Text('Limpiar filtros'),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: provider.proveedores.length,
                    itemBuilder: (context, index) {
                      final p = provider.proveedores[index];
                      final seleccionado = _seleccionados.contains(p.id);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
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
                          subtitle: Text(
                            'Producto/Servicio: ${p.productoServicio}\n'
                            'Crédito: \$${p.creditoDisponible}\n'
                            'Dirección: ${p.direccion}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf),
                                tooltip: 'Ver ficha PDF',
                                onPressed: () async {
                                  // Aquí deberías llamar a tu función para generar y mostrar el PDF
                                  // await PdfUtils.generarFichaProveedor(p);
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarMenuAcciones,
        child: const Icon(Icons.menu),
        tooltip: 'Acciones',
      ),
    );
  }
}