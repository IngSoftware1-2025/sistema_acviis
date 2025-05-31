import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';
import 'package:sistema_acviis/ui/views/bottom_navigation_bar.dart';

class AgregarTrabajadorView extends StatefulWidget {
  const AgregarTrabajadorView({
    super.key
  });

  @override
  State<AgregarTrabajadorView> createState() => _AgregarTrabajadorViewState();
}

class _AgregarTrabajadorViewState extends State<AgregarTrabajadorView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalizedAppBar(title: 'Agregar trabajador/es'),
      body: Placeholder(),
      bottomNavigationBar: NavigationBottomBar(),
    );
  }
}
