import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/widgets/scaffold.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';

class ModificarListaTrabajadoresView extends StatefulWidget {
  const ModificarListaTrabajadoresView({
    super.key,
  });

  @override
  State<ModificarListaTrabajadoresView> createState() => _ModificiarListaTrabajadoresViewState();
}

class _ModificiarListaTrabajadoresViewState extends State<ModificarListaTrabajadoresView> {
  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Modificar lista de cabezones',
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/modificar_lista_trabajadores_view/agregar_trabajador_view');
            },
            child: Center(child: Text('Agregar trabajador/es'))
          ),
          SizedBox(height: normalPadding),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/modificar_lista_trabajadores_view/eliminar_trabajador_view');
            },
            child: Center(child: Text('Eliminar trabajador/es'))
          ),
        ]
      )
    );
  }
}