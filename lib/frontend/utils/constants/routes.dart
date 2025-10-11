import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/logistica/herramientas/modificar_herramientas_view.dart';
import 'package:sistema_acviis/frontend/views/contratos/contratos_view.dart';
import 'package:sistema_acviis/frontend/views/home_page.dart';
import 'package:sistema_acviis/frontend/views/logistica/herramientas/agregar_herramientas_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/vehiculos/agregar_vehiculos_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/vehiculos/modificar_vehiculos_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/vehiculos/vehiculos_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/agregar_ordenes_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/modificar_ordenes_view.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/ordenes_view.dart';
import 'package:sistema_acviis/frontend/views/obras/agregar_obras_view.dart';
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
import 'package:sistema_acviis/frontend/views/logistica/herramientas/herramientas_view.dart';
import 'package:sistema_acviis/frontend/views/finanzas/finanzas_main_view.dart';
import 'package:sistema_acviis/frontend/views/finanzas/facturas_view.dart';
import 'package:sistema_acviis/frontend/views/finanzas/pagos_pendientes_view.dart';
import 'package:sistema_acviis/frontend/views/finanzas/configurar_notificaciones_view.dart';
import 'package:sistema_acviis/frontend/views/obras/obras_view.dart';
/*
  Aqui se importaran todas las vistas presentes en el sistema.
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
  
  '/home_page/logistica_view/herramientas_view' : (BuildContext context) => HerramientasView(),
  '/home_page/logistica_view/herramientas_view/agregar_herramientas_view' : (BuildContext context) => AgregarHerramientasView(),
  '/home_page/logistica_view/herramientas_view/modificar_herramientas_view': (BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
  return ModificarHerramientasView(herramientas: args);
  },

  '/home_page/logistica_view/vehiculos_view' : (BuildContext context) => VehiculosView(),
  '/home_page/logistica_view/vehiculos_view/agregar_vehiculos_view' : (BuildContext context) => AgregarVehiculosView(),
  '/home_page/logistica_view/vehiculos_view/modificar_vehiculos_view': (BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
  return ModificarVehiculosView(vehiculos: args);
  },
  
  '/home_page/logistica_view/ordenes_view' : (BuildContext context) => OrdenesView(),
  '/home_page/logistica_view/ordenes_view/agregar_ordenes_view' : (BuildContext context) => AgregarOrdenesView(),
  '/home_page/logistica_view/modificar_ordenes_view': (BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return ModificarOrdenesView(ordenes: args.cast());
  },

  '/home_page/finanzas_main_view': (BuildContext context) => FinanzasMainView(),
  '/home_page/finanzas_main_view/facturas_view': (BuildContext context) => FacturasView(),
  '/home_page/finanzas_main_view/pagos_pendientes_view': (BuildContext context) => PagosPendientesView(),
  '/home_page/finanzas_main_view/configurar_notificaciones_view': (BuildContext context) => ConfigurarNotificacionesView(),

  '/home_page/obras_view': (BuildContext context) => const ObrasView(),
  '/home_page/obras_view/agregar_obras_view': (BuildContext context) => const AgregarObrasView(),
};
