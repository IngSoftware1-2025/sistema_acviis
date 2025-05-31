import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';

class TrabajadoresView extends StatefulWidget {
  const TrabajadoresView({
    super.key
  });
  @override
  State<TrabajadoresView> createState() => _TrabajadoresViewState();
}

class _TrabajadoresViewState extends State<TrabajadoresView> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PersonalizedAppBar(title: 'Trabajadores'),
      body: Placeholder() // Aqui irian las funciones o botones que cumplan los casos de usos de trbajadores
    );
  }
}