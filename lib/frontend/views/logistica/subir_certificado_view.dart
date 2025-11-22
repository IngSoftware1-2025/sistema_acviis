import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sistema_acviis/models/epp.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';

class SubirCertificadoView extends StatefulWidget {
  final EPP epp;

  const SubirCertificadoView({
    super.key,
    required this.epp,
  });

  @override
  State<SubirCertificadoView> createState() => _SubirCertificadoViewState();
}

class _SubirCertificadoViewState extends State<SubirCertificadoView> {
  File? _certificadoSeleccionado;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Subir Certificado EPP',
      body: Consumer<EppProvider>(
        builder: (context, eppProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(normalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del EPP
                _buildEppInfo(),
                
                SizedBox(height: normalPadding * 2),
                
                // Estado actual del certificado
                _buildEstadoActual(),
                
                SizedBox(height: normalPadding * 2),
                
                // Sección de subir nuevo certificado
                _buildSeccionUpload(),
                
                SizedBox(height: normalPadding * 3),
                
                // Botones de acción
                _buildActionButtons(eppProvider),
                
                SizedBox(height: normalPadding),
                
                // Mostrar error si existe
                if (eppProvider.error != null)
                  _buildErrorMessage(eppProvider.error!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEppInfo() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(normalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.blue[700], size: 28),
                SizedBox(width: normalPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.epp.tipo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        'ID: ${widget.epp.id} | Cantidad Total: ${widget.epp.cantidadTotal} unidades',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoActual() {
    final tieneCertificado = widget.epp.certificadoId != null && widget.epp.certificadoId!.isNotEmpty;
    
    return Card(
      color: tieneCertificado ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(normalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  tieneCertificado ? Icons.verified_user : Icons.warning,
                  color: tieneCertificado ? Colors.green[700] : Colors.orange[700],
                  size: 24,
                ),
                SizedBox(width: normalPadding / 2),
                Text(
                  'Estado Actual del Certificado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: tieneCertificado ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: normalPadding / 2),
            Text(
              tieneCertificado 
                ? 'Este EPP tiene un certificado válido registrado'
                : 'Este EPP no tiene certificado registrado',
              style: TextStyle(
                color: tieneCertificado ? Colors.green[600] : Colors.orange[600],
                fontSize: 14,
              ),
            ),
            if (tieneCertificado) ...[
              SizedBox(height: normalPadding / 2),
              Text(
                'ID del certificado: ${widget.epp.certificadoId}',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _certificadoSeleccionado != null 
            ? 'Reemplazar Certificado'
            : 'Subir Nuevo Certificado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarker,
          ),
        ),
        SizedBox(height: normalPadding),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(normalPadding * 1.5),
          decoration: BoxDecoration(
            border: Border.all(
              color: _certificadoSeleccionado != null ? Colors.green : Colors.grey[400]!,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _certificadoSeleccionado != null ? Colors.green[50] : Colors.grey[50],
          ),
          child: Column(
            children: [
              Icon(
                _certificadoSeleccionado != null ? Icons.check_circle : Icons.upload_file,
                size: 64,
                color: _certificadoSeleccionado != null ? Colors.green : Colors.grey[600],
              ),
              SizedBox(height: normalPadding),
              Text(
                _certificadoSeleccionado != null 
                  ? 'Certificado seleccionado:'
                  : 'Seleccionar certificado PDF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _certificadoSeleccionado != null ? Colors.green[700] : Colors.grey[700],
                ),
              ),
              if (_certificadoSeleccionado != null) ...[
                SizedBox(height: normalPadding / 2),
                Text(
                  _certificadoSeleccionado!.path.split('/').last,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: normalPadding / 2),
                Text(
                  'Tamaño: ${(_getFileSize(_certificadoSeleccionado!) / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[500],
                  ),
                ),
              ],
              SizedBox(height: normalPadding),
              ElevatedButton.icon(
                onPressed: _seleccionarCertificado,
                icon: Icon(_certificadoSeleccionado != null ? Icons.change_circle : Icons.folder_open),
                label: Text(_certificadoSeleccionado != null ? 'Cambiar archivo' : 'Seleccionar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: normalPadding),
        
        // Información adicional
        Container(
          padding: EdgeInsets.all(normalPadding),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  SizedBox(width: normalPadding / 2),
                  Text(
                    'Requisitos del archivo:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: normalPadding / 2),
              Text(
                '• Formato: PDF únicamente\n'
                '• Tamaño máximo: 10 MB\n'
                '• El archivo debe ser legible y de buena calidad\n'
                '• Debe contener información válida del certificado',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(EppProvider eppProvider) {
    final canUpload = _certificadoSeleccionado != null && !_isUploading && !eppProvider.isLoading;
    
    return Row(
      children: [
        Expanded(
          child: BorderButton(
            onPressed: () {
              if (!_isUploading && !eppProvider.isLoading) {
                Navigator.pop(context);
              }
            },
            text: 'Cancelar',
            size: Size(double.infinity, 50),
          ),
        ),
        SizedBox(width: normalPadding),
        Expanded(
          flex: 2,
          child: PrimaryButton(
            onPressed: () {
              if (canUpload) {
                _subirCertificado(eppProvider);
              }
            },
            text: _isUploading || eppProvider.isLoading 
              ? 'Subiendo...' 
              : 'Subir Certificado',
            size: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(normalPadding),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          SizedBox(width: normalPadding / 2),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarCertificado() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        
        // Verificar tamaño máximo (10 MB)
        if (fileSize > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El archivo es demasiado grande. Máximo 10 MB.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        
        setState(() {
          _certificadoSeleccionado = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _subirCertificado(EppProvider eppProvider) async {
    if (_certificadoSeleccionado == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Usar el método modificarEPP para actualizar con nuevo certificado
      final success = await eppProvider.modificarEPP(
        context: context, 
        id: widget.epp.id!,
        tipo: widget.epp.tipo,
        cantidadTotal: widget.epp.cantidadTotal,
        nuevoCertificado: _certificadoSeleccionado!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificado subido exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir certificado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  int _getFileSize(File file) {
    return file.lengthSync();
  }
}
