import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:sistema_acviis/models/trabajador_asistencia.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:excel/excel.dart' as excel_lib; // <-- agregado para leer xlsx

class HistorialAsistenciaView extends StatefulWidget {
  const HistorialAsistenciaView({super.key});

  @override
  State<HistorialAsistenciaView> createState() => _HistorialAsistenciaViewState();
}

class _HistorialAsistenciaViewState extends State<HistorialAsistenciaView> {
  String? obraId;
  String? obraNombre;
  String? fileId; // ID del excel (se muestra al abrir la vista y se actualiza al subir)
  bool isLoadingFileId = false; // <-- agregado
  bool isParsing = false; // estado mientras parsea excel
  List<List<String?>> trabajadores = []; // filas leídas (cada fila: 4 columnas B..E)

  // Navegación entre hojas
  List<String> sheetNames = [];
  int currentSheetIndex = 0;
  Uint8List? lastExcelBytes; // para reusar al cambiar de hoja cuando el archivo vino como base64
  List<List<dynamic>> remoteSheetsRows = []; // filas por hoja si backend devuelve sheets ya parseadas

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      final args = route?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        obraId = args?['obraId']?.toString();
        obraNombre = args?['obraNombre']?.toString();
        fileId = args?['fileId']?.toString(); // si la navegación pasó el id, mostrarlo
      });

      // si no vino fileId y sí hay obraId, pedir al backend el último fileId
      if (obraId != null && (fileId == null || fileId!.isEmpty)) {
        loadLatestFileId();
      }
    });
  }

  // Nuevo: consulta al backend el último fileId para la obra
  Future<void> loadLatestFileId() async {
    if (obraId == null) return;
    setState(() => isLoadingFileId = true);
    try {
      final uri = Uri.parse('http://localhost:3000/historial-asistencia/import/${Uri.encodeComponent(obraId!)}');
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final map = json.decode(resp.body) as Map<String, dynamic>;
        final fid = map['fileId']?.toString();
        setState(() {
          fileId = fid;
        });

        // Si encontramos fileId, cargar y parsear el excel registrado automáticamente
        if (fid != null && fid.isNotEmpty) {
          await fetchAndParseRegisteredFile(fid);
        }
      } else {
        // no encontrado o error; mantener fileId como estaba
        debugPrint('loadLatestFileId: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      debugPrint('loadLatestFileId error: $e');
    } finally {
      if (mounted) setState(() => isLoadingFileId = false);
    }
  }

  // Selecciona un .xlsx y lo sube al backend, retorna el fileId si tuvo éxito
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
      final fileName = picked.name;

      if (bytes == null && picked.path != null) {
        // Evitar dart:io File en web
        try {
          bytes = await File(picked.path!).readAsBytes();
        } catch (_) {
          // si falla (ej. web), continuar; picked.bytes debería contener los datos si withData:true
        }
      }
      if (bytes == null) return null;

      // Parsear y mostrar trabajadores desde el archivo seleccionado (comienza en B12)
      await parseExcelBytes(bytes);

      final uri = Uri.parse('http://localhost:3000/historial-asistencia/upload');
      final request = http.MultipartRequest('POST', uri);

      if (obraId != null) request.fields['obraId'] = obraId!;

      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // validar que body sea JSON antes de decodificar
        String? fid;
        try {
          final map = json.decode(response.body) as Map<String, dynamic>;
          fid = map['fileId']?.toString();
        } catch (e) {
          debugPrint('Respuesta no es JSON: ${response.body}');
        }
        if (fid != null) {
          setState(() => fileId = fid);
        }
        return fid;
      } else {
        debugPrint('Upload failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('pickAndUploadXlsx error: $e');
      return null;
    }
  }

  // Nuevo: permite seleccionar archivo local y solo parsearlo/mostrar trabajadores (sin subir)
  Future<void> pickAndParseLocalXlsx() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.first;
      Uint8List? bytes = picked.bytes;
      if (bytes == null && picked.path != null) {
        try {
          bytes = await File(picked.path!).readAsBytes();
        } catch (_) {}
      }
      if (bytes == null) return;
      await parseExcelBytes(bytes);
    } catch (e) {
      debugPrint('pickAndParseLocalXlsx error: $e');
    }
  }

  // Lee bytes de un xlsx con package:excel y recorre la tabla comenzando en B12.
  // Lee 4 columnas (B, C, D, E) por fila y agrega filas hasta que la primera columna esté vacía.
  Future<void> parseExcelBytes(Uint8List bytes, {int sheetIndex = 0}) async {
    setState(() {
      isParsing = true;
      trabajadores = [];
    });
    try {
      lastExcelBytes = bytes;
       final excel = excel_lib.Excel.decodeBytes(bytes);
       if (excel.tables.isEmpty) {
         debugPrint('parseExcelBytes: no hay hojas en el archivo');
         return;
       }

      // Registrar nombres de hojas
      sheetNames = excel.tables.keys.toList();
      if (sheetNames.isEmpty) return;
      currentSheetIndex = sheetIndex.clamp(0, sheetNames.length - 1);

      // usar la hoja seleccionada
      final sheetName = sheetNames[currentSheetIndex];
      final sheet = excel.tables[sheetName]!;

      // filas en package:sheet.rows (cada celda es Data? con .value)
      final startRowIndex = 12; // 0-based -> fila 13 en Excel (una fila más abajo)
      final startColIndex = 1; // columna B => índice 1
      final colsToRead = 4; // B, C, D, E

      for (int r = startRowIndex; r < sheet.maxRows; r++) {
        final row = (r < sheet.rows.length) ? sheet.rows[r] : <dynamic>[];
        final firstCell = (row.length > startColIndex) ? row[startColIndex]?.value : null;
        final firstText = firstCell?.toString().trim();
        if (firstText == null || firstText.isEmpty) {
          // terminar si la primera columna de la fila está vacía
          break;
        }
        // leer las 4 columnas (si faltan celdas, quedan como null)
        final List<String?> cols = List.generate(colsToRead, (i) {
          final idx = startColIndex + i;
          final val = (row.length > idx) ? row[idx]?.value : null;
          return val?.toString();
        });

        // Si la primera columna es un índice numérico (1,2,3...), desplazar las columnas
        final indexRegex = RegExp(r'^\d+$');
        if (cols.isNotEmpty && cols[0] != null && indexRegex.hasMatch(cols[0]!.trim())) {
          final shifted = List<String?>.filled(colsToRead, null);
          for (int i = 0; i < colsToRead - 1; i++) {
            shifted[i] = (i + 1 < cols.length) ? cols[i + 1] : null;
          }
          // dejamos la última columna como null (o la que corresponda)
          cols.setAll(0, shifted);
        }

        trabajadores.add(cols);
      }
    } catch (e) {
      debugPrint('parseExcelBytes error: $e');
    } finally {
      if (mounted) setState(() => isParsing = false);
    }
  }

  // Mostrar hoja remota ya parseada (cuando backend devuelve 'sheets')
  Future<void> showSheetAt(int idx) async {
    if (idx < 0 || idx >= sheetNames.length) return;
    setState(() {
      isParsing = true;
      trabajadores = [];
      currentSheetIndex = idx;
    });
    try {
      const startRowIndex = 12;
      const startColIndex = 1;
      const colsToRead = 4;

      if (remoteSheetsRows.isNotEmpty) {
        final rows = remoteSheetsRows[idx];
        final List<List<String?>> parsed = [];
        for (int r = startRowIndex; r < rows.length; r++) {
          final row = rows[r] as List<dynamic>;
          final firstCell = (row.length > startColIndex) ? row[startColIndex] : null;
          final firstText = firstCell != null ? (firstCell['value']?.toString() ?? '').trim() : '';
          if (firstText.isEmpty) break;
          final List<String?> cols = List.generate(colsToRead, (i) {
            final colIdx = startColIndex + i;
            if (row.length <= colIdx) return null;
            final cell = row[colIdx];
            if (cell == null) return null;
            return cell['value']?.toString();
          });

          // Si la primera columna es un índice numérico (1,2,3...), desplazar las columnas
          final indexRegex = RegExp(r'^\d+$');
          if (cols.isNotEmpty && cols[0] != null && indexRegex.hasMatch(cols[0]!.trim())) {
            final shifted = List<String?>.filled(colsToRead, null);
            for (int i = 0; i < colsToRead - 1; i++) {
              shifted[i] = (i + 1 < cols.length) ? cols[i + 1] : null;
            }
            cols.setAll(0, shifted);
          }

          parsed.add(cols);
        }
        if (mounted) setState(() => trabajadores = parsed);
        return;
      }

      // si no hay filas remotas, intentar reusar los bytes locales
      if (lastExcelBytes != null) {
        await parseExcelBytes(lastExcelBytes!, sheetIndex: idx);
      }
    } catch (e) {
      debugPrint('showSheetAt error: $e');
    } finally {
      if (mounted) setState(() => isParsing = false);
    }
  }

   // Nuevo: obtiene el Excel registrado (endpoint /file/:fileId) y parsea las filas
   Future<void> fetchAndParseRegisteredFile(String fid) async {
     if (fid.isEmpty) return;
     setState(() {
       isParsing = true;
       trabajadores = [];
     });
     try {
       final uri = Uri.parse('http://localhost:3000/historial-asistencia/file/${Uri.encodeComponent(fid)}');
       final resp = await http.get(uri).timeout(const Duration(seconds: 15));
       if (!mounted) return;
       if (resp.statusCode != 200) {
         debugPrint('fetchAndParseRegisteredFile: status ${resp.statusCode}');
         return;
       }
       final Map<String, dynamic> body = json.decode(resp.body);

       // Si el backend devolvió 'sheets' ya parseadas (objetos { value, color })
       if (body.containsKey('sheets') && body['sheets'] is List) {
        final sheets = body['sheets'] as List<dynamic>;
        sheetNames = [];
        remoteSheetsRows = [];
        for (int i = 0; i < sheets.length; i++) {
          final s = sheets[i] as Map<String, dynamic>;
          final name = s['name']?.toString() ?? 'Hoja ${i + 1}';
          final rows = (s['rows'] as List<dynamic>?) ?? <dynamic>[];
          sheetNames.add(name);
          remoteSheetsRows.add(rows);
        }
        if (sheetNames.isNotEmpty) {
          await showSheetAt(0);
        }
        return;
       }

       // Si backend devolvió base64 del archivo, decodificar y usar el parser local
       if (body.containsKey('base64') && body['base64'] is String) {
         final b = base64.decode(body['base64'] as String);
        await parseExcelBytes(Uint8List.fromList(b), sheetIndex: 0);
         return;
       }
       debugPrint('fetchAndParseRegisteredFile: formato de respuesta inesperado');
     } catch (e) {
       debugPrint('fetchAndParseRegisteredFile error: $e');
     } finally {
       if (mounted) setState(() => isParsing = false);
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
            // Navegador de hojas
            if (sheetNames.isNotEmpty) ...[
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: (currentSheetIndex > 0 && !isParsing)
                        ? () => showSheetAt(currentSheetIndex - 1)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      '${sheetNames[currentSheetIndex]}  (${currentSheetIndex + 1}/${sheetNames.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (currentSheetIndex < sheetNames.length - 1 && !isParsing)
                        ? () => showSheetAt(currentSheetIndex + 1)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),

            // Solo botón de subir excel
            ElevatedButton.icon(
              onPressed: () async {
                final fid = await pickAndUploadXlsx();
                if (!mounted) return;
                if (fid != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archivo subido. ID: $fid')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se subió el archivo')));
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Subir archivo de asistencia'),
            ),

            const SizedBox(height: 20),

            // Mostrar lista de trabajadores leídos
            if (trabajadores.isNotEmpty) ...[
              const Text('Trabajadores detectados:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: trabajadores.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final row = trabajadores[index];

                    // Normalizar columnas: B..E -> row[0]..row[3]
                    String? col0 = row.length > 0 ? row[0]?.trim() : null;
                    String? col1 = row.length > 1 ? row[1]?.trim() : null;
                    String? col2 = row.length > 2 ? row[2]?.trim() : null;
                    String? col3 = row.length > 3 ? row[3]?.trim() : null;

                    // Si la primera columna es un índice numérico (1,2,3...), desplazar columnas a la izquierda
                    if (col0 != null && RegExp(r'^\d+$').hasMatch(col0)) {
                      col0 = col1;
                      col1 = col2;
                      col2 = col3;
                      col3 = null;
                    }

                    bool isRut(String? s) {
                      if (s == null) return false;
                      final t = s.replaceAll('.', '').replaceAll(' ', '');
                      return RegExp(r'^\d+[-–—]?[0-9kK]$').hasMatch(t);
                    }

                    bool hasLetters(String? s) =>
                        s != null && RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(s);

                    final cols = [col0, col1, col2, col3];

                    // Detectar rut primero
                    String? rut;
                    for (final c in cols) {
                      if (isRut(c)) {
                        rut = c;
                        break;
                      }
                    }

                    // Detectar nombre (primera columna con letras que no sea el rut)
                    String? nombre;
                    for (final c in cols) {
                      if (c != null && c.isNotEmpty && c != rut && hasLetters(c)) {
                        nombre = c;
                        break;
                      }
                    }

                    // Detectar cargo: primer valor no vacío que no sea nombre ni rut
                    String? cargo;
                    for (final c in cols) {
                      if (c != null && c.isNotEmpty && c != nombre && c != rut) {
                        cargo = c;
                        break;
                      }
                    }

                    // Caso común: la primera columna es índice numérico -> desplazar
                    if ((nombre == null || nombre.isEmpty) && col0 != null && RegExp(r'^\d+$').hasMatch(col0)) {
                      if (hasLetters(col1)) {
                        nombre = col1;
                        if (rut == null && isRut(col2)) rut = col2;
                        cargo = cargo ?? col3;
                      } else if (hasLetters(col2)) {
                        nombre = col2;
                        if (rut == null && isRut(col3)) rut = col3;
                        cargo = cargo ?? col1;
                      }
                    }

                    // Fallbacks finales
                    nombre = (nombre != null && nombre.isNotEmpty) ? nombre : (col0 ?? col1 ?? col2 ?? '-');
                    rut = (rut != null && rut.isNotEmpty) ? rut : (col1 ?? col2 ?? col3 ?? '-');
                    cargo = (cargo != null && cargo.isNotEmpty) ? cargo : (col2 ?? col3 ?? col1 ?? '-');

                    return ListTile(
                      leading: Text('${index + 1}.'),
                      title: Text(nombre),
                      subtitle: Text('RUT: $rut  •  CARGO: $cargo'),
                    );
                  },
                ),
              ),
            ] else if (isParsing) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              const SizedBox(height: 12),
              const Text('No hay trabajadores cargados (usar el botón para seleccionar un archivo).'),
            ],
          ],
        ),
      ),
    );
  }
}