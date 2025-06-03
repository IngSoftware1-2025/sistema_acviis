import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';

class ListaTrabajadores extends StatefulWidget {
  const ListaTrabajadores({
    super.key
  });
  @override
  State<ListaTrabajadores> createState() => _ListaTrabajadoresState();
}

class _ListaTrabajadoresState extends State<ListaTrabajadores> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrabajadoresProvider>(context, listen: false).fetchTrabajadores();
    });
  }

  @override
  Widget build(BuildContext context){
    final provider = context.watch<TrabajadoresProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: provider.trabajadores.map((trabajador) {
      return Row(
        children: [
          Expanded(
                flex: 4,
                child: Column(
                children: [
                  Center(
                  child: Text(
                    trabajador.nombre, // Nombre trabajador
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  ),
                ],
                ),
              ),
              SizedBox(width: normalPadding),
              Expanded(
                flex: 2,
                child: Column(
                children: [
                  Center(
                  child: Text(
                    'Pendiente', // Cargo trabajador (Pendiente)
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  ),
                ],
                ),
              ),
              SizedBox(width: normalPadding),
              Expanded(
                flex: 2,
                child: Column(
                children: [
                  Center(
                  child: Text(
                    'Pendiente', // Obra trabajador (Pendiente)
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  ),
                ],
                ),
              ),
              SizedBox(width: normalPadding),
              Expanded(
                flex: 1,
                child: Column(
                children: [
                  Center(
                  child: Text(
                    'Opciones', // Botono pero xd
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  ),
                ],
                ),
              ),
        ]
      );
      }).toList(),
    );
  }
}