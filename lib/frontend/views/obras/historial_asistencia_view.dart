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

  // Estado para almacenar y mostrar el contenido del Excel (ahora metadata de hojas)
  List<dynamic>? sheetsMeta; // [{ sheetName, pairs: [{pairIndex, count}], total }]
  bool loadingExcel = false;
  String? historialId;
  String? fileId; // <-- ID del archivo en GridFS devuelto por backend

  // caches por sheetIndex/pairIndex (se mantienen por si luego agregas navegación más profunda)
  final Map<String, List<dynamic>> _pairCache = {};
  final Map<String, bool> _loadingPair = {};

  final Map<String, int> _pairPage = {}; // key -> current page
  final Map<String, bool> _hasMore = {};  // key -> hasMore flag
  final Map<String, ScrollController> _pairControllers = {};

  // Función: solicita al backend el excel más reciente para la obra y lo guarda en memoria (metadata)
  Future<void> fetchLatestExcel() async {
    if (obraId == null) return;
    setState(() {
      loadingExcel = true;
      sheetsMeta = null;
      historialId = null;
      fileId = null;
    });

    try {
      final uri = Uri.parse('http://localhost:3000/historial-asistencia/import/$obraId');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final map = json.decode(resp.body) as Map<String, dynamic>;
        final sheetsRaw = map['sheets'] as List<dynamic>?;
        final hid = map['historialId']?.toString();
        final fid = map['fileId']?.toString();

        // sheetsRaw: [{ sheetName: 'Sheet1', pairs: [...], total: 0 }, ...]
        setState(() {
          sheetsMeta = sheetsRaw ?? [];
          historialId = hid;
          fileId = fid;
        });
      } else {
        debugPrint('fetchLatestExcel failed: ${resp.statusCode} ${resp.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo obtener el excel: ${resp.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('fetchLatestExcel error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error conectando al servidor')),
        );
      }
    } finally {
      if (mounted) setState(() => loadingExcel = false);
    }
  }

  // Obtener trabajadores para un sheetName y pairIndex (paginado simple)
  Future<void> fetchPairWorkers(String sheetName, int pairIndex, {int page = 1, int limit = 50, String? q}) async {
    if (historialId == null) return;
    final key = '$sheetName|$pairIndex|$page${q==null?'':'|q=$q'}';
    if (_pairCache.containsKey(key)) return;
    _loadingPair[key] = true;
    setState(() {});

    try {
      final uri = Uri.parse('http://localhost:3000/historial-asistencia/$historialId/sheets/${Uri.encodeComponent(sheetName)}/pair/$pairIndex?page=$page&limit=$limit${q!=null? '&q=${Uri.encodeComponent(q)}' : ''}');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final map = json.decode(resp.body) as Map<String, dynamic>;
        final items = map['items'] as List<dynamic>? ?? [];
        final total = map['total'] as int? ?? items.length;
        // cache por página
        final pageKey = '$sheetName|$pairIndex|page_$page';
        _pairCache[pageKey] = items;
        // actualizar meta page/hasMore
        _pairPage['$sheetName|$pairIndex'] = page;
        _hasMore['$sheetName|$pairIndex'] = (page * limit) < total;
        // unir todas las páginas en una sola lista accesible
        final combinedKey = '$sheetName|$pairIndex|combined';
        final existing = _pairCache[combinedKey] ?? [];
        _pairCache[combinedKey] = [...existing, ...items];
      } else {
        debugPrint('fetchPairWorkers failed: ${resp.statusCode} ${resp.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando datos: ${resp.statusCode}')));
        }
      }
    } catch (e) {
      debugPrint('fetchPairWorkers error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error conectando al servidor')));
      }
    } finally {
      _loadingPair[key] = false;
      setState(() {});
    }
  }

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

  // ignore: unused_element
  void _ensureController(String combinedKey, String sheetName, int pairIdx) {
    if (_pairControllers[combinedKey] != null) return;
    final ctrl = ScrollController();
    ctrl.addListener(() {
      if (ctrl.position.pixels > ctrl.position.maxScrollExtent - 200) {
        final curPage = _pairPage['$sheetName|$pairIdx'] ?? 1;
        final hasMore = _hasMore['$sheetName|$pairIdx'] ?? true;
        if (hasMore && _loadingPair['$sheetName|$pairIdx|page_${curPage+1}'] != true) {
          fetchPairWorkers(sheetName, pairIdx, page: curPage + 1);
        }
      }
    });
    _pairControllers[combinedKey] = ctrl;
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
                    final fileIdLocal = await pickAndUploadXlsx();
                    if (!mounted) return;
                    if (fileIdLocal != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Archivo subido correctamente. ID: $fileIdLocal')),
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
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: loadingExcel ? null : fetchLatestExcel,
                  icon: const Icon(Icons.download),
                  label: const Text('Cargar último Excel'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // --- NUEVO: mostrar solo las hojas (navegación entre ellas) ---
            if (loadingExcel) const Center(child: CircularProgressIndicator()),
            if (!loadingExcel && (sheetsMeta == null || sheetsMeta!.isEmpty))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('No se ha cargado ningún Excel o aún se está procesando.'),
              ),

            if (!loadingExcel && sheetsMeta != null && sheetsMeta!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('HistorialId: ${historialId ?? "-"}'),
                  TextButton.icon(
                    onPressed: fileId == null
                        ? null
                        : () {
                            final url = 'http://localhost:3000/historial-asistencia/download/$fileId';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('URL de descarga: $url')),
                            );
                          },
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar archivo'),
                  )
                ],
              ),
              const SizedBox(height: 8),

              // Pestañas por hoja para navegar entre ellas
              DefaultTabController(
                length: sheetsMeta!.length,
                child: Expanded(
                  child: Column(
                    children: [
                      Material(
                        color: Theme.of(context).colorScheme.surface,
                        child: TabBar(
                          isScrollable: true,
                          tabs: sheetsMeta!
                              .map((s) => Tab(child: Text(s['sheetName']?.toString() ?? '-')))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          // Cada pestaña ahora muestra únicamente el navegador de páginas y permite scroll
                          children: sheetsMeta!.map((s) {
                            final sheetName = s['sheetName']?.toString() ?? '-';
                            // Soporta metadata en dos formatos:
                            // 1) s['pages'] = [ { 'label': 'AGOSTO', 'id': ... }, ... ]
                            // Usar el orden tal cual viene desde el backend (que debe respetar el orden del archivo)
                            final sortedPages = (s['pages'] as List<dynamic>?) ?? [];

                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sheetName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),

                                  // Navegador de páginas horizontal y scrollable (solo si hay pages metadata)
                                  if (sortedPages.isNotEmpty)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: sortedPages.map<Widget>((p) {
                                          final label = (p is Map && p['label'] != null) ? p['label'].toString() : p.toString();
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Seleccionada: $sheetName → $label')),
                                                );
                                              },
                                              child: Text(label),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  // Placeholder instructivo y refrescar
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        fetchLatestExcel();
                                      },
                                      child: const Text('Refrescar'),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
