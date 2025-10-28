import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:sistema_acviis/models/historial_asistencia.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';

class HistorialAsistenciaView extends StatefulWidget {
  const HistorialAsistenciaView({super.key});

  @override
  State<HistorialAsistenciaView> createState() => _HistorialAsistenciaViewState();
}

class _HistorialAsistenciaViewState extends State<HistorialAsistenciaView> {
  String? obraId;
  String? obraNombre;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      setState(() {
        obraId = args?['obraId']?.toString();
        obraNombre = args?['obraNombre']?.toString();
      });
    });
  }

  // Función: selecciona un .xlsx y lo sube al backend
  // Retorna el id devuelto por el servidor o null si falla
  Future<String?> pickAndUploadXlsx() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;

      final picked = result.files.first;
      Uint8List? bytes = picked.bytes;
      String fileName = picked.name;

      if (bytes == null && picked.path != null) {
        bytes = await File(picked.path!).readAsBytes();
      }
      if (bytes == null) return null;

      final uri = Uri.parse('http://localhost:3000/historial-asistencia/upload');
      final request = http.MultipartRequest('POST', uri);

      // Adjuntar obraId
      if (obraId != null) request.fields['obraId'] = obraId!;

      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final map = json.decode(response.body) as Map<String, dynamic>;
        return map['fileId']?.toString();
      } else {
        debugPrint('Upload failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('pickAndUploadXlsx error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Obra${obraNombre != null ? " - $obraNombre" : ""}',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              obraNombre ?? 'Nombre de obra no disponible',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    obraId != null ? 'ID de obra: $obraId' : 'ID de obra no disponible',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final fileId = await pickAndUploadXlsx();
                    if (!mounted) return;
                    if (fileId != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Archivo subido correctamente. ID: $fileId')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se subió el archivo')),
                      );
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Subir archivo de asistencia'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Aquí puedes mostrar más información de la obra.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
