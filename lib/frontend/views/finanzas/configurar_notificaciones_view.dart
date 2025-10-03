import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/notificacion.dart';
import 'package:sistema_acviis/providers/notificaciones_provider.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<NotificacionesProvider>(context, listen: false).fetchConfiguracion()
    );
  }

  Future<void> guardarConfiguracion() async {
    final provider = Provider.of<NotificacionesProvider>(context, listen: false);

    final config = NotificacionConfig(
      id: provider.configuracion?.id ?? 1, 
      diasAntes: int.tryParse(_diasAntesController.text) ?? 3,
      diasDespues: int.tryParse(_diasDespuesController.text) ?? 0,
    );

    final success = await provider.saveConfiguracion(config);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configuración guardada correctamente")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${provider.error ?? "Desconocido"}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificacionesProvider>(context);

    if (provider.isLoading) {
      return const PrimaryScaffold(
        title: 'Configurar Notificaciones',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.configuracion != null) {
      _diasAntesController.text = provider.configuracion!.diasAntes.toString();
      _diasDespuesController.text = provider.configuracion!.diasDespues.toString();
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
                decoration: const InputDecoration(labelText: "Días antes del vencimiento"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diasDespuesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Días después del vencimiento"),
              ),
              const SizedBox(height: 24),
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
