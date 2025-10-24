import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/views/obras/dialogs/agregar_item.dart';

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

  final List<Map<String, dynamic>> _itemizados = [];

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
      setState(() {
        _itemizados.add(nuevoItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    obraId = args['obraId'];
    obraNombre = args['obraNombre'];

    return PrimaryScaffold(
      title: 'Itemizado de obra ${obraNombre != null ? " - $obraNombre" : ""}',
      body: isLoading
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
                    child: _itemizados.isEmpty
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
                                    rows: _itemizados
                                        .map(
                                          (item) => DataRow(
                                            cells: [
                                              DataCell(Text(item['nombre'])),
                                              DataCell(
                                                  Text(item['cantidad'].toString())),
                                              DataCell(Text(
                                                  item['valor_total'].toString())),
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