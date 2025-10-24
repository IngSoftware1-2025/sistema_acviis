import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/views/obras/dialogs/agregar_item.dart';
import 'package:sistema_acviis/providers/itemizados_provider.dart';

class GestionarItemizadosView extends StatefulWidget {
  const GestionarItemizadosView({super.key});

  @override
  State<GestionarItemizadosView> createState() =>
      _GestionarItemizadosViewState();
}

class _GestionarItemizadosViewState extends State<GestionarItemizadosView> {
  String? obraId;
  String? obraNombre;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => isLoading = true);
      try {
        final Map<String, dynamic> args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
        obraId = args['obraId'];
        obraNombre = args['obraNombre'];
        // precargar itemizados desde el provider
        Provider.of<ItemizadosProvider>(context, listen: false).precargarItemizados();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener datos de la obra: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    });
  }

  Future<void> _abrirDialogoAgregarItem() async {
    final nuevoItem = await mostrarDialogoAgregarItem(context);
    if (nuevoItem != null) {
      try {
        setState(() => isLoading = true);
        await Provider.of<ItemizadosProvider>(context, listen: false)
            .crearItemizado(nuevoItem);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ítem agregado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar ítem: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  dynamic _valorCampo(dynamic item, String campo) {
    try {
      if (item == null) return null;
      if (item is Map) return item[campo];
      final dyn = item as dynamic;
      switch (campo) {
        case 'nombre':
          return dyn.nombre ?? dyn.name;
        case 'cantidad':
          return dyn.cantidad ?? dyn.quantity ?? dyn.cant;
        case 'valor_total':
          return dyn.valorTotal ?? dyn.valor_total ?? dyn.valor;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    obraId = args['obraId'];
    obraNombre = args['obraNombre'];

    final prov = context.watch<ItemizadosProvider>();
    final items = prov.itemizados;

    return PrimaryScaffold(
      title: 'Itemizado de obra ${obraNombre != null ? " - $obraNombre" : ""}',
      body: isLoading || prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _abrirDialogoAgregarItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar nuevo ítem'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lista de ítems registrados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(child: Text('No hay ítems registrados aún.'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowColor:
                                        MaterialStateColor.resolveWith((states) =>
                                            Colors.grey.shade200),
                                    columns: const [
                                      DataColumn(
                                          label: Text('Nombre',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Cantidad',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Valor total estimado',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))),
                                    ],
                                    rows: items
                                        .map(
                                          (item) => DataRow(
                                            cells: [
                                              DataCell(Text(_valorCampo(item, 'nombre')?.toString() ?? '')),
                                              DataCell(Text(_valorCampo(item, 'cantidad')?.toString() ?? '')),
                                              DataCell(Text(_valorCampo(item, 'valor_total')?.toString() ?? '')),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}