import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/backend/controllers/PDF/generacionPDF.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/widgets/checkbox.dart';
import 'package:sistema_acviis/frontend/widgets/expansion_tile_vehiculos.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/providers/vehiculos_provider.dart';

class ListaVehiculos extends StatefulWidget {
  const ListaVehiculos({super.key});

  @override
  State<ListaVehiculos> createState() => _ListaVehiculosState();
}

class _ListaVehiculosState extends State<ListaVehiculos> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehiculosProvider = Provider.of<VehiculosProvider>(context, listen: false);
      vehiculosProvider.fetchVehiculos().then((_) {
        if (!mounted) return; // <-- Agregado
        Provider.of<CheckboxProvider>(context, listen: false)
            .setCheckBoxes(vehiculosProvider.vehiculos.length);
      });
    });
  }

  Widget build(BuildContext context) {
    final provider = context.watch<VehiculosProvider>();
    final checkboxProvider = context.watch<CheckboxProvider>();


    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (checkboxProvider.checkBoxes.length != provider.vehiculos.length + 1) {
      checkboxProvider.setCheckBoxes(provider.vehiculos.length);
    }
    });

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.vehiculos.isEmpty) {
      return const Center(child: Text('No hay vehículos para mostrar.'));
    }
    if (checkboxProvider.checkBoxes.length != (provider.vehiculos.length + 1)) {
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
                    child: PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[0])),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                      'Lista de Vehículos Registrados',
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
              ...List.generate(provider.vehiculos.length, (i) {
                final vehiculo = provider.vehiculos[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    children: [
                      PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[i + 1]),
                      Expanded(
                        child: ExpansionTileVehiculos(
                          vehiculo: vehiculo,                        
                        ),
                      ),
                      Flexible(
                        flex: 0,
                        fit: FlexFit.tight,
                        child: IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          tooltip: "Descargar ficha PDF",
                          onPressed: () {
                            descargarFichaPDFGenerico(
                              context,
                              "vehiculos",
                              vehiculo.id,
                              vehiculo.patente,
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