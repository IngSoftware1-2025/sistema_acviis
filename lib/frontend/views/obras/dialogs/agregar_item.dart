import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> mostrarDialogoAgregarItem(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController cantidadCtrl = TextEditingController();
  final TextEditingController valorCtrl = TextEditingController();

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Agregar nuevo ítem'),
      content: SingleChildScrollView(
        child: Form(
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
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: cantidadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (unidades)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: valorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Valor total estimado',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
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
                'monto_disponible': int.parse(valorCtrl.text),
              });
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    ),
  );
}
