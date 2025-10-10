import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/charla.dart';
import 'package:sistema_acviis/providers/obras_provider.dart';
import 'package:sistema_acviis/frontend/views/obras/programar_charla_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sistema_acviis/models/asistencia_charla.dart';
import 'package:http/http.dart' as http;

class ObrasView extends StatefulWidget {
  const ObrasView({super.key});

  @override
  State<ObrasView> createState() => _ObrasViewState();
}

class _ObrasViewState extends State<ObrasView> {
  @override
  void initState() {
    super.initState();
    // Cargar los datos cuando la vista se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObrasProvider>(context, listen: false).fetchObras();
    });
  }

  @override
  Widget build(BuildContext context) {
    final obrasProvider = Provider.of<ObrasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Charlas por Obra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Crear Nueva Obra',
            onPressed: () {
              // TODO: Navegar a la pantalla de creación de obra
            },
          ),
        ],
      ),
      body: obrasProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => obrasProvider.fetchObras(),
              child: ListView.builder(
                itemCount: obrasProvider.obras.length,
                itemBuilder: (context, index) {
                  final obra = obrasProvider.obras[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: ExpansionTile(
                      leading: const Icon(Icons.construction),
                      title: Text(
                        obra.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Estado: ${obra.estado ?? 'No definido'}'),
                      children: [
                        if (obra.charlas.isEmpty)
                          const ListTile(
                            title: Text('No hay charlas programadas.'),
                          ),
                        ...obra.charlas.map((charla) => _buildCharlaTile(context, charla, obra.id)),
                        // Botón para agregar nueva charla
                        ListTile(
                          leading: const Icon(Icons.add, color: Colors.green),
                          title: const Text('Programar nueva charla'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ProgramarCharlaDialog(
                                  obraId: obra.id,
                                  obraNombre: obra.nombre,
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _subirAsistencia(BuildContext context, String charlaId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true, // <-- ¡Añadimos esto para cargar los bytes del archivo!
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final provider = Provider.of<ObrasProvider>(context, listen: false);

      // No usamos await aquí. Simplemente iniciamos la subida.
      // El provider se encargará de todo, incluyendo la notificación.
      provider.subirAsistencia(
        charlaId: charlaId,
        fileName: file.name,
        fileBytes: file.bytes!,
      );
    }
  }

  // Modificamos la función para que reciba el ID de la charla y la obra
  Future<void> _visualizarAsistencias(BuildContext context, String obraId, String charlaId) async {
    final provider = Provider.of<ObrasProvider>(context, listen: false);

    // Mostramos un diálogo de carga mientras se actualizan los datos
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PopScope(canPop: false, child: Center(child: CircularProgressIndicator())),
    );

    // Buscamos la obra actualizada
    final obraActualizada = await provider.fetchObraById(obraId);

    if (!context.mounted) return;
    Navigator.of(context).pop(); // Cerramos el diálogo de carga

    if (obraActualizada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar los datos.')));
      return;
    }

    // Encontramos la charla y sus asistencias actualizadas
    final charlaActualizada = obraActualizada.charlas.firstWhere((c) => c.id == charlaId);
    final asistencias = charlaActualizada.asistencias;

    if (asistencias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay archivos de asistencia para esta charla.')));
      return;
    }

    // Mostramos el diálogo con los datos frescos
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Usamos StatefulBuilder para poder actualizar el contenido del diálogo
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Archivos de Asistencia'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: asistencias.length,
                  itemBuilder: (context, index) {
                    final asistencia = asistencias[index];
                    return ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: Text(asistencia.nombreArchivo),
                      onTap: () async {
                        final url = Uri.parse(asistencia.urlArchivo);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('No se pudo abrir el archivo: ${asistencia.urlArchivo}')),
                          );
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Eliminar archivo',
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: dialogContext,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: Text('¿Estás seguro de que deseas eliminar el archivo "${asistencia.nombreArchivo}"? Esta acción no se puede deshacer.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            final success = await provider.eliminarAsistencia(asistencia.id);
                            if (success) {
                              // Si se eliminó con éxito, actualizamos la lista local y redibujamos el diálogo
                              setState(() {
                                asistencias.removeAt(index);
                              });
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cerrar'))],
            );
          },
        );
      },
    );
  }

  Widget _buildCharlaTile(BuildContext context, Charla charla, String obraId) {
    // Usamos un Consumer para que solo este widget se reconstruya cuando cambie el estado de subida
    final obrasProvider = context.watch<ObrasProvider>();
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(charla.fechaProgramada);

    return ListTile(
      title: Text('Charla programada para: $fechaFormateada'),
      subtitle: Text('Estado: ${charla.estado}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          obrasProvider.isUploading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.0))
              : IconButton(icon: const Icon(Icons.upload_file, color: Colors.blue), tooltip: 'Registrar Asistencia (CU075)', onPressed: () => _subirAsistencia(context, charla.id)),
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.purple),
            tooltip: 'Visualizar Asistencia (CU076)',
            onPressed: () => _visualizarAsistencias(context, obraId, charla.id),
          ),
        ],
      ),
    );
  }
}
