// lib/frontend/widgets/epp_expansion_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/epp.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';
import 'package:sistema_acviis/frontend/utils/epp_pdf_generator.dart';

class EppExpansionTile extends StatefulWidget {
  final EPP epp;
  final Widget? trailing;
  final VoidCallback? certificadoCallback;

  const EppExpansionTile({
    super.key,
    required this.epp,
    this.trailing,
    this.certificadoCallback,
  });

  @override
  State<EppExpansionTile> createState() => _EppExpansionTileState();
}

class _EppExpansionTileState extends State<EppExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<EppProvider>(
      builder: (context, eppProvider, child) {
        final eppActualizado = eppProvider.epps.firstWhere(
          (e) => e.id == widget.epp.id,
          orElse: () => widget.epp,
        );
        
        // ⚡ VERIFICACIÓN SEGURA DE OBRAS ASIGNADAS
        final estaEnOficinaCentral = eppActualizado.obrasAsignadas.isNotEmpty && 
                                      eppActualizado.obrasAsignadas.first == "Oficina Central";
        
        return ExpansionTile(
          title: Text('${eppActualizado.tipo} (${eppActualizado.cantidad} unidades)'),
          subtitle: Text(
            eppActualizado.obrasAsignadas.isNotEmpty 
              ? (estaEnOficinaCentral
                  ? '📍 En Oficina Central'
                  : 'Obras: ${eppActualizado.obrasAsignadas.join(", ")}')
              : 'Sin ubicación asignada',
            style: TextStyle(
              color: estaEnOficinaCentral 
                  ? Colors.green[600] 
                  : (eppActualizado.obrasAsignadas.isNotEmpty ? Colors.blue[600] : Colors.orange[600]),
              fontSize: 12,
            ),
          ),
          leading: Icon(
            _getEppIcon(eppActualizado.tipo),
            color: _getEppColor(eppActualizado.tipo),
          ),
          trailing: widget.trailing,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  
                  final infoWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información básica del EPP
                      _buildInfoSection('Información General', [
                        _buildInfoRow('ID', eppActualizado.id?.toString() ?? 'Sin ID'),
                        _buildInfoRow('Tipo', eppActualizado.tipo),
                        _buildInfoRow('Cantidad', '${eppActualizado.cantidad} unidades'),
                        _buildInfoRow('Fecha de Registro', 
                          eppActualizado.fechaRegistro?.toLocal().toString().split(' ')[0] ?? 'No especificada'),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      // Información de certificado
                      _buildInfoSection('Certificación', [
                        _buildInfoRow('Estado de Certificado', 
                          eppActualizado.certificadoId != null ? '✅ Certificado disponible' : '❌ Sin certificado'),
                        if (eppActualizado.certificadoId != null)
                          _buildInfoRow('ID de Certificado', eppActualizado.certificadoId!),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      // Botones de acción
                      _buildActionButtons(context, eppActualizado),
                    ],
                  );

                  final obrasWidget = eppActualizado.obrasAsignadas.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: isMobile ? 0 : 16,
                            top: isMobile ? 16 : 0,
                          ),
                          child: _buildObrasAsignadas(eppActualizado.obrasAsignadas),
                        )
                      : _buildSinObrasAsignadas(eppActualizado);

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoWidget,
                        obrasWidget,
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(flex: 2, child: infoWidget),
                        Flexible(flex: 2, child: obrasWidget),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildActionButtons(BuildContext context, EPP epp) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Botón para ver/descargar certificado
        ElevatedButton.icon(
          icon: const Icon(Icons.verified_user, color: Colors.white),
          label: Text(
            epp.certificadoId != null ? 'Ver Certificado' : 'Subir Certificado',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: epp.certificadoId != null ? Colors.green : Colors.orange,
            foregroundColor: Colors.white,
          ),
          onPressed: epp.certificadoId != null 
            ? () => _descargarCertificado(context, epp) 
            : () => _subirCertificado(context, epp),
        ),
        
        // Botón para generar reporte
        ElevatedButton.icon(
          icon: const Icon(Icons.assessment, color: Colors.white),
          label: const Text('Generar Reporte', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _generarReporte(context, epp),
        ),
        
        // Botón para asignar a trabajador
        ElevatedButton.icon(
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text('Asignar', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _asignarEpp(context, epp),
        ),
      ],
    );
  }

  Widget _buildObrasAsignadas(List<String> obras) {
    // ⚡ VERIFICACIÓN SEGURA
    final enOficinaCentral = obras.isNotEmpty && obras.first == "Oficina Central";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación Actual',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        
        if (enOficinaCentral) ...[
          // ⚡ CARD ESPECIAL PARA OFICINA CENTRAL
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.warehouse, color: Colors.green),
              title: const Text(
                'Oficina Central',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Disponible para asignación a obras'),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Asignar a Obra'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _asignarAObra(context, widget.epp),
              ),
            ),
          ),
        ] else ...[
          // ⚡ MOSTRAR OBRAS NORMALES
          ...obras.map((obra) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.construction, color: Colors.orange),
              title: Text(obra),
              subtitle: const Text('Obra activa'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'detalles') {
                    _verDetallesObra(context, obra);
                  } else if (value == 'desasignar') {
                    _desasignarDeObra(context, widget.epp, obra);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detalles',
                    child: Text('Ver detalles'),
                  ),
                  const PopupMenuItem(
                    value: 'desasignar',
                    child: Text('Desasignar'),
                  ),
                ],
              ),
            ),
          )).toList(),
        ],
      ],
    );
  }

  Widget _buildSinObrasAsignadas(EPP epp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asignación de Obras',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.orange[50],
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: const Text('Sin obras asignadas'),
            subtitle: const Text('Este EPP no está asignado a ninguna obra específica'),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Asignar'),
              onPressed: () => _asignarAObra(context, epp),
            ),
          ),
        ),
      ],
    );
  }

  // Métodos de utilidad para iconos y colores
  IconData _getEppIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casco':
        return Icons.construction;
      case 'guantes':
        return Icons.back_hand;
      case 'botas':
        return Icons.hiking;
      case 'chaleco':
        return Icons.safety_check;
      case 'gafas':
        return Icons.visibility;
      case 'respirador':
      case 'mascarilla':
        return Icons.masks;
      case 'arnés':
        return Icons.security;
      default:
        return Icons.security;
    }
  }

  Color _getEppColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casco':
        return Colors.yellow[700]!;
      case 'guantes':
        return Colors.blue[700]!;
      case 'botas':
        return Colors.brown[700]!;
      case 'chaleco':
        return Colors.orange[700]!;
      case 'gafas':
        return Colors.cyan[700]!;
      case 'respirador':
      case 'mascarilla':
        return Colors.green[700]!;
      case 'arnés':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

void _descargarCertificado(BuildContext context, EPP epp) {
    if (epp.certificadoId != null && epp.certificadoId!.isNotEmpty) {
      // 1. Notificar al usuario que inició el proceso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iniciando descarga del certificado...'),
          duration: Duration(seconds: 2),
        ),
      );

      // 2. Llamar al provider para ejecutar la descarga real
      Provider.of<EppProvider>(context, listen: false)
          .descargarCertificado(context, epp.certificadoId!);
          
    } else {
      // Manejo de error si el ID es nulo (aunque el botón debería estar deshabilitado/cambiado)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Este EPP no tiene un certificado válido para descargar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _subirCertificado(BuildContext context, EPP epp) {
    Navigator.pushNamed(
      context,
      '/home_page/logistica_view/epp_view/subir_certificado_view',
      arguments: epp,
    );
  }

  Future<void> _generarReporte(BuildContext context, EPP epp) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando reporte de EPP...')),
      );
      
      await EppPdfGenerator.generarReporteEpp(epp);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte generado y descargado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _asignarEpp(BuildContext context, EPP epp) async {
    final resultado = await Navigator.pushNamed(
      context,
      '/home_page/logistica_view/epp_view/asignar_epp_view',
      arguments: epp,
    );
    
    if (resultado == true && mounted) {
      final eppProvider = Provider.of<EppProvider>(context, listen: false);
      await eppProvider.fetchEpps();
    }
  }

  void _verDetallesObra(BuildContext context, String obra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de la Obra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: $obra'),
            const Text('Estado: Activa'),
            const Text('Tipo: Instalación eléctrica'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _desasignarDeObra(BuildContext context, EPP epp, String obra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desasignación'),
        content: Text('¿Deseas desasignar este EPP de la obra "$obra"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('EPP desasignado de la obra')),
              );
            },
            child: const Text('Desasignar'),
          ),
        ],
      ),
    );
  }

  void _asignarAObra(BuildContext context, EPP epp) {
    Navigator.pushNamed(
      context,
      '/home_page/logistica_view/epp_view/asignar_epp_view',
      arguments: epp,
    );
  }
}
