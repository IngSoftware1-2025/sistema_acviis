import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/backend/controllers/PDF/generacionPDF.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/widgets/checkbox.dart';
import 'package:sistema_acviis/frontend/widgets/expansion_tile_ordenes.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';

class ListaOrdenes extends StatefulWidget {
  const ListaOrdenes({super.key});

  @override
  State<ListaOrdenes> createState() => _ListaOrdenesState();
}

class _ListaOrdenesState extends State<ListaOrdenes> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ordenesProvider = Provider.of<OrdenesProvider>(context, listen: false);
      ordenesProvider.fetchOrdenes().then((_) {
        if (!mounted) return;
        Provider.of<CheckboxProvider>(context, listen: false)
            .setCheckBoxes(ordenesProvider.ordenes.length);
      });
    });
  }


  Widget build(BuildContext context) {
    final provider = context.watch<OrdenesProvider>();
    final checkboxProvider = context.watch<CheckboxProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (checkboxProvider.checkBoxes.length != provider.ordenes.length + 1) {
        checkboxProvider.setCheckBoxes(provider.ordenes.length);
      }
    });

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.ordenes.isEmpty) {
      return const Center(child: Text('No hay órdenes de compra para mostrar.'));
    }
    if (checkboxProvider.checkBoxes.length != (provider.ordenes.length + 1)) {
      return const Center(child: CircularProgressIndicator());
    }

    final double tableWidth = MediaQuery.of(context).size.width > 600
        ? MediaQuery.of(context).size.width
        : 600;

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: tableWidth - normalPadding * 2,
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 0,
                    fit: FlexFit.tight,
                    child: PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[0]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Lista de Órdenes de Compra',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 0,
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Opciones', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const Divider(),
              ...List.generate(provider.ordenes.length, (i) {
                final orden = provider.ordenes[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    children: [
                      PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[i + 1]),
                      Expanded(
                        child: ExpansionTileOrdenes(
                          orden: orden,
                        ),
                      ),
                      Flexible(
                        flex: 0,
                        fit: FlexFit.tight,
                        child: IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          tooltip: "Descargar orden PDF",
                          onPressed: () {
                            descargarFichaPDFGenerico(
                              context,
                              "ordenes",
                              orden.id,
                              orden.numeroOrden,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
