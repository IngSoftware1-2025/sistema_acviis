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
      final provider = Provider.of<ProveedoresProvider>(context, listen: false);
      provider.fetchProveedores().then((_) {
        provider.actualizarFiltros(estado: 'Activo');
      });
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
              : Column(
                  children: [
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: provider.estado ?? 'Activo',
                          items: ['Activo', 'Inactivo'].map((estado) {
                            return DropdownMenuItem(
                              value: estado,
                              child: Text(estado),
                            );
                          }).toList(),
                          onChanged: (value) {
                            provider.actualizarFiltros(estado: value);
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Buscar proveedor',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              provider.actualizarFiltros(textoBusqueda: value);
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
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
                                    final exito = await Provider.of<ProveedoresProvider>(context, listen: false)
                                        .eliminarProveedor(p.id);
                                    // No vuelvas a llamar a fetchProveedores ni actualizarFiltros aquí
                                    // El provider ya lo hace automáticamente
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Espera el resultado de la pantalla de agregar proveedor
          final resultado = await Navigator.pushNamed(
            context,
            '/home_page/proveedores_view/agregar_proveedor_view',
          );
          // Si se agregó un proveedor, actualiza la lista
          if (resultado == true) {
            Provider.of<ProveedoresProvider>(context, listen: false).fetchProveedores();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}