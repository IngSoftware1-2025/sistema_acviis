import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/editar_trabajador_dialog.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_trabajador.dart';

Future<void> mostrarDialogoModificarTrabajador({
  required BuildContext context,
  required dynamic trabajador,
  required Future<void> Function() fetchTrabajadores,
}) async {
  final resultado = await showDialog(
    context: context,
    builder: (context) => EditarTrabajadorDialog(trabajador: trabajador),
  );
  
  if (resultado is Map<String, dynamic>) {
    final cambios = <String, Map<String, dynamic>>{};
    final nuevosDatos = resultado['trabajador'] as Map<String, dynamic>;
    
    // Compara datos del trabajador para detectar cambios
    nuevosDatos.forEach((key, value) {
      final original = trabajador.toJson()[key];
      if (original != value) {
        cambios[key] = {'antes': original, 'despues': value};
      }
    });

    // Si no hay cambios, muestra mensaje y retorna
    if (cambios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se realizaron cambios')),
      );
      return;
    }

    // Muestra el resumen de cambios para confirmación
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambios'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Los siguientes datos serán modificados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Trabajador: ${trabajador.nombreCompleto ?? ''}'),
              Text('RUT: ${trabajador.rut ?? ''}'),
              const SizedBox(height: 12),
              const Text('Cambios:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...cambios.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key}:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '  Antes: ${e.value['antes']}',
                    ),
                    Text(
                      '  Después: ${e.value['despues']}',
                    ),
                  ],
                ),
              )),
            ],
          ),
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

    // Si se confirma la modificación, procede a actualizar
    if (confirmacion == true) {
      try {
        await actualizarTrabajador(trabajador.id, nuevosDatos);
        await fetchTrabajadores();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos del trabajador actualizados correctamente'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar trabajador: $e'),
            ),
          );
        }
      }
    }
  }
}