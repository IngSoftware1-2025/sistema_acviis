import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/comentarios/create_comentario.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/comentarios_provider.dart';

//funcino para agregar comentario a un trabajador
Future<void> mostrarDialogoAgregarComentarioTrabajador({
  required BuildContext context,
  required dynamic trabajador,
  required Future<void> Function() fetchTrabajadores,
}) async {
  final comentarioController = TextEditingController();
  bool comentarioInvalido = false;

  // Primer diálogo: solicitar comentario
  final confirmar = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar comentario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Por favor, ingresa un comentario acerca del trabajador:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: comentarioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Comentario',
                  errorText: comentarioInvalido ? 'El comentario es obligatorio' : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (comentarioInvalido) setState(() => comentarioInvalido = false);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (comentarioController.text.trim().isEmpty) {
                  setState(() => comentarioInvalido = true);
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Siguiente'),
            ),
          ],
        ),
      );
    },
  );

  if (confirmar == true) {
    // Segundo diálogo: mostrar resumen y confirmar
    final confirmarFinal = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar comentario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas agregar el siguiente comentario al trabajador?'),
            const SizedBox(height: 12),
            Text('Nombre: ${trabajador.nombreCompleto ?? ''}'),
            Text('RUT: ${trabajador.rut ?? ''}'),
            const SizedBox(height: 12),
            const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              comentarioController.text.trim(),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmarFinal == true) {
      try {
        // Crear el comentario
        await crearComentario(
          idTrabajador: trabajador.id,
          comentario: comentarioController.text.trim(),
          fecha: DateTime.now(),
          idContrato: null,
        );
        
        await fetchTrabajadores();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comentario agregado correctamente'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al agregar comentario: $e'),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se canceló el comentario al trabajador')),
      );
    }
  }
}

Future<void> mostrarDialogoAgregarComentarioContrato({
  required BuildContext context,
  required dynamic trabajador,
  required Future<void> Function() fetchTrabajadores,
}) async {
  // Verificar si hay contratos activos
  final contratosActivos = (trabajador.contratos ?? [])
      .where((contrato) => contrato['estado'] == 'Activo')
      .toList();

  if (contratosActivos.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay contrato activo para agregar comentario.')),
    );
    return;
  }

  final contrato = contratosActivos.first;
  final comentarioController = TextEditingController();
  bool comentarioInvalido = false;

  // Primer diálogo: solicitar comentario
  final confirmarComentario = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar comentario a contrato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del contrato:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Trabajador: ${trabajador.nombreCompleto ?? ''}'),
              Text('RUT: ${trabajador.rut ?? ''}'),
              Text('Contrato ID: ${contrato['id']}'),
              Text('Estado: ${contrato['estado']}'),
              Text('Plazo: ${contrato['plazo_de_contrato']}'),
              const SizedBox(height: 16),
              const Text(
                'Ingresa tu comentario:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: comentarioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Comentario',
                  errorText: comentarioInvalido ? 'El comentario es obligatorio' : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (comentarioInvalido) setState(() => comentarioInvalido = false);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (comentarioController.text.trim().isEmpty) {
                  setState(() => comentarioInvalido = true);
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Siguiente'),
            ),
          ],
        ),
      );
    },
  );

  if (confirmarComentario == true) {
    // Segundo diálogo: confirmación final
    final confirmarFinal = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar comentario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas agregar el siguiente comentario al contrato?'),
            const SizedBox(height: 12),
            const Text('Datos del trabajador:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Nombre: ${trabajador.nombreCompleto ?? ''}'),
            Text('RUT: ${trabajador.rut ?? ''}'),
            const SizedBox(height: 12),
            const Text('Datos del contrato:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('ID: ${contrato['id']}'),
            Text('Estado: ${contrato['estado']}'),
            Text('Plazo: ${contrato['plazo_de_contrato']}'),
            const SizedBox(height: 12),
            const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                comentarioController.text.trim(),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmarFinal == true) {
      try {
        // Crear el comentario asociado al contrato
        await crearComentario(
          idTrabajador: trabajador.id,
          idContrato: contrato['id'].toString(),
          comentario: comentarioController.text.trim(),
          fecha: DateTime.now(),
        );
        
        // Actualizar los providers
        await Provider.of<ComentariosProvider>(context, listen: false).fetchComentarios();
        await fetchTrabajadores();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comentario agregado al contrato con éxito'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al agregar comentario: $e'),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se canceló el comentario al contrato')),
      );
    }
  }
}