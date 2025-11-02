import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as exl;
import 'package:sistema_acviis/models/trabajador_asistencia.dart';
import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:http/http.dart' as http;

class HistorialAsistenciaView extends StatefulWidget {
  const HistorialAsistenciaView({super.key});

  @override
  State<HistorialAsistenciaView> createState() => _HistorialAsistenciaViewState();
}

class _HistorialAsistenciaViewState extends State<HistorialAsistenciaView> {
  // Cambiar según la URL donde corre tu backend
  static const String apiBase = 'http://localhost:3000';

  // Estado para almacenar las hojas leídas: nombre -> filas (cada fila es lista de valores)
  Map<String, List<List<String>>> _sheets = {};
  String? _selectedSheet;

  // controladores horizontales separados y flag para sincronizarlos sin bucles
  final ScrollController _horizontalHeaderController = ScrollController();
  final ScrollController _horizontalBodyController = ScrollController();
  bool _isSyncingHorizontal = false;

  @override
  void initState() {
    super.initState();
    _horizontalHeaderController.addListener(() {
      if (_isSyncingHorizontal) return;
      if (!_horizontalBodyController.hasClients || !_horizontalHeaderController.hasClients) return;
      _isSyncingHorizontal = true;
      final target = _horizontalHeaderController.offset.clamp(
        0.0,
        _horizontalBodyController.position.maxScrollExtent,
      );
      try {
        _horizontalBodyController.jumpTo(target);
      } catch (_) {}
      _isSyncingHorizontal = false;
    });

    _horizontalBodyController.addListener(() {
      if (_isSyncingHorizontal) return;
      if (!_horizontalHeaderController.hasClients || !_horizontalBodyController.hasClients) return;
      _isSyncingHorizontal = true;
      final target = _horizontalBodyController.offset.clamp(
        0.0,
        _horizontalHeaderController.position.maxScrollExtent,
      );
      try {
        _horizontalHeaderController.jumpTo(target);
      } catch (_) {}
      _isSyncingHorizontal = false;
    });
  }

  @override
  void dispose() {
    _horizontalHeaderController.dispose();
    _horizontalBodyController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(BuildContext context, String? obraId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se seleccionó archivo.')));
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo leer el archivo seleccionado.')));
      return;
    }

    final uri = Uri.parse('$apiBase/historial-asistencia/upload-register');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));
    if (obraId != null) request.fields['obraId'] = obraId;
    // enviar la fecha del dispositivo (local)
    request.fields['fecha_subida'] = DateTime.now().toIso8601String();

    final scaffold = ScaffoldMessenger.of(context);
    final loading = scaffold.showSnackBar(const SnackBar(content: Text('Subiendo archivo...'), duration: Duration(days: 1)));

    try {
      final streamedResp = await request.send();
      final respStr = await streamedResp.stream.bytesToString();
      loading.close();

      if (streamedResp.statusCode >= 200 && streamedResp.statusCode < 300) {
        String msg = 'Archivo subido correctamente';
        try {
          final json = jsonDecode(respStr);
          if (json is Map && json['id_excel'] != null) {
            msg = 'Subida exitosa. id_excel: ${json['id_excel']}';
          }
        } catch (_) {}
        scaffold.showSnackBar(SnackBar(content: Text(msg)));
      } else {
        scaffold.showSnackBar(SnackBar(content: Text('Error al subir (status ${streamedResp.statusCode}): $respStr')));
      }
    } catch (e) {
      loading.close();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir archivo: $e')));
    }
  }

  // Lee XLSX, elimina filas vacías y filtra columnas con pocos datos.
  Future<void> _fetchAndReadExcel(BuildContext context, String? obraId) async {
    if (obraId == null || obraId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('obraId no disponible.')));
      return;
    }

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(const SnackBar(content: Text('Buscando último archivo para la obra...')));

    try {
      final importUri = Uri.parse('$apiBase/historial-asistencia/import/${Uri.encodeComponent(obraId)}');
      final importResp = await http.get(importUri);

      if (importResp.statusCode != 200) {
        scaffold.showSnackBar(SnackBar(content: Text('No se encontró id del archivo (status ${importResp.statusCode})')));
        return;
      }

      final importJson = jsonDecode(importResp.body);
      final fileId = importJson != null && importJson['id_excel'] != null ? importJson['id_excel'].toString() : null;
      if (fileId == null || fileId.isEmpty) {
        scaffold.showSnackBar(const SnackBar(content: Text('Respuesta no contiene id_excel')));
        debugPrint('import response: ${importResp.body}');
        return;
      }

      scaffold.showSnackBar(const SnackBar(content: Text('Descargando archivo desde servidor...')));

      final fileUri = Uri.parse('$apiBase/historial-asistencia/file/$fileId');
      final fileResp = await http.get(fileUri);

      if (fileResp.statusCode != 200) {
        scaffold.showSnackBar(SnackBar(content: Text('Error al descargar archivo (status ${fileResp.statusCode})')));
        debugPrint('file download response: ${fileResp.statusCode} ${fileResp.body}');
        return;
      }

      final bytes = fileResp.bodyBytes;
      if (bytes == null || bytes.isEmpty) {
        scaffold.showSnackBar(const SnackBar(content: Text('Archivo descargado vacío')));
        return;
      }

      // Leer XLSX en memoria usando package:excel
      exl.Excel excel;
      try {
        excel = exl.Excel.decodeBytes(bytes);
      } catch (e) {
        scaffold.showSnackBar(const SnackBar(content: Text('Error al parsear XLSX')));
        debugPrint('Error decodeBytes: $e');
        return;
      }

      // Procesar todas las hojas y eliminar filas completamente nulas
      final Map<String, List<List<String>>> parsed = {};
      for (final sheetName in excel.tables.keys) {
        final sheet = excel.tables[sheetName];
        if (sheet == null) continue;

        // Convertir cada celda a string crudo y eliminar filas vacías
        final cleanedRows = <List<String>>[];
        for (final originalRow in sheet.rows) {
          final converted = List<String>.generate(originalRow.length, (i) {
            final cell = originalRow[i];
            final v = cell?.value;
            return v == null ? '' : v.toString().trim();
          });
          if (converted.any((c) => c.trim().isNotEmpty)) cleanedRows.add(converted);
        }

        // 2) detectar columnas completamente vacías y eliminar columnas con 3 o menos datos (<=3)
        if (cleanedRows.isEmpty) {
          parsed[sheetName] = cleanedRows;
          continue;
        }

        final int maxCols = cleanedRows.map((r) => r.length).fold(0, (a, b) => max(a as int, b));
        final List<int> colCounts = List<int>.filled(maxCols, 0);

        for (final row in cleanedRows) {
          for (int c = 0; c < row.length; c++) {
            if (row[c].trim().isNotEmpty) colCounts[c] += 1;
          }
        }

        // Mantener solo columnas con más de 3 celdas no vacías (eliminar si todos nulos o <=3)
        final List<int> keepIdx = [];
        for (int i = 0; i < colCounts.length; i++) {
          if (colCounts[i] > 3) keepIdx.add(i);
        }

        if (keepIdx.isEmpty) {
          parsed[sheetName] = [];
        } else if (keepIdx.length == maxCols) {
          parsed[sheetName] = cleanedRows;
        } else {
          final filtered = cleanedRows.map((row) {
            return keepIdx.map((i) => i < row.length ? row[i] : '').toList();
          }).toList();
          parsed[sheetName] = filtered;
        }
      }

      setState(() {
        _sheets = parsed;
        _selectedSheet = _sheets.isNotEmpty ? _sheets.keys.first : null;
      });

      scaffold.showSnackBar(const SnackBar(content: Text('Lectura completada. Revisa la vista para ver las filas.')));
    } catch (e, st) {
      debugPrint('Error en _fetchAndReadExcel: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildSheetSelector() {
    if (_sheets.isEmpty) return const SizedBox.shrink();

    final names = _sheets.keys.toList();
    return Row(
      children: [
        const Text('Hojas: ', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: names.map((name) {
                final selected = name == _selectedSheet;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(name),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedSheet = name),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetTable(String sheetName) {
    final rows = _sheets[sheetName] ?? [];
    if (rows.isEmpty) return const Text('Hoja vacía.');

    // calcular cantidad máxima de columnas
    final int maxCols = rows.map((r) => r.length).fold(0, (a, b) => max(a as int, b));

    // ancho por columna (ajusta si quieres columnas más estrechas/anchas)
    const double colWidth = 140.0;
    final double tableWidth = maxCols * colWidth;
    final screenWidth = MediaQuery.of(context).size.width;
    final double minTableWidth = max(tableWidth, screenWidth);

    // Header (fila de títulos C1, C2, ...)
    final header = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _horizontalHeaderController, // usa controller del header
      physics: const ClampingScrollPhysics(),
      child: Container(
        width: minTableWidth,
        color: Colors.grey.shade100,
        child: Row(
          children: List.generate(maxCols, (i) {
            return Container(
              width: colWidth,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Text('C${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          }),
        ),
      ),
    );

    // Body: ListView.builder para scroll vertical perezoso, envuelto en SingleChildScrollView horizontal
    final bodyInner = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minTableWidth),
      child: SizedBox(
        width: minTableWidth,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(), // permite scroll vertical normalmente
          itemCount: rows.length,
          itemBuilder: (context, rowIndex) {
            final row = rows[rowIndex];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: List.generate(maxCols, (colIndex) {
                  final v = colIndex < row.length ? row[colIndex] : '';
                  return Container(
                    width: colWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Builder(builder: (context) {
                      // Mostrar el valor crudo de la celda (sin procesamiento de fechas/weekday)
                      return Text(v ?? '', style: const TextStyle(fontSize: 13));
                    }),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );

    // Envolver el area horizontal con GestureDetector para permitir arrastrar en touch
    final horizontalScrollable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        if (!_horizontalBodyController.hasClients) return;
        final max = _horizontalBodyController.position.maxScrollExtent;
        final newOffset = (_horizontalBodyController.offset - details.delta.dx).clamp(0.0, max);
        _horizontalBodyController.jumpTo(newOffset);
      },
      child: Scrollbar(
        controller: _horizontalBodyController, // usa controller del body (la barra controla el body)
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 10,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalBodyController, // usa controller del body
          physics: const ClampingScrollPhysics(),
          child: bodyInner,
        ),
      ),
    );

    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header fijo arriba (se moverá horizontalmente con el cuerpo)
          header,
          const Divider(height: 1),
          // body con scroll vertical y horizontal (Scrollbar + GestureDetector para pan)
          Expanded(child: horizontalScrollable),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments as Map<String, dynamic>?;

    final obraId = args?['obraId']?.toString();
    final obraNombre = args?['obraNombre']?.toString();
    final fileId = args?['fileId']?.toString();

    return PrimaryScaffold(
      title: 'Obra${obraNombre != null ? " - $obraNombre" : ""}',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Subir archivo XLSX'),
                    onPressed: () => _pickAndUpload(context, obraId),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar y leer XLSX (debug)'),
                    onPressed: () => _fetchAndReadExcel(context, obraId),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Selector de hojas (itembox)
            _buildSheetSelector(),
            const SizedBox(height: 12),
            // Mostrar tabla con todas las filas y columnas de la hoja seleccionada
            Expanded(
              child: _selectedSheet == null
                  ? const Center(child: Text('No hay hojas cargadas.'))
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: _buildSheetTable(_selectedSheet!),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}