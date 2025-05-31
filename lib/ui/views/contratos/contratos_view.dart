import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';

class ContratosView extends StatefulWidget {
  const ContratosView({
    super.key
  });
  @override
  State<ContratosView> createState() => _ContratosViewState();
}

class _ContratosViewState extends State<ContratosView> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PersonalizedAppBar(title: 'Contratos'),
      body: Placeholder(), // Aqui ira el contenido necesario para cumplir los casos de uso relacionados a contratos
    );
  }
}