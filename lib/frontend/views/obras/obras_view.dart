import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/models/charla.dart';
import 'package:sistema_acviis/providers/obras_provider.dart';
import 'package:sistema_acviis/frontend/views/obras/programar_charla_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/frontend/widgets/checkbox.dart';


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
      final obrasProvider = Provider.of<ObrasProvider>(context, listen: false);
      obrasProvider.fetchObras().then((_) {
        if (!mounted) return;
        // Configurar los checkboxes con la cantidad de obras
        Provider.of<CheckboxProvider>(context, listen: false)
            .setCheckBoxes(obrasProvider.obras.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final obrasProvider = Provider.of<ObrasProvider>(context);
    final checkboxProvider = Provider.of<CheckboxProvider>(context);
    
    // Sincronizar los checkboxes con la cantidad de obras
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (checkboxProvider.checkBoxes.length != obrasProvider.obras.length + 1) {
        checkboxProvider.setCheckBoxes(obrasProvider.obras.length);
      }
    });

    return PrimaryScaffold(
      title: 'Obras',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título a la izquierda
                Row(
                  children: [
                    // Checkbox para seleccionar todas las obras
                    if (checkboxProvider.checkBoxes.isNotEmpty)
                      PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[0]),
                    const SizedBox(width: 8),
                    Text(
                      'Lista de obras registradas',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Contador de seleccionados
                    Builder(
                      builder: (context) {
                        int seleccionadas = 0;
                        for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                          if (checkboxProvider.checkBoxes[i].isSelected) {
                            seleccionadas++;
                          }
                        }
                        return seleccionadas > 0 
                          ? Text(
                              '($seleccionadas seleccionadas)',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            )
                          : const SizedBox.shrink();
                      }
                    ),
                  ],
                ),
                // Botones a la derecha
                Row(
                  children: [
                    PrimaryButton(
                      text: 'Crear Nueva Obra',
                      onPressed: () {
                        Navigator.pushNamed(context, '/home_page/obras_view/agregar_obras_view');
                      },
                      size: Size(175, 40),
                    ),
                    const SizedBox(width: 10), 
                    PrimaryButton(
                      text: 'Modificar Obra(s)',
                      onPressed: () {
                        // Verificar cuáles obras están seleccionadas
                        final List<int> seleccionados = [];
                        for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                          if (checkboxProvider.checkBoxes[i].isSelected) {
                            seleccionados.add(i - 1); // Restamos 1 porque el checkbox 0 es "Seleccionar todos"
                          }
                        }
                        
                        final obrasSeleccionadas = seleccionados
                          .map((i) => obrasProvider.obras[i])
                          .toList();
                        
                        if (obrasSeleccionadas.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Debes seleccionar al menos una obra.')),
                          );
                          return;
                        }
                        Navigator.pushNamed(context, '/home_page/obras_view/modificar_obras_view',
                        arguments: obrasSeleccionadas);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Seleccionaste ${obrasSeleccionadas.length} obras para modificar')),
                        );
                      },
                      size: Size(175, 40), 
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: obrasProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await obrasProvider.fetchObras();
                      return Future<void>.value();
                    },
                    child: ListView.builder(
                      itemCount: obrasProvider.obras.length,
                      itemBuilder: (context, index) {
                        final obra = obrasProvider.obras[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          child: ExpansionTile(
                            leading: PrimaryCheckbox(
                              customCheckbox: checkboxProvider.checkBoxes[index + 1],
                            ),
                            title: Row(
                              children: [
                                Text(
                                  obra.nombre,
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SimpleDialog(
                                          title: const Text('Detalles de la obra'),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text('Responsable: ${obra.responsableEmail ?? "N/A"}'),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text('Descripción: ${obra.descripcion ?? "N/A"}'),
                                            ),
                                          ],
                                        );
                                      }
                                    );
                                  },
                                  icon: Icon(
                                    Icons.comment_outlined,
                                    size: 18,
                                  ),
                                  tooltip: 'Ver detalles',
                                )
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dirección: ${obra.direccion}',
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                if (obra.obraInicio != null && obra.obraFin != null)
                                  Text(
                                    'Duración: ${DateFormat('dd/MM/yyyy').format(obra.obraInicio!)} - ${DateFormat('dd/MM/yyyy').format(obra.obraFin!)}',
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                if (obra.jornada != null && obra.jornada!.isNotEmpty)
                                  Text(
                                    'Jornada: ${obra.jornada}',
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                              ],
                            ),
                            children: [
                              if (obra.charlas.isEmpty)
                                const ListTile(
                                  title: Text('No hay charlas programadas.'),
                                ),
                              ...obra.charlas.map((charla) => _buildCharlaTile(context, charla, obra.id)),
                              // Botón para agregar nueva charla
                              ListTile(
                                leading: const Icon(Icons.add, color: AppColors.success),
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
                              ),
                              ListTile(
                                leading: const Icon(Icons.engineering, color: AppColors.primaryDarker),
                                title: const Text('Gestionar personal de obra'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, 
                                    '/home_page/obras_view/gestionar_trabajadores_view',
                                    arguments: {
                                      'obraId': obra.id,
                                      'obraNombre': obra.nombre
                                    }
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.business_center, color: AppColors.primaryDarker),
                                title: const Text('Gestionar recursos logísticos de obra'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, 
                                    '/home_page/obras_view/gestionar_recursos_view',
                                    arguments: {
                                      'obraId': obra.id,
                                      'obraNombre': obra.nombre
                                    }
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.inventory, color: AppColors.primaryDarker),
                                title: const Text('Gestionar Itemizados de obra'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, 
                                    '/home_page/obras_view/gestionar_itemizados_view',
                                    arguments: {
                                      'obraId': obra.id,
                                      'obraNombre': obra.nombre
                                    }
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.history, color: AppColors.primaryDarker),
                                title: const Text('Historial de asistencia de obra'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, 
                                    '/home_page/obras_view/historial_asistencia_view',
                                    arguments: {
                                      'obraId': obra.id,
                                      'obraNombre': obra.nombre
                                    }
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.attach_money, color: AppColors.primaryDarker),
                                title: const Text('Gestionar recursos financieros de obra'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, 
                                    '/home_page/obras_view/gestionar_finanzas_view',
                                    arguments: {
                                      'obraId': obra.id,
                                      'obraNombre': obra.nombre
                                    }
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _subirAsistencia(BuildContext context, String charlaId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final provider = Provider.of<ObrasProvider>(context, listen: false);

      provider.subirAsistencia(
        charlaId: charlaId,
        fileName: file.name,
        fileBytes: file.bytes!,
      );
    }
  }

  Future<void> _visualizarAsistencias(BuildContext context, String obraId, String charlaId) async {
    final provider = Provider.of<ObrasProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PopScope(canPop: false, child: Center(child: CircularProgressIndicator())),
    );

    final obraActualizada = await provider.fetchObraById(obraId);

    if (!context.mounted) return;
    Navigator.of(context).pop(); 

    if (obraActualizada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar los datos.')));
      return;
    }

    final charlaActualizada = obraActualizada.charlas.firstWhere((c) => c.id == charlaId);
    final asistencias = charlaActualizada.asistencias;

    if (asistencias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay archivos de asistencia para esta charla.')));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
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
