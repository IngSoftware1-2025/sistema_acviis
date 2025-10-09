import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/charla.dart';
import 'package:sistema_acviis/providers/obras_provider.dart';

class ObrasView extends StatefulWidget {
  const ObrasView({super.key});

  @override
  State<ObrasView> createState() => _ObrasViewState();
}

class _ObrasViewState extends State<ObrasView> {
  @override
  void initState() {
    super.initState();
    // Cargar los datos cuando la vista se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObrasProvider>(context, listen: false).fetchObras();
    });
  }

  @override
  Widget build(BuildContext context) {
    final obrasProvider = Provider.of<ObrasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Charlas por Obra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Crear Nueva Obra',
            onPressed: () {
              // TODO: Navegar a la pantalla de creación de obra
            },
          ),
        ],
      ),
      body: obrasProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => obrasProvider.fetchObras(),
              child: ListView.builder(
                itemCount: obrasProvider.obras.length,
                itemBuilder: (context, index) {
                  final obra = obrasProvider.obras[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: ExpansionTile(
                      leading: const Icon(Icons.construction),
                      title: Text(
                        obra.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Estado: ${obra.estado ?? 'No definido'}'),
                      children: [
                        if (obra.charlas.isEmpty)
                          const ListTile(
                            title: Text('No hay charlas programadas.'),
                          ),
                        ...obra.charlas.map((charla) => _buildCharlaTile(context, charla)),
                        // Botón para agregar nueva charla
                        ListTile(
                          leading: const Icon(Icons.add, color: Colors.green),
                          title: const Text('Programar nueva charla'),
                          onTap: () {
                            // TODO: Implementar CU074 - Programación de charlas
                            print('Programar charla para la obra: ${obra.nombre}');
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCharlaTile(BuildContext context, Charla charla) {
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(charla.fechaProgramada);
    return ListTile(
      title: Text('Charla programada para: $fechaFormateada'),
      subtitle: Text('Estado: ${charla.estado}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.blue),
            tooltip: 'Registrar Asistencia (CU075)',
            onPressed: () {
              // TODO: Implementar CU075
              print('Registrar asistencia para charla ID: ${charla.id}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.purple),
            tooltip: 'Visualizar Asistencia (CU076)',
            onPressed: charla.asistencias.isEmpty ? null : () {
              // TODO: Implementar CU076
              print('Visualizar asistencia para charla ID: ${charla.id}');
            },
          ),
        ],
      ),
    );
  }
}

