import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Future<String?> subirCertificadoEpp(File archivoPdf, BuildContext context) async {
  final uri = Uri.parse('http://localhost:3000/api/epp/upload-certificado');
  final request = http.MultipartRequest('POST', uri);
  
  // Leer bytes del archivo
  final bytes = await archivoPdf.readAsBytes();
  
  request.files.add(
    http.MultipartFile.fromBytes(
      'certificado',
      bytes,
      filename: archivoPdf.path.split('/').last,
      contentType: MediaType('application', 'pdf'),
    ),
  );
  
  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final respJson = jsonDecode(respStr);
      return respJson['fileId'];
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir el certificado')),
        );
      }
      return null;
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    return null;
  }
}