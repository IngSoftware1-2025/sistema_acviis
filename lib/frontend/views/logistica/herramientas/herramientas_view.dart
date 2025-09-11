import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/backend/controllers/herramientas/actualizar_estado_herramientas.dart';
import 'package:sistema_acviis/frontend/utils/filtros/herramientas.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/providers/herramientas_provider.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/views/logistica/herramientas/func/lista_herramientas.dart';
import 'package:sistema_acviis/frontend/views/logistica/herramientas/func/search_bar.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';

class HerramientasView extends StatefulWidget {
  const HerramientasView({super.key});

  @override
  State<HerramientasView> createState() => _HerramientasViewState();
}

class _HerramientasViewState extends State<HerramientasView> {
  @override
  Widget build(BuildContext context) {  
    return PrimaryScaffold(
      title: 'Herrmamientas',
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
                    text: 'Agregar herramienta',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home_page/logistica_view/herramientas_view/agregar_herramientas_view');
                    },
                  ),

                  SizedBox(height: normalPadding,),

                PrimaryButton(
                  onPressed: () {
                  final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                  final herramientasProvider = Provider.of<HerramientasProvider>(context, listen: false);

                  final seleccionadas = <int>[];
                  for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                    if (checkboxProvider.checkBoxes[i].isSelected) {
                      seleccionadas.add(i - 1); 
                    }
                  }

                  if (seleccionadas.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debes seleccionar al menos una herramienta.')),
                    );
                    return;
                  }

                  final herramientasSeleccionadas = seleccionadas
                      .map((i) => herramientasProvider.herramientas[i])
                      .toList();

                  Navigator.pushReplacementNamed(
                    context,
                    '/home_page/logistica_view/herramientas_view/modificar_herramientas_view',
                    arguments: herramientasSeleccionadas,
                  );
                },
                  text: 'Modificar herramientas',
                ),

                  SizedBox(height: normalPadding,),

                PrimaryButton(
                  onPressed: () async {
                  final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                  final herramientasProvider = Provider.of<HerramientasProvider>(context, listen: false);

                  final seleccionadas = <int>[];
                  for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                    if (checkboxProvider.checkBoxes[i].isSelected) {
                      seleccionadas.add(i - 1); 
                    }
                  }

                  if (seleccionadas.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debes seleccionar al menos una herramienta.')),
                    );
                    return;
                  }

                  final herramientasSeleccionadas = seleccionadas
                      .map((i) => herramientasProvider.herramientas[i])
                      .toList();

                  final idsSeleccionados = herramientasSeleccionadas.map((h) => h.id).toList();

                  try {
                    await herramientasProvider.darDeBaja(idsSeleccionados);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Todas las herramientas seleccionadas fueron dadas de baja.')),
                    );
                    Provider.of<CheckboxProvider>(context, listen: false)
                      .setCheckBoxes(herramientasProvider.herramientas.length);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hubo un error al dar de baja herramientas.')),
                    );
                    print("Hubo un error al dar de baja herramientas: $e");
                  }
                },
                  text: 'Dar de baja herramientas',
                ),
                ]
              ),

              SizedBox(width: normalPadding,),

              Expanded(
                child: HerramientasSearchBar(),
              ),  

              SizedBox(width: normalPadding,),

              CascadeButton(
                title: 'Filtros Herramientas',
                offset: 0.0,
                icon: Icon(Icons.filter_alt_sharp),
                children: [
                  HerramientasFiltrosDisplay()
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
          ListaHerramientas()
        ],
      ),
    );
  }
}