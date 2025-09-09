import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/pagos_provider.dart';
import 'package:sistema_acviis/models/pagos.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:sistema_acviis/frontend/views/finanzas/Dialogs/editar_pago_dialog.dart';
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
  Future<void> descargarYAbrirPdf(String fotografiaId) async {
  final url = 'http://localhost:3000/finanzas/download-pdf/$fotografiaId';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final downloadsDir = Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${downloadsDir.path}/factura_${fotografiaId}_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado en Descargas. Abriendo...')),
      );
      await OpenFile.open(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo descargar el PDF')),
      );
    }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el PDF: $e')),
      );
    }
  }
  Future<void> descargarFacturaPDF(BuildContext context, String facturaId, String codigo) async {
    try {
      final url = Uri.parse('http://localhost:3000/pagos/$facturaId/pdf');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final downloadsDir = Directory('${Platform.environment['USERPROFILE']}\\Downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        final file = File('${downloadsDir.path}/factura_$codigo.pdf');
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF de factura guardado en Descargas. Abriendo...')),
        );
        await OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar el PDF de la factura')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  bool get _allSelected {
    final pagosProvider = Provider.of<PagosProvider>(context, listen: false);
    final facturas = pagosProvider.facturas;
    final seleccionadas = pagosProvider.facturasSeleccionadas;
    return facturas.isNotEmpty && seleccionadas.length == facturas.length;
  }

  void _toggleSelectAll(bool? value) {
    final pagosProvider = Provider.of<PagosProvider>(context, listen: false);
    final facturas = pagosProvider.facturas;
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
    final facturas = pagosProvider.facturas;
    final seleccionadas = pagosProvider.facturasSeleccionadas;

    return Column(
      children: [
        ListTile(
            title: Row(
            children: [
              Expanded(
              child: Center(
                child: Text(
                'Facturas',
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
              child: const Text('Eliminar varios'),
              ),
            ],
            ),
            leading: Checkbox(
            value: _allSelected,
            onChanged: _toggleSelectAll,
            ),
          ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: facturas.length,
            itemBuilder: (context, i) {
              final factura = facturas[i];
              final isSelected = seleccionadas.contains(factura);
              return ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    pagosProvider.seleccionarFactura(factura, value ?? false);
                    if (widget.onSeleccionadasChanged != null) {
                      widget.onSeleccionadasChanged!(pagosProvider.facturasSeleccionadas);
                    }
                  },
                ),
                title: Text(factura.nombreMandante),
                subtitle: Text('Valor: ${factura.valor} - Estado: ${factura.estadoPago} - Tipo: ${factura.tipoPago}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (factura.fotografiaId.isNotEmpty)
                      ElevatedButton.icon(
                        icon: Icon(Icons.download),
                        label: Text('Descargar PDF Mongo'),
                        onPressed: () => descargarYAbrirPdf(factura.fotografiaId),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        descargarFacturaPDF(
                          context,
                          factura.id.toString(),
                          factura.codigo,
                        );
                      },
                      child: const Text('Descargar PDF'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => EditarPagoDialog(pago: factura),
                        );
                      },
                      child: const Text('Modificar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(),
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