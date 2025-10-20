import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/utils/filtros/vehiculos.dart';
import 'package:sistema_acviis/frontend/views/logistica/vehiculos/func/lista_vehiculos.dart';
import 'package:sistema_acviis/frontend/views/logistica/vehiculos/func/search_bar.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/providers/vehiculos_provider.dart';

class VehiculosView extends StatefulWidget {
  const VehiculosView({super.key});

  @override
  State<VehiculosView> createState() => _VehiculosViewState();
}

class _VehiculosViewState extends State<VehiculosView> {
  @override
  Widget build(BuildContext context) {  
    return PrimaryScaffold(
      title: 'Vehículos',
      body: Column(
        children: [
          Row(
            children: [
              CascadeButton(
                title: 'Acciones/Métodos',
                startRight: true, offset: 0.0,
                icon: Icon(Icons.menu),
                children: [
                  PrimaryButton(
                    text: 'Agregar vehículo',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home_page/logistica_view/vehiculos_view/agregar_vehiculos_view');
                    },
                  ),

                  SizedBox(height: normalPadding,),

                PrimaryButton(
                  onPressed: () {
                  final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                  final vehiculosProvider = Provider.of<VehiculosProvider>(context, listen: false);

                  final seleccionados = <int>[];
                  for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                    if (checkboxProvider.checkBoxes[i].isSelected) {
                      seleccionados.add(i - 1); 
                    }
                  }

                  if (seleccionados.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debes seleccionar al menos un vehículo.')),
                    );
                    return;
                  }

                  final vehiculosSeleccionados = seleccionados
                      .map((i) => vehiculosProvider.vehiculos[i])
                      .toList();

                  Navigator.pushReplacementNamed(
                    context,
                    '/home_page/logistica_view/vehiculos_view/modificar_vehiculos_view',
                    arguments: vehiculosSeleccionados,
                  );
                },
                  text: 'Modificar vehículos',
                ),

                  SizedBox(height: normalPadding,),

                PrimaryButton(
                  onPressed: () async {
                  final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                  final vehiculosProvider = Provider.of<VehiculosProvider>(context, listen: false);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  final seleccionados = <int>[];
                  for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                    if (checkboxProvider.checkBoxes[i].isSelected) {
                      seleccionados.add(i - 1); 
                    }
                  }

                  if (seleccionados.isEmpty) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Debes seleccionar al menos un vehículo.')),
                    );
                    return;
                  }

                  final vehiculosSeleccionados = seleccionados
                      .map((i) => vehiculosProvider.vehiculos[i])
                      .toList();

                  final idsSeleccionados = vehiculosSeleccionados.map((v) => v.id).toList();

                  try {
                    await vehiculosProvider.darDeBaja(idsSeleccionados);
                    if (!mounted) return;
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Todos los vehículos seleccionados fueron dados de baja.')),
                    );
                    checkboxProvider.setCheckBoxes(vehiculosProvider.vehiculos.length);
                  } catch (e) {
                    if (!mounted) return;
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Hubo un error al dar de baja vehículos.')),
                    );
                    debugPrint('Hubo un error al dar de baja vehículos: $e');
                  }
                },
                  text: 'Dar de baja vehículos',
                ),
                ]
              ),

              SizedBox(width: normalPadding,),

              Expanded(
                child: VehiculosSearchBar(),
              ),  

              SizedBox(width: normalPadding,),

              CascadeButton(
                title: 'Filtros Vehiculos',
                offset: 0.0,
                icon: Icon(Icons.filter_alt_sharp),
                children: [
                  VehiculosFiltrosDisplay(parentContext: context)
                ],
              ),
            ],
          ),

          SizedBox(height: normalPadding,),

          Padding(
            padding: EdgeInsets.symmetric(vertical: normalPadding),
            child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 10,
              color: Colors.black,
            ),
            ),
          ),
          ListaVehiculos()
        ],
      ),
    );
  }
}