import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';
import 'package:sistema_acviis/ui/views/bottom_navigation_bar.dart';

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
    return Scaffold(
      appBar: PersonalizedAppBar(title: 'Eliminar trabajador/es'),
      body: Placeholder(),
      bottomNavigationBar: NavigationBottomBar(),
    );
  }
}