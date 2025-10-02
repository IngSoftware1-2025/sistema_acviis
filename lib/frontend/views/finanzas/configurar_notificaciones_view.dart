import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';

class ConfigurarNotificacionesView extends StatefulWidget {
  const ConfigurarNotificacionesView({super.key});

  @override
  State<ConfigurarNotificacionesView> createState() => _ConfigurarNotificacionesViewState();
}

class _ConfigurarNotificacionesViewState extends State<ConfigurarNotificacionesView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _diasAntesController = TextEditingController();
  final TextEditingController _diasDespuesController = TextEditingController();

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:3000/finanzas/configuracion-notificaciones"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _diasAntesController.text = (data['diasantes'] ?? 3).toString();
          _diasDespuesController.text = (data['diasdespues'] ?? 0).toString();
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> guardarConfiguracion() async {
    final diasantes = int.tryParse(_diasAntesController.text) ?? 3;
    final diasdespues = int.tryParse(_diasDespuesController.text) ?? 0;

    final body = {"diasantes": diasantes, "diasdespues": diasdespues};

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/finanzas/configurar-notificaciones"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Configuración guardada correctamente")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión con el servidor")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return PrimaryScaffold(
        title: 'Configurar Notificaciones',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PrimaryScaffold(
      title: 'Configurar Notificaciones',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _diasAntesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Días antes del vencimiento"),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _diasDespuesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Días después del vencimiento"),
              ),
              SizedBox(height: 24),
              PrimaryButton(
                text: "Guardar",
                onPressed: guardarConfiguracion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
