import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sistema_acviis/models/pagos.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/pagos_provider.dart';
import 'package:file_picker/file_picker.dart';

class AgregarFacturaCajaChicaDialog extends StatefulWidget {
  const AgregarFacturaCajaChicaDialog({super.key});

  @override
  State<AgregarFacturaCajaChicaDialog> createState() => _AgregarFacturaCajaChicaDialogState();
}

class _AgregarFacturaCajaChicaDialogState extends State<AgregarFacturaCajaChicaDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Campos específicos para caja chica
  String numeroFactura = '';
  String servicioOfrecido = 'Gasto Caja Chica';
  double valor = 0;
  String estadoPago = 'Pagado'; // Por defecto pagado para caja chica
  
  // Campos con valores por defecto para caja chica
  String nombreMandante = 'Caja Chica';
  String rutMandante = '';
  String direccionComercial = 'Oficina Principal';
  String codigo = '';
  DateTime? fechaFactura;

  late TextEditingController numeroFacturaController;
  late TextEditingController servicioOfrecidoController;
  late TextEditingController valorController;
  late TextEditingController rutMandanteController;

  String tipoPago = 'caja_chica';
  bool sentido = false; // false: gasto de la empresa
  bool mostrarResumen = false;
  PlatformFile? archivoPdf;

  @override
  void initState() {
    super.initState();
    final random = Random();
    
    // Generar datos por defecto
    numeroFactura = 'CC-${random.nextInt(999999).toString().padLeft(6, '0')}';
    codigo = 'CC-${random.nextInt(9999).toString().padLeft(4, '0')}';
    rutMandante = 'N/A'; // Para caja chica puede no tener RUT específico
    valor = (random.nextDouble() * 50000).roundToDouble(); // Montos típicos de caja chica
    fechaFactura = DateTime.now();

    numeroFacturaController = TextEditingController(text: numeroFactura);
    servicioOfrecidoController = TextEditingController(text: servicioOfrecido);
    valorController = TextEditingController(text: valor.toString());
    rutMandanteController = TextEditingController(text: rutMandante);
  }

  @override
  void dispose() {
    numeroFacturaController.dispose();
    servicioOfrecidoController.dispose();
    valorController.dispose();
    rutMandanteController.dispose();
    super.dispose();
  }

  void crearFacturaCajaChica() async {
    String? pdfId;
    if (archivoPdf != null) {
      pdfId = await Provider.of<PagosProvider>(context, listen: false)
          .subirPDF(archivoPdf!, context);
      if (pdfId == null) return;
    }

    final pago = Pago(
      id: '',
      nombreMandante: nombreMandante,
      rutMandante: rutMandanteController.text,
      direccionComercial: direccionComercial,
      codigo: codigo,
      servicioOfrecido: servicioOfrecidoController.text,
      valor: double.tryParse(valorController.text) ?? 0,
      plazoPagar: fechaFactura ?? DateTime.now(),
      estadoPago: estadoPago,
      fotografiaId: pdfId ?? '',
      tipoPago: tipoPago,
      sentido: sentido,
      visualizacion: 'activo',
    );

    try {
      await Provider.of<PagosProvider>(context, listen: false).agregarPagosFacturas(pago);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la factura de caja chica: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(mostrarResumen ? 'Resumen Factura Caja Chica' : 'Registrar Factura Caja Chica'),
      actions: [
        if (!mostrarResumen)
          TextButton(
            child: Text('Siguiente'),
            onPressed: () {
              if (_formKey.currentState?.validate() == true && fechaFactura != null) {
                if (archivoPdf == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Debe adjuntar la imagen de la factura (PDF)')),
                  );
                  return;
                }
                setState(() => mostrarResumen = true);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Complete todos los campos obligatorios')),
                );
              }
            },
          ),
        if (mostrarResumen)
          TextButton(
            onPressed: () {
              if (archivoPdf == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Debe adjuntar la imagen de la factura (PDF)')),
                );
                return;
              }
              crearFacturaCajaChica();
            },
            child: Text('Registrar Factura'),
          ),
        TextButton(
          child: Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
      content: mostrarResumen
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo: Factura Caja Chica', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Número de Factura: $numeroFactura'),
                  Text('Servicio/Concepto: ${servicioOfrecidoController.text}'),
                  Text('Valor: \$${valorController.text}'),
                  Text('Fecha: ${fechaFactura?.toLocal().toString().split(' ')[0]}'),
                  Text('Estado: $estadoPago'),
                  Text('RUT Proveedor: ${rutMandanteController.text}'),
                  if (archivoPdf != null)
                    Text('Imagen adjunta: ${archivoPdf!.name}'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info explicativa
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Registre facturas y gastos menores de caja chica',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Número de factura (campo principal requerido)
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Número de la Factura *',
                        hintText: 'Ej: 001234567',
                        prefixIcon: Icon(Icons.receipt),
                        border: OutlineInputBorder(),
                      ),
                      controller: numeroFacturaController,
                      onChanged: (v) => numeroFactura = v,
                      validator: (v) => v == null || v.isEmpty ? 'Número de factura es obligatorio' : null,
                    ),
                    SizedBox(height: 12),

                    // Concepto/Servicio
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Concepto del Gasto *',
                        hintText: 'Ej: Materiales de oficina, Combustible, etc.',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      controller: servicioOfrecidoController,
                      validator: (v) => v == null || v.isEmpty ? 'Concepto es obligatorio' : null,
                    ),
                    SizedBox(height: 12),

                    // Valor
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Monto *',
                        prefixText: '\$ ',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: valorController,
                      validator: (v) => v == null || v.isEmpty ? 'Monto es obligatorio' : null,
                    ),
                    SizedBox(height: 12),

                    // RUT del proveedor (opcional para caja chica)
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'RUT Proveedor (opcional)',
                        hintText: '12.345.678-9',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      controller: rutMandanteController,
                    ),
                    SizedBox(height: 16),

                    // Fecha de la factura
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(fechaFactura == null
                          ? 'Seleccionar fecha de la factura *'
                          : 'Fecha: ${fechaFactura!.toLocal().toString().split(' ')[0]}'),
                      leading: Icon(Icons.calendar_today, color: Colors.blue),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (!mounted) return;
                        if (fecha != null) setState(() => fechaFactura = fecha);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Adjuntar imagen de la factura (PDF)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: archivoPdf == null ? Colors.red.shade300 : Colors.green.shade300,
                        ),
                      ),
                      child: ListTile(
                        title: Text(archivoPdf == null
                            ? 'Adjuntar imagen de la factura (PDF) *'
                            : 'Archivo: ${archivoPdf!.name}'),
                        subtitle: archivoPdf == null 
                            ? Text('Requerido', style: TextStyle(color: Colors.red.shade600))
                            : Text('Archivo seleccionado', style: TextStyle(color: Colors.green.shade600)),
                        leading: Icon(
                          Icons.attach_file, 
                          color: archivoPdf == null ? Colors.red : Colors.green,
                        ),
                        trailing: Icon(Icons.upload_file),
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
