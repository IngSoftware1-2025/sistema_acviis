import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/contratos/contratos_view.dart';
import 'package:sistema_acviis/frontend/views/home_page.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/agregar_trabajador_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/contratos_anexos.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/eliminar_trabajadores_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/modificar_trabajadores_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/trabajadores_view.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/eliminar_contratos_view.dart';
//Referente a logistica (EPP)
import 'package:sistema_acviis/frontend/views/logistica/logistica_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/epp_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/agregar_epp_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/subir_certificado_view.dart';
import 'package:sistema_acviis/models/epp.dart';
import 'package:sistema_acviis/frontend/views/logistica/asignar_epp_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/modificar_epp_view.dart';
//Proveedores
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/frontend/views/proveedores/modificar_proveedor_view.dart';
import 'package:sistema_acviis/frontend/views/proveedores/proveedores_view.dart';
import 'package:sistema_acviis/frontend/views/proveedores/agregar_proveedor_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/herramientas_view.dart';
/*
  Aqui se importaran todas las vistas presentes en el sistema
  (Para el primer incremento serian todas las vistas asociadas
  con trabajador y contratos)
  
  Actualizado para el segundo incremento.
*/
final Map<String, WidgetBuilder> routes = { 
  '/home_page' : (BuildContext context) => HomePage(),
  '/home_page/trabajadores_view': (BuildContext context) => TrabajadoresView(),
  '/home_page/contratos_view' : (BuildContext context) => ContratosView(),
  '/home_page/logistica_view': (BuildContext context) => LogisticaView(), //Vista nueva
  '/home_page/logistica_view/epp_view': (BuildContext context) => EppView(), //Vista nueva
  '/home_page/logistica_view/epp_view/agregar_epp_view': (BuildContext context) => AgregarEppView(), //Vista nueva
  '/home_page/logistica_view/epp_view/subir_certificado_view': (BuildContext context) { //Vista nueva
    final epp = ModalRoute.of(context)!.settings.arguments as EPP;
    return SubirCertificadoView(epp: epp);
  }, 
  '/home_page/logistica_view/epp_view/asignar_epp_view': (BuildContext context) { //Vista nueva
    final epp = ModalRoute.of(context)!.settings.arguments as EPP;
    return AsignarEppView(epp: epp);
  },
  '/home_page/logistica_view/epp_view/modificar_epp_view': (BuildContext context) { //Vista nueva
    final epp = ModalRoute.of(context)!.settings.arguments as EPP;
    return ModificarEppView(epp: epp);
  },
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
  
  '/home_page/herramientas_view' : (BuildContext context) => HerramientasView(),
};
