import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';

class ListaTrabajadores extends StatefulWidget {
  const ListaTrabajadores({super.key});
  @override
  State<ListaTrabajadores> createState() => _ListaTrabajadoresState();
}

class _ListaTrabajadoresState extends State<ListaTrabajadores> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrabajadoresProvider>(context, listen: false).fetchTrabajadores();
      // Iria el provider de Contratos de trabajadores 
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrabajadoresProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Define un ancho mínimo para la tabla
    final double tableWidth = MediaQuery.of(context).size.width > 600
        ? MediaQuery.of(context).size.width
        : 600;
    
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: tableWidth - normalPadding * 2,
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Flexible(flex: 4, fit: FlexFit.tight, child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                Flexible(flex: 3, fit: FlexFit.tight, child: Text('Cargo', style: TextStyle(fontWeight: FontWeight.bold))),
                Flexible(flex: 3, fit: FlexFit.tight, child: Text('Obra', style: TextStyle(fontWeight: FontWeight.bold))),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Opciones', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const Divider(),
            // Rows
            ...provider.trabajadores.map((trabajador) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Row(
                  children: [
                    Flexible(flex: 4, fit: FlexFit.tight, child: Text(trabajador.nombreCompleto)),
                    Flexible(flex: 3, fit: FlexFit.tight, child: Text('Pendiente')), // Cargo real si lo tienes
                    Flexible(flex: 3, fit: FlexFit.tight, child: Text('Pendiente')), // Obra real si lo tienes
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            // Aqui van cosas xd
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Text('Eliminar'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}