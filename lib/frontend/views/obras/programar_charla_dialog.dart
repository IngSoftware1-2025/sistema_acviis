import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/obras_provider.dart';

class ProgramarCharlaDialog extends StatefulWidget {
  final String obraId;
  final String obraNombre;

  const ProgramarCharlaDialog({
    super.key,
    required this.obraId,
    required this.obraNombre,
  });

  @override
  State<ProgramarCharlaDialog> createState() => _ProgramarCharlaDialogState();
}

class _ProgramarCharlaDialogState extends State<ProgramarCharlaDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _intervaloController = TextEditingController();

  DateTime? _fechaSeleccionada;
  bool _esPeriodica = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fechaController.dispose();
    _intervaloController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaHora(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return;

    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (hora == null) return;

    setState(() {
      _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
      _fechaController.text = DateFormat('dd/MM/yyyy HH:mm').format(_fechaSeleccionada!);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final obrasProvider = Provider.of<ObrasProvider>(context, listen: false);
    final success = await obrasProvider.programarCharla(
      obraId: widget.obraId,
      fechaProgramada: _fechaSeleccionada!,
      tipoProgramacion: _esPeriodica ? 'periodica' : 'unica',
      intervaloDias: _esPeriodica ? int.tryParse(_intervaloController.text) : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Charla programada con éxito.')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al programar la charla.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Programar Charla para\n"${widget.obraNombre}"', textAlign: TextAlign.center),
      content: _isLoading
          ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _fechaController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha y Hora',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _seleccionarFechaHora(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, seleccione una fecha y hora.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Programación periódica'),
                      value: _esPeriodica,
                      onChanged: (bool value) {
                        setState(() {
                          _esPeriodica = value;
                        });
                      },
                    ),
                    if (_esPeriodica)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          controller: _intervaloController,
                          decoration: const InputDecoration(
                            labelText: 'Repetir cada (días)',
                            hintText: 'Ej: 3',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_esPeriodica) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese el intervalo de días.';
                              }
                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                return 'Debe ser un número mayor a 0.';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Programar'),
              ),
            ],
    );
  }
}