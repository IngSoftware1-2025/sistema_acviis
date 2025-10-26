import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> mostrarDialogoAgregarItem(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();
  final montoCtrl = TextEditingController();

  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Agregar ítem al itemizado',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del ítem',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cantidadCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad (unidades)',
                border: OutlineInputBorder(),
              ),
              validator: (v){
                if(v == null || v.isEmpty) return 'Campo requerido';
                if(int.tryParse(v) == null) return 'Debe ser un número entero';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor total estimado (CLP)',
                border: OutlineInputBorder(),
              ),
              validator: (v){
                if(v == null || v.isEmpty) return 'Campo requerido';
                if(int.tryParse(v) == null) return 'Debe ser un número válido';
                return null;
              },
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'nombre': nombreCtrl.text.trim(),
                'cantidad': int.parse(cantidadCtrl.text),
                'valor_total': int.parse(montoCtrl.text),
              });
            }
          },
          child: const Text('Guardar ítem'),
        ),
      ],
    ),
  );
}
