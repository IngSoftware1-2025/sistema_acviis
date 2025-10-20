import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/descargar_anexo_pdf.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/frontend/widgets/comentarios_contrato_tile.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/anexos/agregar_anexo_contrato_dialog.dart';

class PersonalizedExpansionTile extends StatefulWidget {
  final Trabajador trabajador;
  final Widget? trailing;
  final VoidCallback? pdfCallback;

  const PersonalizedExpansionTile({
    super.key,
    required this.trabajador,
    this.trailing,
    this.pdfCallback,
  });

  @override
  State<PersonalizedExpansionTile> createState() => _PersonalizedExpansionTileState();
}

class _PersonalizedExpansionTileState extends State<PersonalizedExpansionTile> {
  @override
  Widget build(BuildContext context) {
    final t = widget.trabajador;
    
    return ExpansionTile(
      title: Text(t.nombreCompleto),
      leading: const Icon(Icons.keyboard_arrow_down),
      trailing: widget.trailing,
      onExpansionChanged: (expanded) {
        if (expanded) {
          final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context, listen: false);
          trabajadoresProvider.fetchTrabajadorId(t.id);
        }
      },
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<TrabajadoresProvider>(
            builder: (context, trabajadoresProvider, child) {
              if (trabajadoresProvider.trabajadorIsLoading(t.id)) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final infoWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${t.id}'),
                      Text('Nombre: ${t.nombreCompleto}'),
                      Text('Estado Civil: ${t.estadoCivil}'),
                      Text('RUT: ${t.rut}'),
                      Text('Fecha de Nacimiento: ${t.fechaDeNacimiento.toIso8601String().split('T')[0]}'),
                      Text('Dirección: ${t.direccion}'),
                      Text('Correo Electrónico: ${t.correoElectronico}'),
                      Text('Sistema de Salud: ${t.sistemaDeSalud}'),
                      Text('Previsión AFP: ${t.previsionAfp}'),
                      Text('Obra en la que trabaja: ${t.obraEnLaQueTrabaja}'),
                      Text('Rol que asume en la obra: ${t.rolQueAsumeEnLaObra}'),
                      Text('Estado en la empresa: ${t.estado}'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                        label: const Text('Generar ficha PDF', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: widget.pdfCallback ?? () {},
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.beach_access, color: Colors.white),
                        label: const Text('Generar documento vacaciones', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () {
                          final contratos = t.contratos;
                          final contratoActivo = contratos.isNotEmpty ? contratos.firstWhere(
                            (c) => (c['estado'] ?? '').toString().toLowerCase() == 'activo',
                            orElse: () => null,
                          ) : null;
                          final idContrato = contratoActivo != null ? contratoActivo['id'] : null;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AgregarAnexoContratoDialog(
                                idContrato: idContrato,
                                idTrabajador: t.id,
                                trabajador: t,
                                tipoVacaciones: true,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );

                  final contratosWidget = t.contratos.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: isMobile ? 0 : 16,
                            top: isMobile ? 16 : 0,
                          ),
                          child: _HorizontalExpandableContracts(
                            contratos: t.contratos,
                          ),
                        )
                      : const SizedBox.shrink();

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoWidget,
                        contratosWidget,
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(flex: 2, child: infoWidget),
                        if (t.contratos.isNotEmpty)
                          Flexible(flex: 3, child: contratosWidget),
                      ],
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HorizontalExpandableContracts extends StatefulWidget {
  final List<dynamic> contratos;
  const _HorizontalExpandableContracts({
    required this.contratos,
  });

  @override
  State<_HorizontalExpandableContracts> createState() => _HorizontalExpandableContractsState();
}

class _HorizontalExpandableContractsState extends State<_HorizontalExpandableContracts> {
  int expandedIndex = 0;
  late List<dynamic> sortedContratos;

  @override
  void initState() {
    super.initState();
    sortedContratos = List<dynamic>.from(widget.contratos);
    sortedContratos.sort((a, b) {
      if ((a['estado'] ?? '').toString().toLowerCase() == 'activo') return -1;
      if ((b['estado'] ?? '').toString().toLowerCase() == 'activo') return 1;
      return 0;
    });
  }

  void _showAnexosDialog(List<dynamic> anexos) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anexos del Contrato'),
        content: anexos.isNotEmpty
            ? SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: anexos.length,
                  separatorBuilder: (context, i) => const Divider(),
                  itemBuilder: (context, i) {
                    final anexo = anexos[anexos.length - 1 - i];
                    return ListTile(
                      title: Text(anexo['tipo'] ?? 'Anexo ${anexo['id'] ?? i + 1}'),
                      subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Id_contrato: ${anexo['id_contrato'] ?? ''}'),
                        Text('Fecha de creación: ${anexo['fecha_de_creacion']?.toString().split('T').first ?? ''}'),
                        Text('Duración: ${anexo['duracion'] ?? ''}'),
                        Text('Parámetros: ${anexo['parametros'] ?? ''}'),
                        if ((anexo['comentarios'] as List?)?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...((anexo['comentarios'] as List).map<Widget>((comentario) => Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                              child: Text(
                                '- ${comentario['comentario'] ?? ''}',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                              ))),
                          ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                        icon: const Icon(Icons.remove_red_eye_sharp),
                        label: const Text('Visualizar Anexo'),
                        onPressed: () {
                          descargarAnexoPDF(context, anexo['id']);
                        },
                        ),
                      ],
                      ),
                    );
                  },

                ),
              )
            : const Text('No hay anexos para este contrato.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(sortedContratos.length, (i) {
        final contrato = sortedContratos[i];
        final anexos = contrato['anexos'] as List<dynamic>? ?? [];
        final idContrato = contrato['id']?.toString() ?? '';

        return Flexible(
          flex: expandedIndex == i ? 5 : 1,
          child: GestureDetector(
            onTap: () => setState(() => expandedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: expandedIndex == i ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: expandedIndex == i ? Colors.blue : Colors.grey,
                  width: expandedIndex == i ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: expandedIndex == i
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${contrato['id'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Plazo: ${contrato['plazo_de_contrato'] ?? ''}'),
                        Text('Estado: ${contrato['estado'] ?? ''}'),
                        Text('Fecha: ${contrato['fecha_de_contratacion'] ?? ''}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                          Expanded(
                            child: ElevatedButton.icon(
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Ver anexos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: anexos.isNotEmpty ? () => _showAnexosDialog(anexos) : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          /*
                          Expanded(
                            child: ElevatedButton.icon(
                            icon: const Icon(Icons.remove_red_eye_sharp),
                            label: const Text('Visualizar Contrato'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              descargarAnexoPDF(context, idContrato);
                            },
                            ),
                          ),
                          */
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Aquí se muestra el menú de comentarios
                        ComentariosContratoTile(idContrato: idContrato),
                      ],
                    )
                  : Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Contrato ${i + 1}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}