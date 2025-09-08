import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/logistica/herramientas/modificar_herramientas_view.dart';
import 'package:sistema_acviis/frontend/views/contratos/contratos_view.dart';
import 'package:sistema_acviis/frontend/views/home_page.dart';
import 'package:sistema_acviis/frontend/views/logistica/herramientas/agregar_herramientas_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/logistica_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/agregar_trabajador_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/contratos_anexos.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/eliminar_trabajadores_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/modificar_trabajadores_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/trabajadores_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/eliminar_contratos_view.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/frontend/views/proveedores/modificar_proveedor_view.dart';
import 'package:sistema_acviis/frontend/views/proveedores/proveedores_view.dart';
import 'package:sistema_acviis/frontend/views/proveedores/agregar_proveedor_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/herramientas/herramientas_view.dart';
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
  '/home_page/trabajadores_view/eliminar_trabajador_view' : (BuildContext context){
    final args = ModalRoute.of(context)!.settings.arguments;
    final trabajadores = (args is List<dynamic>) ? args : <dynamic>[];
    return EliminarTrabajadorView(trabajadores: trabajadores);
  },
  '/home_page/trabajadores_view/eliminar_contratos_view': (BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
  final trabajadoresSeleccionados = args['trabajadores'] ?? <dynamic>[];
  return EliminarContratosView(
    trabajadoresSeleccionados: trabajadoresSeleccionados,
  );
},
  '/home_page/trabajadores_view/contratos_anexos' : (BuildContext context) => ContratosAnexos(),
  '/home_page/trabajadores_view/modificar_trabajadores_view' : (BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return ModificarTrabajadoresView(trabajadores: args);
  },
  '/home_page/proveedores_view/modificar_proveedor_view': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Proveedor;
    return ModificarProveedorView(proveedor: args);
  },
  '/home_page/proveedores_view': (BuildContext context) => ProveedoresView(),
  '/home_page/proveedores_view/agregar_proveedor_view': (BuildContext context) => AgregarProveedorView(),
  
  '/home_page/logistica_view' : (BuildContext context) => LogisticaView(),

  '/home_page/logistica_view/herramientas_view' : (BuildContext context) => HerramientasView(),
  '/home_page/logistica_view/herramientas_view/agregar_herramientas_view' : (BuildContext context) => AgregarHerramientasView(),
  '/home_page/logistica_view/herramientas_view/modificar_herramientas_view': (BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
  return ModificarHerramientasView(herramientas: args);
  },
};
