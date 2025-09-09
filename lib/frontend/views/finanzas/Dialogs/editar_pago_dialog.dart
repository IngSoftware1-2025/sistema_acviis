import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/pagos.dart';
import 'package:sistema_acviis/providers/pagos_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class EditarPagoDialog extends StatefulWidget {
  final Pago pago;
  const EditarPagoDialog({super.key, required this.pago});

  @override
  State<EditarPagoDialog> createState() => _EditarPagoDialogState();
}

class _EditarPagoDialogState extends State<EditarPagoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreMandanteController;
  late TextEditingController rutMandanteController;
  late TextEditingController direccionComercialController;
  late TextEditingController codigoController;
  late TextEditingController servicioOfrecidoController;
  late TextEditingController valorController;
  late TextEditingController estadoPagoController;
  late TextEditingController tipoPagoController;
  late TextEditingController visualizacionController;
  DateTime? plazoPagar;
  bool sentido = true;
  PlatformFile? archivoPdf;
  String fotografiaId = '';

  @override
  void initState() {
    super.initState();
    final p = widget.pago;
    nombreMandanteController = TextEditingController(text: p.nombreMandante);
    rutMandanteController = TextEditingController(text: p.rutMandante);
    direccionComercialController = TextEditingController(text: p.direccionComercial);
    codigoController = TextEditingController(text: p.codigo);
    servicioOfrecidoController = TextEditingController(text: p.servicioOfrecido);
    valorController = TextEditingController(text: p.valor.toString());
    estadoPagoController = TextEditingController(text: p.estadoPago);
    tipoPagoController = TextEditingController(text: p.tipoPago);
    visualizacionController = TextEditingController(text: p.visualizacion);
    plazoPagar = p.plazoPagar;
    sentido = p.sentido;
    fotografiaId = p.fotografiaId;
  }

  @override
  void dispose() {
    nombreMandanteController.dispose();
    rutMandanteController.dispose();
    direccionComercialController.dispose();
    codigoController.dispose();
    servicioOfrecidoController.dispose();
    valorController.dispose();
    estadoPagoController.dispose();
    tipoPagoController.dispose();
    visualizacionController.dispose();
    super.dispose();
  }

  Future<void> actualizarPagoDialog() async {
    if (_formKey.currentState!.validate()) {
      String? nuevoPdfId = fotografiaId;
      if (archivoPdf != null) {
        final uri = Uri.parse('http://localhost:3000/finanzas/upload-pdf');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(
          http.MultipartFile.fromBytes(
            'pdf',
            archivoPdf!.bytes!,
            filename: archivoPdf!.name,
            contentType: MediaType('application', 'pdf'),
          ),
        );
        final response = await request.send();
        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final respJson = jsonDecode(respStr);
          nuevoPdfId = respJson['fileId'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir el PDF')),
          );
          return;
        }
      }

      final data = {
        'nombre_mandante': nombreMandanteController.text,
        'rut_mandante': rutMandanteController.text,
        'direccion_comercial': direccionComercialController.text,
        'codigo': codigoController.text,
        'servicio_ofrecido': servicioOfrecidoController.text,
        'valor': double.tryParse(valorController.text) ?? widget.pago.valor,
        'plazo_pagar': (plazoPagar ?? widget.pago.plazoPagar).toIso8601String(),
        'estado_pago': estadoPagoController.text,
        'fotografia_id': nuevoPdfId,
        'tipo_pago': tipoPagoController.text,
        'sentido': sentido,
        'visualizacion': visualizacionController.text,
      };

      try {
        await Provider.of<PagosProvider>(context, listen: false)
            .actualizarPagoFactura(widget.pago.id, data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pago actualizado correctamente')),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el pago: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Pago'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreMandanteController,
                decoration: const InputDecoration(labelText: 'Nombre Mandante'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: rutMandanteController,
                decoration: const InputDecoration(labelText: 'RUT Mandante'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: direccionComercialController,
                decoration: const InputDecoration(labelText: 'Dirección Comercial'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: codigoController,
                decoration: const InputDecoration(labelText: 'Código'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: servicioOfrecidoController,
                decoration: const InputDecoration(labelText: 'Servicio Ofrecido'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: valorController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: estadoPagoController,
                decoration: const InputDecoration(labelText: 'Estado Pago'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: tipoPagoController,
                decoration: const InputDecoration(labelText: 'Tipo de Pago'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: visualizacionController,
                decoration: const InputDecoration(labelText: 'Visualización'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              SwitchListTile(
                title: Text(sentido ? 'Sentido: hacia otra empresa' : 'Sentido: hacia mi empresa'),
                value: sentido,
                onChanged: (v) => setState(() => sentido = v),
              ),
              ListTile(
                title: Text(plazoPagar == null
                    ? 'Selecciona fecha de plazo de pago'
                    : 'Plazo de pago: ${plazoPagar!.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: plazoPagar ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (fecha != null) setState(() => plazoPagar = fecha);
                },
              ),
              ListTile(
                title: Text(archivoPdf == null
                    ? 'Selecciona archivo PDF'
                    : 'Archivo seleccionado: ${archivoPdf!.name}'),
                trailing: const Icon(Icons.attach_file),
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                    withData: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    setState(() {
                      archivoPdf = result.files.first;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: actualizarPagoDialog,
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}