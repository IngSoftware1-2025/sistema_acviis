import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sistema_acviis/models/pagos.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/create_pago.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/pagos_provider.dart';

class AgregarFacturaDialog extends StatefulWidget {
  const AgregarFacturaDialog({super.key});

  @override
  State<AgregarFacturaDialog> createState() => _AgregarFacturaDialogState();
}

class _AgregarFacturaDialogState extends State<AgregarFacturaDialog> {
  final _formKey = GlobalKey<FormState>();
  // Campos de la factura
  String nombreMandante = '';
  String rutMandante = '';
  String direccionComercial = '';
  String codigo = '';
  String servicioOfrecido = '';
  double valor = 0;
  DateTime? plazoPagar;
  String estadoPago = '';
  String fotografiaId = '';

  late TextEditingController nombreMandanteController;
  late TextEditingController rutMandanteController;
  late TextEditingController direccionComercialController;
  late TextEditingController codigoController;
  late TextEditingController servicioOfrecidoController;
  late TextEditingController valorController;
  late TextEditingController estadoPagoController;
  late TextEditingController fotografiaIdController;
  String tipoPago = 'factura';
  bool sentido = true; // true: hacia otra empresa, false: hacia mi empresa

  bool mostrarResumen = false;

  @override
  void initState() {
    super.initState();
    final random = Random();
    nombreMandante = 'Mandante ${random.nextInt(1000)}';
    rutMandante = '1${random.nextInt(99999999)}-${random.nextInt(9)}';
    direccionComercial = 'Calle ${random.nextInt(100)}';
    codigo = 'Codigo ${random.nextInt(10)}';
    servicioOfrecido = 'Servicio ${random.nextInt(5)}';
    valor = (random.nextDouble() * 100000).roundToDouble();
    plazoPagar = DateTime.now().add(Duration(days: random.nextInt(60)));
    estadoPago = random.nextBool() ? 'Pagado' : 'Pendiente';
    fotografiaId = 'foto${random.nextInt(1000)}';
    sentido = true; // siempre "hacia otra empresa"

    nombreMandanteController = TextEditingController(text: nombreMandante);
    rutMandanteController = TextEditingController(text: rutMandante);
    direccionComercialController = TextEditingController(text: direccionComercial);
    codigoController = TextEditingController(text: codigo);
    servicioOfrecidoController = TextEditingController(text: servicioOfrecido);
    valorController = TextEditingController(text: valor.toString());
    estadoPagoController = TextEditingController(text: estadoPago);
    fotografiaIdController = TextEditingController(text: fotografiaId);
  }

  void enviarFactura() async {
    final factura = Pago(
      id: '', // No enviar
      nombreMandante: nombreMandanteController.text,
      rutMandante: rutMandanteController.text,
      direccionComercial: direccionComercialController.text,
      codigo: codigoController.text,
      servicioOfrecido: servicioOfrecidoController.text,
      valor: double.tryParse(valorController.text) ?? 0,
      plazoPagar: plazoPagar ?? DateTime.now(),
      estadoPago: estadoPagoController.text,
      fotografiaId: fotografiaIdController.text,
      tipoPago: tipoPago,
      sentido: sentido,
      visualizacion: 'activo',
    );
    try {
      await crearPago(factura);
      if (mounted) {
        await Provider.of<PagosProvider>(context, listen: false).fetchFacturas();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la factura: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(mostrarResumen ? 'Resumen de Factura' : 'Agregar Factura'),
      actions: [
        if (!mostrarResumen)
          TextButton(
            child: Text('Siguiente'),
            onPressed: () {
              if (_formKey.currentState?.validate() == true && plazoPagar != null) {
                setState(() => mostrarResumen = true);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Completa todos los campos')),
                );
              }
            },
          ),
        if (mostrarResumen)
          TextButton(
            onPressed: enviarFactura,
            child: Text('Aceptar y Guardar'),
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
                  Text('Mandante: $nombreMandante'),
                  Text('RUT: $rutMandante'),
                  Text('Dirección: $direccionComercial'),
                  Text('Código: $codigo'),
                  Text('Servicio: $servicioOfrecido'),
                  Text('Valor: $valor'),
                  Text('Plazo de pago: ${plazoPagar?.toLocal().toString().split(' ')[0]}'),
                  Text('Estado: $estadoPago'),
                  Text('Fotografía ID: $fotografiaId'),
                  Text('Tipo: $tipoPago'),
                  Text('Sentido: ${sentido ? 'hacia otra empresa' : 'hacia mi empresa'}'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Nombre Mandante'),
                      controller: nombreMandanteController,
                      onChanged: (v) => nombreMandante = v,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'RUT Mandante'),
                      controller: rutMandanteController,
                      onChanged: (v) => rutMandante = v,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Dirección Comercial'),
                      controller: direccionComercialController,
                      onChanged: (v) => direccionComercial = v,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Código'),
                      controller: codigoController,
                      onChanged: (v) => codigo = v,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Servicio Ofrecido'),
                      controller: servicioOfrecidoController,
                      onChanged: (v) => servicioOfrecido = v,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                      controller: valorController,
                      onChanged: (v) => valor = double.tryParse(v) ?? 0,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Estado Pago'),
                      controller: estadoPagoController,
                      onChanged: (v) => estadoPago = v,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Fotografía ID'),
                      controller: fotografiaIdController,
                      onChanged: (v) => fotografiaId = v,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
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
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (!mounted) return;
                        if (fecha != null) setState(() => plazoPagar = fecha);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}