import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/contratos/contratos_view.dart';
import 'package:sistema_acviis/ui/views/home_page.dart';
import 'package:sistema_acviis/ui/views/trabajadores/agregar_trabajador_view.dart';
import 'package:sistema_acviis/ui/views/trabajadores/contratos_anexos.dart';
import 'package:sistema_acviis/ui/views/trabajadores/eliminar_trabajador_view.dart';
import 'package:sistema_acviis/ui/views/trabajadores/trabajadores_view.dart';

/*
  Aqui se importaran todas las vistas presentes en el sistema
  (Para el primer incremento serian todas las vistas asociadas
  con trabajador y contratos)
*/
final Map<String, WidgetBuilder> routes = { 
  '/home_page' : (BuildContext context) => HomePage(),
  '/home_page/trabajadores_view': (BuildContext context) => TrabajadoresView(),
  '/home_page/contratos_view' : (BuildContext context) => ContratosView(),
  '/home_page/trabajadores_view/agregar_trabajador_view' : (BuildContext context) => AgregarTrabajadorView(),
  '/home_page/trabajadores_view/eliminar_trabajador_view' : (BuildContext context) => EliminarTrabajadorView(),
  '/home_page/trabajadores_view/contratos_anexos' : (BuildContext context) => ContratosAnexos(),
};