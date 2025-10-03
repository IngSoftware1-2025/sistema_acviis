import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/pagos_provider.dart';
import 'package:sistema_acviis/models/pagos.dart';

class ListaPagosPendientes extends StatefulWidget {
  final Function(List<Pago>)? onSeleccionadasChanged;
  const ListaPagosPendientes({super.key, this.onSeleccionadasChanged});

  @override
  State<ListaPagosPendientes> createState() => _ListaPagosPendientesState();
}

class _ListaPagosPendientesState extends State<ListaPagosPendientes> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PagosProvider>(context, listen: false).fetchOtrosPagos();
    });
  }

  bool get _allSelected {
    final pagosProvider = Provider.of<PagosProvider>(context, listen: false);
    final pagosPendientes = pagosProvider.otrosPagos
        .where((p) => p.tipoPago.toLowerCase() != 'factura')
        .toList();
    final seleccionadas = pagosProvider.otrosPagosSeleccionados;
    return pagosPendientes.isNotEmpty && seleccionadas.length == pagosPendientes.length;
  }

  void _toggleSelectAll(bool? value) {
    final pagosProvider = Provider.of<PagosProvider>(context, listen: false);
    final pagosPendientes = pagosProvider.otrosPagos
        .where((p) => p.tipoPago.toLowerCase() != 'factura')
        .toList();
    if (value == true) {
      for (var pago in pagosPendientes) {
        pagosProvider.seleccionarOtroPago(pago, true);
      }
    } else {
      for (var pago in pagosPendientes) {
        pagosProvider.seleccionarOtroPago(pago, false);
      }
    }
    if (widget.onSeleccionadasChanged != null) {
      widget.onSeleccionadasChanged!(pagosProvider.otrosPagosSeleccionados);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagosProvider = context.watch<PagosProvider>();
    final pagosPendientes = pagosProvider.otrosPagos
        .where((p) => p.tipoPago.toLowerCase() != 'factura')
        .toList();
    final seleccionadas = pagosProvider.otrosPagosSeleccionados;

    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Pagos Pendientes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: seleccionadas.isNotEmpty
                    ? () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar varios pagos'),
                            content: const Text('¿Está seguro que desea eliminar los pagos seleccionados? Se eliminarán del sistema.'),
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
                          for (var pago in seleccionadas) {
                            await Provider.of<PagosProvider>(context, listen: false)
                                .actualizarVisualizacion(pago.id, 'eliminado');
                          }
                          await Provider.of<PagosProvider>(context, listen: false)
                              .fetchOtrosPagos();
                          Provider.of<PagosProvider>(context, listen: false)
                              .otrosPagosSeleccionados.clear();
                        }
                      }
                    : null,
                child: const Text('Eliminar varios'),
              ),
            ],
          ),
          leading: Checkbox(
            value: _allSelected,
            onChanged: _toggleSelectAll,
          ),
        ),
        SizedBox(
          height: 350,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pagosPendientes.length,
            itemBuilder: (context, i) {
              final pagoPendiente = pagosPendientes[i];
              final isSelected = seleccionadas.contains(pagoPendiente);
              return ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    pagosProvider.seleccionarOtroPago(pagoPendiente, value ?? false);
                    if (widget.onSeleccionadasChanged != null) {
                      widget.onSeleccionadasChanged!(pagosProvider.otrosPagosSeleccionados);
                    }
                  },
                ),
                title: Text(pagoPendiente.nombreMandante),
                subtitle: Text('Valor: ${pagoPendiente.valor} - Estado: ${pagoPendiente.estadoPago} - Tipo: ${pagoPendiente.tipoPago}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pagoPendiente.fotografiaId.isNotEmpty)
                      ElevatedButton.icon(
                        icon: Icon(Icons.download),
                        label: Text('Descargar PDF Mongo'),
                        onPressed: () => pagosProvider.descargarArchivoPDF(context, pagoPendiente.fotografiaId),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        pagosProvider.descargarFicha(context, pagoPendiente.id.toString(), pagoPendiente.codigo);
                      },
                      child: const Text('Descargar PDF'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar pago'),
                            content: const Text('¿Está seguro que desea eliminar este pago? Se eliminará del sistema.'),
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
                          await Provider.of<PagosProvider>(context, listen: false)
                              .actualizarVisualizacion(pagoPendiente.id, 'eliminado');
                          await Provider.of<PagosProvider>(context, listen: false)
                              .fetchOtrosPagos();
                        }
                      },
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}