import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<String?> subirPdfPago(PlatformFile archivoPdf, BuildContext context) async {
  final uri = Uri.parse('http://localhost:3000/finanzas/upload-pdf');
  final request = http.MultipartRequest('POST', uri);
  request.files.add(
    http.MultipartFile.fromBytes(
      'pdf',
      archivoPdf.bytes!,
      filename: archivoPdf.name,
      contentType: MediaType('application', 'pdf'),
    ),
  );
  final response = await request.send();
  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final respJson = jsonDecode(respStr);
    return respJson['fileId'];
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al subir el PDF')),
    );
    return null;
  }
}