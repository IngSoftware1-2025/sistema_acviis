import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';


class GestionarItemizadosView extends StatefulWidget {
  const GestionarItemizadosView({super.key});

  @override
  State<GestionarItemizadosView> createState() => _GestionarItemizadosViewState();
}

class _GestionarItemizadosViewState extends State<GestionarItemizadosView> {
  String? obraId;
  String? obraNombre;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => isLoading = true);
      try {
        final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
        obraId = args['obraId'];
        obraNombre = args['obraNombre'];
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener datos de la obra: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    obraId = args['obraId'];
    obraNombre = args['obraNombre'];

    return PrimaryScaffold(
      title: 'Gestionar Itemizados obra ${obraNombre != null ? " - $obraNombre" : ""}',
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
    );
  }
}