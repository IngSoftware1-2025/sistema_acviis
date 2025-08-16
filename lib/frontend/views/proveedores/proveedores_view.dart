import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:sistema_acviis/frontend/views/proveedores/modificar_proveedor_view.dart';

class ProveedoresView extends StatefulWidget {
  const ProveedoresView({super.key});

  @override
  State<ProveedoresView> createState() => _ProveedoresViewState();
}

class _ProveedoresViewState extends State<ProveedoresView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProveedoresProvider>(context, listen: false).fetchProveedores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProveedoresProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.proveedores.isEmpty
              ? const Center(child: Text('No hay proveedores registrados.'))
              : ListView.builder(
                  itemCount: provider.proveedores.length,
                  itemBuilder: (context, i) {
                    final p = provider.proveedores[i];
                    return ListTile(
                      title: Text(p.nombre),
                      subtitle: Text(p.rut),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ModificarProveedorView(proveedor: p),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar proveedor'),
                                  content: const Text('¿Seguro que deseas eliminar este proveedor?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final exito = await Provider.of<ProveedoresProvider>(context, listen: false)
                                    .eliminarProveedor(p.id);
                                if (exito && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Proveedor eliminado')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home_page/proveedores_view/agregar_proveedor_view');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}