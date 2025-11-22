import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/herramientas/create_herramientas.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';

class AgregarHerramientasView extends StatefulWidget {
  const AgregarHerramientasView({super.key});

  @override
  State<AgregarHerramientasView> createState() => _AgregarHerramientasViewState();
}

class _AgregarHerramientasViewState extends State<AgregarHerramientasView> {
  final _formKey = GlobalKey<FormState>();

  // Por razones de testing, se agregan valores iniciales

  // ===================== Tipo
  final TextEditingController _tipoController = TextEditingController(
    text: [
      'Martillo',
      'Taladro',
      'Sierra',
      'Destornillador',
      'Llave inglesa'
    ][DateTime.now().millisecondsSinceEpoch % 5],
  );

  // ===================== Garantía (fecha en formato YYYY-MM-DD)
  final TextEditingController _garantiaController = TextEditingController(
    text: '${2024 + DateTime.now().millisecondsSinceEpoch % 3}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 12).toString().padLeft(2, '0')}-'
          '${(1 + DateTime.now().millisecondsSinceEpoch % 28).toString().padLeft(2, '0')}',
  );

  // ===================== Cantidad
  final TextEditingController _cantidadController = TextEditingController(
    text: '${1 + DateTime.now().millisecondsSinceEpoch % 20}',
  );

  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Convertir fecha de garantía a DateTime si existe
        DateTime? garantia;
        if (_garantiaController.text.isNotEmpty) {
          garantia = DateTime.parse(_garantiaController.text);
        }

        await createHerramienta(
          tipo: _tipoController.text,
          garantia: garantia,
          cantidadTotal: int.parse(_cantidadController.text),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Herramienta creada exitosamente')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home_page/logistica_view/herramientas_view',
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear herramienta: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Agregar herramienta',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo de herramienta'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _garantiaController,
                decoration: const InputDecoration(
                  labelText: 'Garantía (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null; // Opcional
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad Total'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Guardar herramienta'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}