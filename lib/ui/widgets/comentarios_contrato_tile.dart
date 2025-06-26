import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/comentarios.dart';
import 'package:sistema_acviis/backend/controllers/comentarios/get_comentarios.dart';

class ComentariosContratoTile extends StatefulWidget {
  final String idContrato;

  const ComentariosContratoTile({
    super.key,
    required this.idContrato,
  });

  @override
  State<ComentariosContratoTile> createState() => _ComentariosContratoTileState();
}

class _ComentariosContratoTileState extends State<ComentariosContratoTile> {
  late Future<List<Comentario>> _comentariosFuture;

  @override
  void initState() {
    super.initState();
    _comentariosFuture = getComentariosPorContrato(widget.idContrato);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.comment),
      title: const Text('Comentarios del contrato'),
      children: [
        FutureBuilder<List<Comentario>>(
          future: _comentariosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                title: Text('Cargando comentarios...'),
              );
            }
            if (snapshot.hasError) {
              return ListTile(
                title: Text('Error: ${snapshot.error}'),
              );
            }
            final comentarios = snapshot.data ?? [];
            if (comentarios.isEmpty) {
              return const ListTile(
                title: Text('Sin comentarios asociados al contrato'),
              );
            }
            return Column(
              children: comentarios
                  .map(
                    (comentario) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(comentario.comentario),
                      subtitle: Text(
                        'ID Trabajador: ${comentario.idTrabajador}\nFecha: ${comentario.fecha.toLocal()}',
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}