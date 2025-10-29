import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';

class AgregarEppView extends StatefulWidget {
  const AgregarEppView({super.key});

  @override
  State<AgregarEppView> createState() => _AgregarEppViewState();
}

class _AgregarEppViewState extends State<AgregarEppView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _cantidadController = TextEditingController();
  
  // Variables del formulario
  String? _tipoSeleccionado;
  List<String> _obrasSeleccionadas = [];
  File? _certificadoSeleccionado;
  bool _certificadoOpcional = true;
  
  // Opciones predefinidas
  final List<String> _tiposEpp = [
    'Casco de Seguridad',
    'Guantes de Trabajo',
    'Botas de Seguridad',
    'Chaleco Reflectivo',
    'Gafas de Protección',
    'Respirador/Mascarilla',
    'Arnés de Seguridad',
    'Protección Auditiva',
    'Ropa de Trabajo',
    'Equipo de Soldadura',
  ];
  
  // TODO: Estas obras deberían venir de un provider/API
  final List<String> _obrasDisponibles = [
    'Instalación Residencial Las Condes',
    'Proyecto Industrial Maipú', 
    'Mantenimiento Red Eléctrica Centro',
    'Construcción Subestación Norte',
    'Reparación Sistema Alumbrado Sur',
    'Sin asignar a obra específica',
  ];

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Agregar EPP',
      body: Consumer<EppProvider>(
        builder: (context, eppProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(normalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con instrucciones
                  _buildHeader(),
                  
                  SizedBox(height: normalPadding * 2),
                  
                  // Sección: Información Básica
                  _buildSectionHeader('Información Básica', Icons.info_outline),
                  _buildTipoEppField(),
                  SizedBox(height: normalPadding),
                  _buildCantidadField(),
                  
                  SizedBox(height: normalPadding * 2),
                  
                  // Sección: Asignación de Obras
                  _buildSectionHeader('Asignación de Obras', Icons.construction),
                  _buildObrasField(),
                  
                  SizedBox(height: normalPadding * 2),
                  
                  // Sección: Certificado (Opcional)
                  _buildSectionHeader('Certificado de Calidad', Icons.verified_user),
                  _buildCertificadoField(),
                  
                  SizedBox(height: normalPadding * 3),
                  
                  // Botones de acción
                  _buildActionButtons(eppProvider),
                  
                  SizedBox(height: normalPadding),
                  
                  // Mostrar error si existe
                  if (eppProvider.error != null)
                    _buildErrorMessage(eppProvider.error!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
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
                Text(
                  'Registro de Equipo de Protección Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: normalPadding / 2),
            Text(
              'Complete la información del EPP que desea registrar en el sistema. '
              'Los campos marcados con (*) son obligatorios.',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: normalPadding),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDarker),
          SizedBox(width: normalPadding / 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarker,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoEppField() {
    return DropdownButtonFormField<String>(
      value: _tipoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Tipo de EPP *',
        hintText: 'Seleccione el tipo de equipo',
        prefixIcon: Icon(Icons.security),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: _tiposEpp.map((tipo) => DropdownMenuItem(
        value: tipo,
        child: Text(tipo),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _tipoSeleccionado = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Debe seleccionar un tipo de EPP';
        }
        return null;
      },
    );
  }

  Widget _buildCantidadField() {
    return TextFormField(
      controller: _cantidadController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Cantidad *',
        hintText: 'Ingrese la cantidad de unidades',
        prefixIcon: Icon(Icons.format_list_numbered),
        suffix: Text('unidades'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Debe ingresar una cantidad';
        }
        final cantidad = int.tryParse(value);
        if (cantidad == null || cantidad <= 0) {
          return 'Debe ingresar un número válido mayor a 0';
        }
        if (cantidad > 9999) {
          return 'La cantidad no puede ser mayor a 9999';
        }
        return null;
      },
    );
  }

  Widget _buildObrasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccione las obras donde se utilizará este EPP:',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        SizedBox(height: normalPadding / 2),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _obrasDisponibles.map((obra) {
              final isSelected = _obrasSeleccionadas.contains(obra);
              return CheckboxListTile(
                title: Text(obra),
                subtitle: obra.contains('Sin asignar') 
                  ? Text('EPP disponible para cualquier obra', 
                      style: TextStyle(color: Colors.orange[600], fontSize: 12))
                  : null,
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      // Si selecciona "Sin asignar", deseleccionar otras
                      if (obra.contains('Sin asignar')) {
                        _obrasSeleccionadas.clear();
                        _obrasSeleccionadas.add(obra);
                      } else {
                        // Si selecciona una obra específica, quitar "Sin asignar"
                        _obrasSeleccionadas.removeWhere((o) => o.contains('Sin asignar'));
                        _obrasSeleccionadas.add(obra);
                      }
                    } else {
                      _obrasSeleccionadas.remove(obra);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
        ),
        if (_obrasSeleccionadas.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: normalPadding / 2),
            child: Text(
              'Debe seleccionar al menos una obra o "Sin asignar"',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCertificadoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _certificadoOpcional,
              onChanged: (value) {
                setState(() {
                  _certificadoOpcional = value ?? true;
                  if (_certificadoOpcional) {
                    _certificadoSeleccionado = null;
                  }
                });
              },
            ),
            Expanded(
              child: Text(
                'Registrar sin certificado (se puede agregar después)',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        
        if (!_certificadoOpcional) ...[
          SizedBox(height: normalPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(normalPadding),
            decoration: BoxDecoration(
              border: Border.all(
                color: _certificadoSeleccionado != null ? Colors.green : Colors.grey[400]!,
              ),
              borderRadius: BorderRadius.circular(8),
              color: _certificadoSeleccionado != null ? Colors.green[50] : Colors.grey[50],
            ),
            child: Column(
              children: [
                Icon(
                  _certificadoSeleccionado != null ? Icons.check_circle : Icons.upload_file,
                  size: 48,
                  color: _certificadoSeleccionado != null ? Colors.green : Colors.grey[600],
                ),
                SizedBox(height: normalPadding / 2),
                Text(
                  _certificadoSeleccionado != null 
                    ? 'Certificado seleccionado:'
                    : 'Seleccionar certificado PDF',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _certificadoSeleccionado != null ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
                if (_certificadoSeleccionado != null) ...[
                  SizedBox(height: normalPadding / 4),
                  Text(
                    _certificadoSeleccionado!.path.split('/').last,
                    style: TextStyle(fontSize: 12, color: Colors.green[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: normalPadding),
                ElevatedButton.icon(
                  onPressed: _seleccionarCertificado,
                  icon: Icon(_certificadoSeleccionado != null ? Icons.change_circle : Icons.folder_open),
                  label: Text(_certificadoSeleccionado != null ? 'Cambiar archivo' : 'Seleccionar PDF'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

Widget _buildActionButtons(EppProvider eppProvider) {
  return Row(
    children: [
      Expanded(
        child: BorderButton(
          onPressed: () {
            if (!eppProvider.isLoading) {
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
            if (!eppProvider.isLoading) {
              _registrarEpp();
            }
          },
          text: eppProvider.isLoading ? 'Registrando...' : 'Registrar EPP',
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
        setState(() {
          _certificadoSeleccionado = File(result.files.single.path!);
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

  Future<void> _registrarEpp() async {
    // Limpiar errores previos
    final eppProvider = Provider.of<EppProvider>(context, listen: false);
    eppProvider.limpiarError();

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar obras seleccionadas
    if (_obrasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos una obra'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar certificado si es requerido
    if (!_certificadoOpcional && _certificadoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un certificado PDF'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      bool success;
      
      if (_certificadoOpcional || _certificadoSeleccionado == null) {
        // Registrar sin certificado
        success = await eppProvider.registrarEPPSinCertificado(
          tipo: _tipoSeleccionado!,
          obrasAsignadas: _obrasSeleccionadas,
          cantidad: int.parse(_cantidadController.text),
        );
      } else {
        // Registrar con certificado
      
        success = await eppProvider.registrarEPP(
        context: context, // ⚡ AGREGAR ESTO
          tipo: _tipoSeleccionado!,
          obrasAsignadas: _obrasSeleccionadas,
          cantidad: int.parse(_cantidadController.text),
          certificadoPdf: _certificadoSeleccionado!,
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EPP registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
