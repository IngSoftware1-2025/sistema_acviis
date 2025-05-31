import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/contratos/contratos_view.dart';
import 'package:sistema_acviis/ui/views/home_page.dart';
import 'package:sistema_acviis/ui/views/trabajadores/trabajadores_view.dart';

/*
  Aqui se importaran todas las vistas presentes en el sistema
  (Para el primer incremento serian todas las vistas asociadas
  con trabajador y contratos)
*/
final Map<String, WidgetBuilder> routes = { 
  '/trabajadores_view': (BuildContext context) => TrabajadoresView(),
  '/contratos_view' : (BuildContext context) => ContratosView(),
  '/home_page' : (BuildContext context) => HomePage(),
};