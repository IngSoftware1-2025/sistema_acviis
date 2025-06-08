import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/widgets/scaffold.dart';

class EliminarTrabajadorView extends StatefulWidget {
  const EliminarTrabajadorView({
    super.key,
  });
  @override
  State<EliminarTrabajadorView> createState() => _EliminarTrabajadorViewState();
}

class _EliminarTrabajadorViewState extends State<EliminarTrabajadorView> {
  @override
  Widget build(BuildContext context){
    return PrimaryScaffold(
      title: 'Eliminar trabajador/es',
      body: Placeholder(),
    );
  }
}