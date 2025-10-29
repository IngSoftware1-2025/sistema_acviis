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

  // URL base para backend: ajusta según plataforma (Android emulator -> 10.0.2.2)
  String get backendBaseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

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
      final uri = Uri.parse('$backendBaseUrl/historial-asistencia/import/${Uri.encodeComponent(obraId!)}');
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final map = json.decode(resp.body) as Map<String, dynamic>;
        // Cambiado: backend devuelve id_excel
        final fid = map['id_excel']?.toString();
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

      final uri = Uri.parse('$backendBaseUrl/historial-asistencia/upload-register');
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
          // Cambiado: backend devuelve id_excel
          fid = map['id_excel']?.toString();
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
       final uri = Uri.parse('$backendBaseUrl/historial-asistencia/file/${Uri.encodeComponent(fid)}');
       final resp = await http.get(uri).timeout(const Duration(seconds: 15));
       if (!mounted) return;
       debugPrint('fetchAndParseRegisteredFile: status=${resp.statusCode} content-type=${resp.headers['content-type']}');
       if (resp.statusCode != 200) {
         debugPrint('fetchAndParseRegisteredFile: status ${resp.statusCode} body=${resp.body}');
         return;
       }

       // Intentar decodificar JSON primero (caso 'sheets' o 'base64')
       Map<String, dynamic>? body;
       try {
         body = json.decode(resp.body) as Map<String, dynamic>?;
         debugPrint('fetchAndParseRegisteredFile: parsed JSON ok');
       } catch (e) {
         debugPrint('fetchAndParseRegisteredFile: respuesta no JSON, intentar parsear como bytes. error: $e');
         body = null;
       }

       if (body != null) {
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
           try {
             final b = base64.decode(body['base64'] as String);
             lastExcelBytes = Uint8List.fromList(b);
             await parseExcelBytes(lastExcelBytes!, sheetIndex: 0);
             return;
           } catch (e) {
             debugPrint('Error decodificando base64: $e');
             // seguir al intento con bodyBytes abajo
           }
         }

         // Si viene otro JSON válido pero sin sheets/base64, intentar buscar un campo 'file' con base64
         if (body.containsKey('file') && body['file'] is String) {
           try {
             final b = base64.decode(body['file'] as String);
             lastExcelBytes = Uint8List.fromList(b);
             await parseExcelBytes(lastExcelBytes!, sheetIndex: 0);
             return;
           } catch (e) {
             debugPrint('Error decodificando body.file base64: $e');
           }
         }
       }

       // Si llegamos aquí, intentar parsear directamente los bytes de la respuesta
       final bytes = resp.bodyBytes;
       if (bytes.isNotEmpty) {
         try {
           // guardar para navegación entre hojas
           lastExcelBytes = Uint8List.fromList(bytes);
           await parseExcelBytes(lastExcelBytes!, sheetIndex: 0);
           return;
         } catch (e) {
           debugPrint('Error parseando bodyBytes como xlsx: $e');
         }
       }

       debugPrint('fetchAndParseRegisteredFile: formato de respuesta inesperado o datos vacíos');
     } catch (e) {
       debugPrint('fetchAndParseRegisteredFile error: $e');
     } finally {
       if (mounted) setState(() => isParsing = false);
     }
   }

  // Reemplazado: descarga el archivo registrado como XLSX, lo guarda en Downloads y lo abre
  Future<void> downloadAndOpenRegisteredXlsx(String fid) async {
    if (fid.isEmpty) return;
    try {
      final uri = Uri.parse('$backendBaseUrl/historial-asistencia/file/${Uri.encodeComponent(fid)}');
      final resp = await http.get(uri).timeout(const Duration(seconds: 30));
      if (!mounted) return;
      debugPrint('downloadAndOpenRegisteredXlsx: status=${resp.statusCode} content-type=${resp.headers['content-type']}');
      if (resp.statusCode != 200) {
        debugPrint('downloadAndOpenRegisteredXlsx: body=${resp.body}');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al descargar: ${resp.statusCode}')));
        return;
      }

      // Obtener bytes (acepta binario o JSON con base64)
      Uint8List bytes;
      String filename = 'historial_$fid.xlsx';
      try {
        final map = json.decode(resp.body) as Map<String, dynamic>?;
        if (map != null && map.containsKey('base64') && map['base64'] is String) {
          bytes = base64.decode(map['base64'] as String);
          if (map.containsKey('filename')) filename = map['filename'].toString();
        } else if (map != null && map.containsKey('file') && map['file'] is String) {
          bytes = base64.decode(map['file'] as String);
          if (map.containsKey('filename')) filename = map['filename'].toString();
        } else {
          // JSON sin base64 -> guardar texto para inspección
          final text = resp.body;
          final up = Platform.isWindows ? (Platform.environment['USERPROFILE'] ?? Directory.current.path) : (Platform.environment['HOME'] ?? Directory.current.path);
          final debugDir = Directory('$up${Platform.pathSeparator}Downloads');
          if (!await debugDir.exists()) await debugDir.create(recursive: true);
          final debugFile = File('${debugDir.path}${Platform.pathSeparator}historial_${fid}_response.txt');
          await debugFile.writeAsString(text);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Respuesta no binaria guardada en: ${debugFile.path}')));
          debugPrint('Respuesta JSON sin base64 guardada en: ${debugFile.path}');
          return;
        }
      } catch (_) {
        // no JSON -> usar bodyBytes
        bytes = resp.bodyBytes;
      }

      if (bytes.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo vacío o no descargable')));
        return;
      }

      // Intentar obtener filename desde headers Content-Disposition
      final cd = resp.headers['content-disposition'];
      if (cd != null) {
        final m = RegExp("filename\\*?=(?:UTF-8'')?\"?([^\";]+)\"?").firstMatch(cd);
        if (m != null && m.groupCount >= 1) {
          filename = Uri.decodeFull(m.group(1)!);
        }
      }

      // Asegurar extensión .xlsx
      if (!filename.toLowerCase().endsWith('.xlsx')) {
        filename = '$filename.xlsx';
      }

      // Guardar en carpeta Downloads
      final up = Platform.isWindows ? (Platform.environment['USERPROFILE'] ?? Directory.current.path) : (Platform.environment['HOME'] ?? Directory.current.path);
      final downloadsPath = '$up${Platform.pathSeparator}Downloads';
      final dir = Directory(downloadsPath);
      if (!await dir.exists()) await dir.create(recursive: true);

      final safeName = filename.replaceAll(RegExp(r'[\\/:]'), '_');
      final outFile = File('${dir.path}${Platform.pathSeparator}$safeName');
      await outFile.writeAsBytes(bytes);

      // Abrir con la aplicación por defecto (Windows)
      try {
        if (Platform.isWindows) {
          await Process.run('cmd', ['/c', 'start', '', outFile.path]);
        } else if (Platform.isLinux) {
          await Process.run('xdg-open', [outFile.path]);
        } else if (Platform.isMacOS) {
          await Process.run('open', [outFile.path]);
        }
      } catch (e) {
        debugPrint('No se pudo abrir automáticamente: $e');
      }

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('XLSX descargado y abierto: ${outFile.path}')));
      debugPrint('Archivo XLSX guardado en: ${outFile.path}');
    } catch (e) {
      debugPrint('downloadAndOpenRegisteredXlsx error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al descargar/abrir: $e')));
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

            // Botones: subir y abrir archivo registrado
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final fid = await pickAndUploadXlsx();
                      if (!mounted) return;
                      if (fid != null) {
                        setState(() => fileId = fid);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archivo subido. ID: $fid')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se subió el archivo')));
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Subir archivo de asistencia'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (fileId != null && fileId!.isNotEmpty && !isParsing)
                        ? () async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Descargando y abriendo XLSX...')));
                            await downloadAndOpenRegisteredXlsx(fileId!);
                          }
                        : null,
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar y abrir XLSX registrado'),
                  ),
                ),
              ],
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
                    final String? col0 = row.isNotEmpty ? row[0]?.trim() : null;
                    final String? col1 = row.length > 1 ? row[1]?.trim() : null;
                    final String? col2 = row.length > 2 ? row[2]?.trim() : null;
                    final String? col3 = row.length > 3 ? row[3]?.trim() : null;

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
                    // 1) Preferir celdas que contengan letras (más probables como cargos)
                    for (final c in cols) {
                      if (c != null && c.isNotEmpty && c != nombre && c != rut && hasLetters(c)) {
                        cargo = c;
                        break;
                      }
                    }
                    // 2) Si no se encontró, tomar la primera que no sea puramente numérica
                    if (cargo == null) {
                      for (final c in cols) {
                        if (c != null && c.isNotEmpty && c != nombre && c != rut && !RegExp(r'^\d+$').hasMatch(c)) {
                          cargo = c;
                          break;
                        }
                      }
                    }
                    // 3) Si aún no se encontró, dejar null y aplicar fallback más abajo

                    // Caso común: la primera columna es índice numérico -> desplazar
                    if ((nombre == null || nombre.isEmpty) && col0 != null && RegExp(r'^\d+$').hasMatch(col0)) {
                      if (hasLetters(col1)) {
                        nombre = col1;
                        if (rut == null && isRut(col2)) rut = col2;
                        cargo = cargo ?? (hasLetters(col3) ? col3 : null);
                      } else if (hasLetters(col2)) {
                        nombre = col2;
                        if (rut == null && isRut(col3)) rut = col3;
                        cargo = cargo ?? (hasLetters(col1) ? col1 : null);
                      }
                    }

                    // Fallbacks finales
                    nombre = (nombre != null && nombre.isNotEmpty) ? nombre : (col0 ?? col1 ?? col2 ?? '-');
                    rut = (rut != null && rut.isNotEmpty) ? rut : (col1 ?? col2 ?? col3 ?? '-');
                    cargo = (cargo != null && cargo.isNotEmpty) ? cargo : '-';

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