import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';
import 'package:sistema_acviis/frontend/widgets/checkbox.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/frontend/widgets/expansion_tile.dart';
import 'package:sistema_acviis/frontend/widgets/epp_expansion_tile.dart';

class ListaEpp extends StatefulWidget {
  const ListaEpp({super.key});

  @override
  State<ListaEpp> createState() => _ListaEppState();
}

class _ListaEppState extends State<ListaEpp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    
    final eppProvider = Provider.of<EppProvider>(context, listen: false);
    final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
    
    if (eppProvider.eppsCompletos.isEmpty) {
      await eppProvider.fetchEpps();
    }
    
    if (mounted) {
      checkboxProvider.setCheckBoxes(eppProvider.epps.length);
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _updateCheckboxes(EppProvider eppProvider, CheckboxProvider checkboxProvider) {
    // Solo actualizar si el número de checkboxes no coincide
    final expectedLength = eppProvider.epps.length + 1;
    if (checkboxProvider.checkBoxes.length != expectedLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          checkboxProvider.setCheckBoxes(eppProvider.epps.length);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EppProvider, CheckboxProvider>(
      builder: (context, eppProvider, checkboxProvider, child) {
        // Actualizar checkboxes si es necesario
        _updateCheckboxes(eppProvider, checkboxProvider);

        if (eppProvider.isLoading && !_isInitialized) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (eppProvider.error != null) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: normalPadding),
                  Text(
                    'Error al cargar EPPs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: normalPadding / 2),
                  Text(
                    eppProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: normalPadding),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Si no hay EPPs en la lista completa
        if (eppProvider.eppsCompletos.isEmpty) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 64, color: Colors.grey),
                  SizedBox(height: normalPadding),
                  Text(
                    'No hay EPPs registrados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: normalPadding / 2),
                  Text(
                    'Comienza agregando el primer equipo de protección personal',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: normalPadding),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/home_page/logistica_view/epp_view/agregar_epp_view',
                      );
                    },
                    icon: Icon(Icons.add),
                    label: Text('Agregar EPP'),
                  ),
                ],
              ),
            ),
          );
        }

        // Si hay EPPs pero ninguno pasa los filtros
        if (eppProvider.epps.isEmpty && eppProvider.hayFiltrosActivos) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.orange),
                  SizedBox(height: normalPadding),
                  Text(
                    'No se encontraron EPPs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: normalPadding / 2),
                  Text(
                    'No hay EPPs que coincidan con los filtros aplicados',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: normalPadding),
                  ElevatedButton.icon(
                    onPressed: () {
                      eppProvider.limpiarFiltros();
                    },
                    icon: Icon(Icons.clear),
                    label: Text('Limpiar Filtros'),
                  ),
                ],
              ),
            ),
          );
        }

        // Verificar que los checkboxes estén sincronizados
        if (checkboxProvider.checkBoxes.length != (eppProvider.epps.length + 1)) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final double tableWidth = MediaQuery.of(context).size.width > 600
            ? MediaQuery.of(context).size.width
            : 600;

        return Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: tableWidth - normalPadding * 2,
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Flexible(
                        flex: 0,
                        fit: FlexFit.tight,
                        child: PrimaryCheckbox(
                          customCheckbox: checkboxProvider.checkBoxes[0]
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            eppProvider.hayFiltrosActivos 
                              ? 'EPPs Filtrados (${eppProvider.epps.length})'
                              : 'Lista de EPPs Registrados (${eppProvider.epps.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 0,
                        fit: FlexFit.tight,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Opciones',
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // ExpansionTiles para cada EPP
                  ...List.generate(eppProvider.epps.length, (i) {
                    final epp = eppProvider.epps[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Row(
                        children: [
                          PrimaryCheckbox(
                            customCheckbox: checkboxProvider.checkBoxes[i + 1],
                            key: ValueKey('checkbox_${epp.id}'), // ← Clave única
                          ),
                          Expanded(
                            child: EppExpansionTile(
                              epp: epp,
                              key: ValueKey('expansion_${epp.id}'), // ← Clave única
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  await _handleMenuAction(value, epp);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'Modificar',
                                    child: Text('Modificar EPP'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Eliminar',
                                    child: Text('Eliminar EPP'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Asignar',
                                    child: Text('Asignar a Trabajador'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Ver Certificado',
                                    child: Text('Ver Certificado'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Generar Reporte',
                                    child: Text('Generar Reporte'),
                                  ),
                                ],
                                icon: const Icon(Icons.more_vert),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMenuAction(String action, dynamic epp) async {
    switch (action) {
      case 'Modificar':
        Navigator.pushNamed(
          context,
          '/home_page/logistica_view/epp_view/modificar_epp_view',
          arguments: epp,
        );
        break;
      case 'Eliminar':
        await _mostrarDialogoEliminarEpp(context, epp);
        break;
      case 'Asignar':
        Navigator.pushNamed(
          context,
          '/home_page/logistica_view/epp_view/asignar_epp_view',
          arguments: epp,
        );
        break;
      case 'Ver Certificado':
        await _abrirCertificado(context, epp);
        break;
      case 'Generar Reporte':
        await _generarReporteEpp(context, epp);
        break;
    }
  }

  // Función para eliminar EPP individual
  Future<void> _mostrarDialogoEliminarEpp(BuildContext context, dynamic epp) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que deseas eliminar este EPP?'),
                SizedBox(height: normalPadding),
                Text(
                  'Tipo: ${epp.tipo}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Cantidad: ${epp.cantidad}'),
                Text('Obras asignadas: ${epp.obrasAsignadas.join(", ")}'),
                SizedBox(height: normalPadding),
                Text(
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(context).pop();
                
                final eppProvider = Provider.of<EppProvider>(context, listen: false);
                final success = await eppProvider.eliminarEpp(epp.id!);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('EPP eliminado exitosamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar EPP: ${eppProvider.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Función para abrir certificado
  Future<void> _abrirCertificado(BuildContext context, dynamic epp) async {
    if (epp.certificadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este EPP no tiene certificado asociado')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abriendo certificado...')),
      );
      
      // TODO: Implementar descarga desde MongoDB GridFS
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir certificado: $e')),
      );
    }
  }

  // Función para generar reporte de EPP
  Future<void> _generarReporteEpp(BuildContext context, dynamic epp) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando reporte de EPP...')),
      );
      
      // TODO: Implementar generación de reporte
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar reporte: $e')),
      );
    }
  }
}