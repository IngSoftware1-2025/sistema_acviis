import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/itemizado.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/views/obras/dialogs/agregar_item.dart';
import 'package:sistema_acviis/providers/itemizados_provider.dart';
import 'package:sistema_acviis/frontend/utils/itemizados_pdf_generator.dart';


class GestionarItemizadosView extends StatefulWidget {
  const GestionarItemizadosView({super.key});

  @override
  State<GestionarItemizadosView> createState() => _GestionarItemizadosViewState();
}

class _GestionarItemizadosViewState extends State<GestionarItemizadosView> {
  String? obraId;
  String? obraNombre;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      obraId = args?['obraId'];
      obraNombre = args?['obraNombre'];

      if (obraId != null) {
        context.read<ItemizadosProvider>().fetchItemizadosPorObra(obraId!);
      }
    });
  }

  Future<void> _abrirDialogoAgregarItem() async {
    final nuevoItem = await mostrarDialogoAgregarItem(context);
    if (nuevoItem != null && obraId != null) {
      final ok = await context.read<ItemizadosProvider>().addItemizado(
        nombre: nuevoItem['nombre'],
        cantidad: nuevoItem['cantidad'],
        montoTotal: nuevoItem['valor_total'],
        obraId: obraId!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ok ? 'Ítem agregado' : 'Error al agregar ítem')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Itemizado de obra ${obraNombre != null ? " - $obraNombre" : ""}',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _abrirDialogoAgregarItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar nuevo ítem'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (obraId != null && obraNombre != null) {
                      await ItemizadosPdfGenerator.generarYMostrar(
                        context,
                        obraId: obraId!,
                        obraNombre: obraNombre!,
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generar PDF'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<ItemizadosProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.itemizados.isEmpty) {
                    return const Center(child: Text('No hay ítems registrados aún.'));
                  }

                  final totalEstimado = provider.itemizados.fold<int>(0, (a, b) => a + b.montoTotal);

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity, 
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columnSpacing: 40,
                              headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Cantidad')),
                                DataColumn(label: Text('Valor total')),
                              ],
                              rows: provider.itemizados.map((Itemizado item) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(item.nombre)),
                                    DataCell(Text(item.cantidad.toString())),
                                    DataCell(Text('\$${item.montoTotal.toString()}')),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'TOTAL ESTIMADO:  \$${totalEstimado.toString()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
