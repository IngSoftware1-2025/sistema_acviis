import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/agregar_comentario_func.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/anexos/agregar_anexo_contrato_dialog.dart';
import 'package:sistema_acviis/frontend/widgets/checkbox.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/frontend/widgets/expansion_tile.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_estado_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/comentarios/create_comentario.dart';
import 'package:sistema_acviis/providers/comentarios_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/eliminar_trabajador_func.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/modificar_trabajador_func.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/crear_contrato_func.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/eliminar_contrato_func.dart';

class ListaTrabajadores extends StatefulWidget {
  const ListaTrabajadores({super.key});
  @override
  State<ListaTrabajadores> createState() => _ListaTrabajadoresState();
}

class _ListaTrabajadoresState extends State<ListaTrabajadores> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context, listen: false);
      trabajadoresProvider.fetchTrabajadores().then((_) {
        if (!mounted) return; // <-- Agregado
        Provider.of<CheckboxProvider>(context, listen: false)
            .setCheckBoxes(trabajadoresProvider.trabajadores.length);
      });
    });
  }

  //  función para descargar y abrir el PDF:
  // esto no hay que cambiarlo de lugar???????????
  Future<void> descargarFichaPDF(BuildContext context, String trabajadorId, String rut) async {
    try {
      final url = Uri.parse('http://localhost:3000/trabajadores/$trabajadorId/ficha-pdf');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/ficha_trabajador_${rut ?? trabajadorId}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF descargado. Abriendo...')),
        );
        await OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar la ficha PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrabajadoresProvider>();
    final checkboxProvider = context.watch<CheckboxProvider>();
    final listaDeComentarios = Provider.of<ComentariosProvider>(context).comentarios;

    // --- SINCRONIZA LOS CHECKBOXES ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (checkboxProvider.checkBoxes.length != provider.trabajadores.length + 1) {
        checkboxProvider.setCheckBoxes(provider.trabajadores.length);
      }
    });

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.trabajadores.isEmpty) {
      return const Center(child: Text('No hay trabajadores para mostrar.'));
    }
    if (checkboxProvider.checkBoxes.length != (provider.trabajadores.length + 1)) {
      return const Center(child: CircularProgressIndicator());
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
                    child: PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[0])),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                      'Lista de Trabajadores Registrados',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 0,
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Opciones', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const Divider(),
              // ExpansionTiles para cada trabajador usando PersonalizedExpansionTile
              ...List.generate(provider.trabajadores.length, (i) {
                final trabajador = provider.trabajadores[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    children: [
                      PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[i + 1]),
                      Expanded(
                        child: PersonalizedExpansionTile(
                          trabajador: trabajador,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'Eliminar') { // ===================== ELIMINAR TRABAJADOR
                                await mostrarDialogoEliminarTrabajador(
                                  context: context,
                                  trabajador: trabajador,
                                  crearComentario: crearComentario,
                                  actualizarEstadoTrabajador: actualizarEstadoTrabajador,
                                  fetchTrabajadores: provider.fetchTrabajadores,
                                );
                              } else if (value == 'Modificar') {// ===================== MODIFICAR TRABAJADOR
                                await mostrarDialogoModificarTrabajador(
                                  context: context, 
                                  trabajador: trabajador, 
                                  fetchTrabajadores: provider.fetchTrabajadores
                                  );
                              } else if (value == 'Eliminar Contrato') { // ===================== ELIMINAR CONTRATO
                                await mostrarDialogoEliminarContrato(
                                  context: context, 
                                  trabajador: trabajador, 
                                  fetchTrabajadores: provider.fetchTrabajadores,
                                );
                              } else if (value == 'Crear Contrato') { // ===================== CREAR CONTRATO
                                await mostrarDialogoCrearContrato(
                                  context: context, 
                                  trabajador: trabajador, 
                                  fetchTrabajadores: provider.fetchTrabajadores,
                                );
                              } else if (value == 'Agregar Comentario') { // ===================== AGREGAR COMENTARIO
                                await mostrarDialogoAgregarComentarioTrabajador(
                                  context: context, 
                                  trabajador: trabajador, 
                                  fetchTrabajadores: provider.fetchTrabajadores,
                                  );
                              } else if (value == 'Agregar Comentario a Contrato') { // ===================== AGREGAR COMENTARIO A CONTRATO
                                await mostrarDialogoAgregarComentarioContrato(
                                  context: context, 
                                  trabajador: trabajador, 
                                  fetchTrabajadores: provider.fetchTrabajadores,
                                );
                              } else if (value == 'Agregar anexo a contrato') { // ===================== AGREGAR ANEXO A CONTRATO
                                showDialog(
                                  context: context,
                                    builder: (context) {
                                    // Busca el contrato activo del trabajador
                                    final contratos = trabajador.contratos ?? [];
                                    final contratoActivo = contratos.firstWhere(
                                      (c) => c['estado'] == 'Activo',
                                      orElse: () => null,
                                    );
                                    final idContrato = contratoActivo != null ? contratoActivo['id'] : null;
                                    final idTrabajador = trabajador.id;
                                    return AgregarAnexoContratoDialog(
                                      idContrato: idContrato, 
                                      idTrabajador: idTrabajador,
                                      trabajador: trabajador,
                                    );
                                    },
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Modificar',
                                child: Text('Modificar'),
                              ),
                              const PopupMenuItem(
                                value: 'Eliminar',
                                child: Text('Eliminar'),
                              ),
                              const PopupMenuItem(
                                value: 'Eliminar Contrato',
                                child: Text('Eliminar Contrato'),
                              ),
                              const PopupMenuItem(
                                value: 'Crear Contrato',
                                child: Text('Crear Contrato'),
                              ),
                              const PopupMenuItem(
                                value: 'Agregar Comentario',
                                child: Text('Agregar Comentario al Trabajador'),
                              ),
                              const PopupMenuItem(
                                value: 'Agregar Comentario a Contrato',
                                child: Text('Agregar Comentario a Contrato'),
                              ),
                              const PopupMenuItem(
                                value: 'Agregar anexo a contrato',
                                child: Text('Agregar anexo a contrato'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                          // callback al botón para generar PDF:
                          pdfCallback: () {
                            descargarFichaPDF(context, trabajador.id, trabajador.rut);
                          },
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
  }
}