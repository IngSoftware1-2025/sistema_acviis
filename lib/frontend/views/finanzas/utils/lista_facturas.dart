// lib/frontend/views/finanzas/utils/lista_facturas.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/pagos_provider.dart';
import 'package:sistema_acviis/models/pagos.dart';
import 'package:sistema_acviis/frontend/views/finanzas/Dialogs/editar_pago_dialog.dart';
import 'package:sistema_acviis/frontend/views/finanzas/Dialogs/filtro_facturas_dialog.dart';

class ListaFacturas extends StatefulWidget {
  final Function(List<Pago>)? onSeleccionadasChanged;
  const ListaFacturas({super.key, this.onSeleccionadasChanged});

  @override
  State<ListaFacturas> createState() => _ListaFacturasState();
}

class _ListaFacturasState extends State<ListaFacturas> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PagosProvider>(context, listen: false).fetchFacturas();
    });
  }
  
  bool get _allSelected {
    final pagosProvider = Provider.of<PagosProvider>(context, listen: false);
    final facturas = pagosProvider.facturasFiltradas; // Cambio: usar facturasFiltradas
    final seleccionadas = pagosProvider.facturasSeleccionadas;
    return facturas.isNotEmpty && seleccionadas.length == facturas.length;
  }

  void _toggleSelectAll(bool? value) {
    final pagosProvider = Provider.of<PagosProvider>(context, listen: false);
    final facturas = pagosProvider.facturasFiltradas; // Cambio: usar facturasFiltradas
    if (value == true) {
      for (var factura in facturas) {
        pagosProvider.seleccionarFactura(factura, true);
      }
    } else {
      for (var factura in facturas) {
        pagosProvider.seleccionarFactura(factura, false);
      }
    }
    if (widget.onSeleccionadasChanged != null) {
      widget.onSeleccionadasChanged!(pagosProvider.facturasSeleccionadas);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagosProvider = context.watch<PagosProvider>();
    final facturas = pagosProvider.facturasFiltradas; // Cambio: usar facturasFiltradas
    final seleccionadas = pagosProvider.facturasSeleccionadas;
    final hayFiltros = pagosProvider.filtrosFacturas != null && pagosProvider.filtrosFacturas!.isNotEmpty;
    final totalFacturas = pagosProvider.facturas.length; // Total sin filtrar

    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Facturas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      if (hayFiltros)
                        Text(
                          'Mostrando ${facturas.length} de $totalFacturas facturas',
                          style: TextStyle(
                            fontSize: 12, 
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Botón de filtro
              ElevatedButton.icon(
                icon: Icon(
                  hayFiltros ? Icons.filter_alt : Icons.filter_list,
                  color: hayFiltros ? Colors.white : null,
                ),
                label: Text(hayFiltros ? 'Filtros (${facturas.length})' : 'Filtrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hayFiltros ? Colors.blue : null,
                  foregroundColor: hayFiltros ? Colors.white : null,
                ),
                onPressed: () async {
                  final resultado = await showDialog<bool>(
                    context: context,
                    builder: (context) => const FiltroFacturasDialog(),
                  );
                  // Si se aplicaron filtros, actualizar la vista
                  if (resultado == true && mounted) {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(width: 8),
              // Botón de eliminar múltiples
              ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: seleccionadas.isNotEmpty
                  ? () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar varias facturas'),
                          content: const Text('¿Está seguro que desea eliminar las facturas seleccionadas? Se eliminarán del sistema.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        for (var factura in seleccionadas) {
                          await Provider.of<PagosProvider>(context, listen: false)
                              .actualizarVisualizacion(factura.id, 'eliminado');
                        }
                        await Provider.of<PagosProvider>(context, listen: false)
                            .fetchFacturas();
                        Provider.of<PagosProvider>(context, listen: false)
                            .facturasSeleccionadas.clear();
                      }
                    }
                  : null,
                child: const Text('Eliminar Facturas'),
              ),
            ],
          ),
          leading: Checkbox(
            value: _allSelected,
            onChanged: _toggleSelectAll,
          ),
        ),
        
        // Mostrar mensaje si hay filtros pero no hay resultados
        if (hayFiltros && facturas.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'No se encontraron facturas con los filtros aplicados',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    pagosProvider.limpiarFiltrosFacturas();
                  },
                  child: const Text('Limpiar filtros'),
                ),
              ],
            ),
          ),
        
        // Lista de facturas
        Expanded(
          child: facturas.isEmpty && !hayFiltros
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'No hay facturas registradas',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: facturas.length,
                itemBuilder: (context, i) {
                  final factura = facturas[i];
                  final isSelected = seleccionadas.contains(factura);
                  
                  // Determinar color según estado
                  Color? estadoColor;
                  if (factura.estadoPago.toLowerCase() == 'pagado') {
                    estadoColor = Colors.green;
                  } else if (factura.estadoPago.toLowerCase() == 'pendiente') {
                    estadoColor = Colors.orange;
                  } else if (factura.estadoPago.toLowerCase() == 'vencido') {
                    estadoColor = Colors.red;
                  }
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: isSelected ? 4 : 1,
                    color: isSelected ? Colors.blue.shade50 : null,
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          pagosProvider.seleccionarFactura(factura, value ?? false);
                          if (widget.onSeleccionadasChanged != null) {
                            widget.onSeleccionadasChanged!(pagosProvider.facturasSeleccionadas);
                          }
                        },
                      ),
                      title: Text(
                        factura.nombreMandante,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Servicio: ${factura.servicioOfrecido}'),
                          Row(
                            children: [
                              Text('Valor: \$${factura.valor.toStringAsFixed(2)}'),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: estadoColor?.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: estadoColor ?? Colors.grey),
                                ),
                                child: Text(
                                  factura.estadoPago,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: estadoColor ?? Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Vence: ${factura.plazoPagar.day}/${factura.plazoPagar.month}/${factura.plazoPagar.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: factura.plazoPagar.isBefore(DateTime.now()) 
                                    ? Colors.red 
                                    : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (factura.fotografiaId.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                              tooltip: 'Descargar PDF Mongo',
                              onPressed: () => pagosProvider.descargarArchivoPDF(
                                context, 
                                factura.fotografiaId
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.blue),
                            tooltip: 'Descargar Ficha PDF',
                            onPressed: () {
                              pagosProvider.descargarFicha(
                                context,
                                factura.id.toString(),
                                factura.codigo,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Modificar',
                            onPressed: () async {
                              final resultado = await showDialog(
                                context: context,
                                builder: (context) => EditarPagoDialog(pago: factura),
                              );
                              if (resultado == true && mounted) {
                                setState(() {});
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar factura'),
                                  content: const Text('¿Está seguro que desea eliminar esta factura? Se eliminará del sistema.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Eliminar'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await Provider.of<PagosProvider>(context, listen: false)
                                    .actualizarVisualizacion(factura.id, 'eliminado');
                                await Provider.of<PagosProvider>(context, listen: false)
                                    .fetchFacturas();
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
    );
  }
}
