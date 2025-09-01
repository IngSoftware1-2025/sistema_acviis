import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/herramientas_provider.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/views/logistica/func/lista_herramientas.dart';
import 'package:sistema_acviis/frontend/views/logistica/func/search_bar.dart';
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
                    onPressed: () {}
                  ),

                  SizedBox(height: normalPadding,),

                  PrimaryButton(
                    text: 'Modificar herramientas',
                    onPressed: () {}
                  ),

                  SizedBox(height: normalPadding,),

                  PrimaryButton(
                    text: 'Eliminar herramientas',
                    onPressed: () {}
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
                children: [],
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