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

class ModificarEppView extends StatefulWidget {
  final EPP epp;

  const ModificarEppView({
    super.key,
    required this.epp,
  });

  @override
  State<ModificarEppView> createState() => _ModificarEppViewState();
}

class _ModificarEppViewState extends State<ModificarEppView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _cantidadController = TextEditingController();
  final _tallaController = TextEditingController(); // [NUEVO]
  
  // Variables del formulario
  String? _tipoSeleccionado;
  File? _nuevoCertificado;
  bool _cambiarCertificado = false;
  
  // ✅ LISTA ACTUALIZADA (Debe coincidir con AgregarEppView)
  final List<String> _tiposEpp = [
    'Guante Cabritilla',
    'Guante Multiflex',
    'Tapón Auditivo',
    'Tapón Auditivo tipo Fono',
    'Antiparra de Seguridad Clara',
    'Antiparra de Seguridad Oscura',
    'Sobre lente Claro',
    'Sobre lente Oscuro',
    'Casco Azul',
    'Casco Blanco',
    'Geólogo',
    'Polera',
    'Arnés de Seguridad',
    'Cabo de Vida',
    'Zapato de Seguridad',
    'Guante Soldador',
    'Guante Mosquetero',
    'Chaqueta Soldador',
    'Polainas Soldador',
    'Careta Facial',
    'Soporte Careta Facial',
  ];
  
  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  void _inicializarDatos() {
    // 1. Cargar Cantidad Total
    _cantidadController.text = widget.epp.cantidadTotal.toString();

    // 2. Lógica para separar "Tipo (Talla)"
    // Ej: "Chaqueta Soldador (45)" -> Tipo="Chaqueta Soldador", Talla="45"
    String tipoCompleto = widget.epp.tipo;
    bool encontrado = false;

    for (String tipoBase in _tiposEpp) {
      // Verificamos si el string guardado empieza con uno de nuestros tipos base
      if (tipoCompleto.startsWith(tipoBase)) {
        // Si son idénticos, es solo el tipo sin talla
        if (tipoCompleto.length == tipoBase.length) {
          _tipoSeleccionado = tipoBase;
          encontrado = true;
          break;
        } 
        // Si es más largo, verificamos si tiene el formato " (Talla)"
        else if (tipoCompleto.length > tipoBase.length) {
          String resto = tipoCompleto.substring(tipoBase.length); // Lo que sobra
          if (resto.startsWith(' (') && resto.endsWith(')')) {
            _tipoSeleccionado = tipoBase;
            // Extraer lo que está entre paréntesis: " (45)" -> "45"
            _tallaController.text = resto.substring(2, resto.length - 1);
            encontrado = true;
            break;
          }
        }
      }
    }

    // Si no encontramos coincidencia (ej: un tipo antiguo eliminado), 
    // dejamos _tipoSeleccionado en null para que el usuario seleccione uno nuevo,
    // evitando el crash.
    if (!encontrado) {
      // Opcional: Podríamos poner el valor antiguo en 'talla' para no perderlo visualmente
      // _tallaController.text = tipoCompleto;
      debugPrint('Tipo de EPP "$tipoCompleto" no encontrado en la lista actual.');
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _tallaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Modificar EPP',
      body: Consumer<EppProvider>(
        builder: (context, eppProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(normalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: normalPadding * 2),
                  
                  // Sección: Información Básica
                  _buildSectionHeader('Información Básica', Icons.edit),
                  _buildTipoEppField(),
                  
                  // Campo de Talla Agregado
                  SizedBox(height: normalPadding),
                  _buildTallaField(),
                  
                  SizedBox(height: normalPadding),
                  _buildCantidadField(),
                  
                  SizedBox(height: normalPadding * 2),
                  
                  // Sección: Certificado
                  _buildSectionHeader('Certificado de Calidad', Icons.verified_user),
                  _buildCertificadoSection(),
                  
                  SizedBox(height: normalPadding * 3),
                  
                  _buildActionButtons(eppProvider),
                  
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
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(normalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Colors.orange[700], size: 28),
                SizedBox(width: normalPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modificando: ${widget.epp.tipo}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      Text(
                        'ID: ${widget.epp.id}',
                        style: TextStyle(color: Colors.orange[600], fontSize: 14),
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
      validator: (value) => value == null ? 'Debe seleccionar un tipo' : null,
    );
  }

  // [NUEVO] Campo para editar la talla
  Widget _buildTallaField() {
    return TextFormField(
      controller: _tallaController,
      decoration: InputDecoration(
        labelText: 'Talla o Detalle (Opcional)',
        hintText: 'Ej: L, 42, o color específico',
        prefixIcon: Icon(Icons.straighten),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCantidadField() {
    return TextFormField(
      controller: _cantidadController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Cantidad Total *',
        hintText: 'Ingrese la cantidad total de unidades',
        prefixIcon: Icon(Icons.format_list_numbered),
        suffix: Text('unidades'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese una cantidad';
        final c = int.tryParse(value);
        if (c == null || c <= 0) return 'Cantidad inválida';
        return null;
      },
    );
  }

  Widget _buildCertificadoSection() {
    final tieneCertificado = widget.epp.certificadoId != null && widget.epp.certificadoId!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(normalPadding),
          decoration: BoxDecoration(
            color: tieneCertificado ? Colors.green[50] : Colors.orange[50],
            border: Border.all(color: tieneCertificado ? Colors.green : Colors.orange),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(tieneCertificado ? Icons.check_circle : Icons.warning, 
                color: tieneCertificado ? Colors.green : Colors.orange),
              SizedBox(width: normalPadding),
              Text(tieneCertificado ? 'Certificado actual válido' : 'Sin certificado actual'),
            ],
          ),
        ),
        SizedBox(height: normalPadding),
        CheckboxListTile(
          title: Text(tieneCertificado ? 'Reemplazar certificado' : 'Agregar certificado'),
          value: _cambiarCertificado,
          onChanged: (val) => setState(() {
            _cambiarCertificado = val ?? false;
            if (!_cambiarCertificado) _nuevoCertificado = null;
          }),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (_cambiarCertificado) _buildUploadCertificado(),
      ],
    );
  }

  Widget _buildUploadCertificado() {
    return Container(
      padding: EdgeInsets.all(normalPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          Text(_nuevoCertificado != null 
            ? 'Archivo: ${_nuevoCertificado!.path.split('/').last}' 
            : 'Seleccione un PDF'),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _seleccionarCertificado,
            icon: Icon(Icons.upload_file),
            label: Text('Seleccionar PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EppProvider eppProvider) {
    return Row(
      children: [
        Expanded(
          child: BorderButton(
            onPressed: () => Navigator.pop(context),
            text: 'Cancelar',
            size: Size(double.infinity, 50),
          ),
        ),
        SizedBox(width: normalPadding),
        Expanded(
          flex: 2,
          child: PrimaryButton(
            onPressed: () {
              if (!eppProvider.isLoading) _guardarCambios(eppProvider);
            },
            text: eppProvider.isLoading ? 'Guardando...' : 'Guardar Cambios',
            size: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: EdgeInsets.all(normalPadding),
      color: Colors.red[50],
      child: Text(error, style: TextStyle(color: Colors.red)),
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
        setState(() => _nuevoCertificado = File(result.files.single.path!));
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _guardarCambios(EppProvider eppProvider) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // ⚡ RECONSTRUIR TIPO + TALLA
      String tipoFinal = _tipoSeleccionado!;
      if (_tallaController.text.trim().isNotEmpty) {
        tipoFinal = '$tipoFinal (${_tallaController.text.trim()})';
      }

      final success = await eppProvider.modificarEPP(
        context: context,
        id: widget.epp.id!,
        tipo: tipoFinal, // Enviamos el string combinado
        cantidadTotal: int.parse(_cantidadController.text),
        nuevoCertificado: _nuevoCertificado,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EPP modificado exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
