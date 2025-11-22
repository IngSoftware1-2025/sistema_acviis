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
        
        return ExpansionTile(
          title: Text('${eppActualizado.tipo} (${eppActualizado.cantidadTotal} unidades)'),
          subtitle: eppActualizado.cantidadDisponible != null
              ? Text(
                  'Disponibles: ${eppActualizado.cantidadDisponible} unidades',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                )
              : null,
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información básica del EPP
                      _buildInfoSection('Información General', [
                        _buildInfoRow('ID', eppActualizado.id?.toString() ?? 'Sin ID'),
                        _buildInfoRow('Tipo', eppActualizado.tipo),
                        _buildInfoRow('Cantidad Total', '${eppActualizado.cantidadTotal} unidades'),
                        if (eppActualizado.cantidadDisponible != null)
                          _buildInfoRow('Cantidad Disponible', '${eppActualizado.cantidadDisponible} unidades'),
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

}
