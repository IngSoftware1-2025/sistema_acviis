import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as exl;
import 'package:sistema_acviis/backend/controllers/obras/historial_asistencia_api.dart';
import 'package:sistema_acviis/models/persona_asistencia.dart';

class HistorialAsistenciaProvider extends ChangeNotifier {

  Map<String, List<List<String>>> _sheets = {};
  Map<String, List<List<Color?>>> _sheetsColors = {};

  Map<String, List<List<String>>> _asistenciasHorasExtra = {};
  Map<String, List<List<Color?>>> _asistenciasHorasExtraColors = {};

  Map<String, List<List<String>>> _finesDeSemana = {};
  Map<String, List<List<Color?>>> _finesDeSemanaColors = {};

  Map<String, List<List<String>>> _asistenciaDiaria = {};
  Map<String, List<List<Color?>>> _asistenciaDiariaColors = {};

  Map<String, List<List<String>>> _personas = {};
  Map<String, List<List<Color?>>> _personasColors = {};

  // Getters usados por la vista
  Map<String, List<List<String>>> get sheets => _sheets;
  Map<String, List<List<Color?>>> get sheetsColors => _sheetsColors;

  Map<String, List<List<String>>> get asistenciasHorasExtra => _asistenciasHorasExtra;
  Map<String, List<List<Color?>>> get asistenciasHorasExtraColors => _asistenciasHorasExtraColors;

  Map<String, List<List<String>>> get finesDeSemana => _finesDeSemana;
  Map<String, List<List<Color?>>> get finesDeSemanaColors => _finesDeSemanaColors;

  Map<String, List<List<String>>> get asistenciaDiaria => _asistenciaDiaria;
  Map<String, List<List<Color?>>> get asistenciaDiariaColors => _asistenciaDiariaColors;

  Map<String, List<List<String>>> get personas => _personas;
  Map<String, List<List<Color?>>> get personasColors => _personasColors;

  final Map<String, List<PersonaAsistencia>> _personasAsistencia = {};
  Map<String, List<PersonaAsistencia>> get personasAsistencia => _personasAsistencia;

  // Últimos archivos descargados
  final Map<String, Uint8List> _downloadedFiles = {};
  Map<String, Uint8List> get downloadedFiles => _downloadedFiles;

  String? lastError;
  String? statusMessage;

  /// Limpia todo el estado relacionado con el Excel
  void clearAll() {
    _sheets.clear();
    _sheetsColors.clear();

    _asistenciasHorasExtra.clear();
    _asistenciasHorasExtraColors.clear();

    _finesDeSemana.clear();
    _finesDeSemanaColors.clear();

    _asistenciaDiaria.clear();
    _asistenciaDiariaColors.clear();

    _personas.clear();
    _personasColors.clear();

    _personasAsistencia.clear();

    _downloadedFiles.clear();

    lastError = null;
    statusMessage = null;
    notifyListeners();
  }

  String _formatDateToWeekday(String s) {
    final t = s.trim();
    if (t.isEmpty) return '';
    DateTime? dt;
    try {
      dt = DateTime.parse(t);
    } catch (_) {
      dt = null;
    }
    if (dt == null) {
      final re = RegExp(r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})$');
      final m = re.firstMatch(t);
      if (m != null) {
        try {
          final d = int.parse(m.group(1)!);
          final mo = int.parse(m.group(2)!);
          var y = int.parse(m.group(3)!);
          if (y < 100) y += 2000;
          dt = DateTime(y, mo, d);
        } catch (_) {
          dt = null;
        }
      }
    }
    if (dt == null) {
      final reDay = RegExp(r'^(\d{1,2})');
      final m2 = reDay.firstMatch(t);
      if (m2 != null) return m2.group(1)!;
      return t;
    }
    const nombres = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
      6: 'Sábado',
      7: 'Domingo',
    };
    final nombre = nombres[dt.weekday] ?? '';
    final dd = dt.day.toString().padLeft(2, '0');
    return '$dd\n$nombre';
  }

  void _setStatus(String s) {
    statusMessage = s;
    notifyListeners();
  }

  void _setError(String e) {
    lastError = e;
    statusMessage = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> uploadFileFromBytes(Uint8List bytes, String filename, {String? obraId}) async {
    return await uploadFileFromBytesApi(bytes, filename, obraId: obraId);
  }

  Future<void> fetchAndProcessExcel(String obraId) async {
    if (obraId.isEmpty) {
      _setError('obraId vacío');
      return;
    }
    try {
      _setStatus('Descargando archivo desde servidor...');
      Uint8List bytes;
      try {
        bytes = await downloadLatestExcelBytesApi(obraId);
      } catch (e) {
        _setError(e.toString());
        return;
      }

      exl.Excel excel;
      try {
        excel = exl.Excel.decodeBytes(bytes);
      } catch (e) {
        _setError('Error al parsear XLSX');
        return;
      }

      if (excel.tables.isEmpty) {
        _setError('No se encontraron hojas en el XLSX');
        return;
      }

      final Map<String, List<List<String>>> parsed = {};
      final Map<String, List<List<Color?>>> parsedColors = {};
      for (final sheetName in excel.tables.keys) {
        final sheet = excel.tables[sheetName];
        if (sheet == null) continue;
        final cleanedRows = <List<String>>[];
        final cleanedColors = <List<Color?>>[];
        for (final originalRow in sheet.rows) {
          final converted = List<String>.generate(originalRow.length, (i) {
            final cell = originalRow[i];
            final v = (cell == null) ? null : (cell.value ?? null);
            return v == null ? '' : v.toString().trim();
          });
          final colorRow = List<Color?>.filled(converted.length, null);
          if (converted.any((c) => c.trim().isNotEmpty)) {
            cleanedRows.add(converted);
            cleanedColors.add(colorRow);
          }
        }
        parsed[sheetName] = cleanedRows;
        parsedColors[sheetName] = cleanedColors;
      }

      _asistenciasHorasExtra.clear();
      _finesDeSemana.clear();
      _asistenciaDiaria.clear();
      _personas.clear();
      _asistenciasHorasExtraColors.clear();
      _finesDeSemanaColors.clear();
      _asistenciaDiariaColors.clear();
      _personasColors.clear();

      String _lower(String s) => s.toLowerCase();

      for (final sheetName in parsed.keys.toList()) {
        final rowsOrig = parsed[sheetName] ?? [];
        final colorsOrig = parsedColors[sheetName] ?? [];
        final rows = rowsOrig.map((r) => List<String>.from(r)).toList();
        final colors = colorsOrig.map((r) => List<Color?>.from(r)).toList();

        Map<String, dynamic> _extractLastBlock(List<List<String>> lst, List<List<Color?>> colst) {
          int found = -1;
          for (int i = lst.length - 1; i >= 0; i--) {
            final row = lst[i];
            if (row.any((cell) => cell != null && _lower(cell).contains('n°'))) {
              found = i;
              break;
            }
          }
          if (found == -1) return {'rows': <List<String>>[], 'colors': <List<Color?>>[]};
          final start = max(0, found - 2);
          final blockRows = lst.sublist(start);
          final blockColors = colst.sublist(start);
          lst.removeRange(start, lst.length);
          colst.removeRange(start, colst.length);
          return {'rows': blockRows, 'colors': blockColors};
        }

        final b1 = _extractLastBlock(rows, colors);
        _asistenciasHorasExtra[sheetName] = List<List<String>>.from(b1['rows']);
        _asistenciasHorasExtraColors[sheetName] = List<List<Color?>>.from(b1['colors']);

        final b2 = _extractLastBlock(rows, colors);
        _finesDeSemana[sheetName] = List<List<String>>.from(b2['rows']);
        _finesDeSemanaColors[sheetName] = List<List<Color?>>.from(b2['colors']);

        final b3 = _extractLastBlock(rows, colors);
        _asistenciaDiaria[sheetName] = List<List<String>>.from(b3['rows']);
        _asistenciaDiariaColors[sheetName] = List<List<Color?>>.from(b3['colors']);

        parsed[sheetName] = rows;
        parsedColors[sheetName] = colors;
      }

      List<List<T>> _dropFirstNColumns<T>(List<List<T>> rows, int n) {
        return rows.map((r) {
          if (r.isEmpty) return <T>[];
          return r.length > n ? r.sublist(n) : <T>[];
        }).toList();
      }

      Map<String, dynamic> _removeEmptyColumnsPair(List<List<String>> rows, List<List<Color?>> colors) {
        if (rows.isEmpty && colors.isEmpty) return {'rows': <List<String>>[], 'colors': <List<Color?>>[]};
        final int maxCols = max(
            rows.map((r) => r.length).fold(0, (a, b) => max(a as int, b)),
            colors.map((r) => r.length).fold(0, (a, b) => max(a as int, b)));
        final List<int> keep = [];
        for (int c = 0; c < maxCols; c++) {
          bool anyNonEmpty = false;
          for (int r = 0; r < max(rows.length, colors.length); r++) {
            final String? cell = (r < rows.length && c < rows[r].length) ? rows[r][c] : null;
            final Color? col = (r < colors.length && c < colors[r].length) ? colors[r][c] : null;
            final bool cellHas = cell != null && cell.trim().isNotEmpty;
            final bool colorHas = col != null;
            if (cellHas || colorHas) {
              anyNonEmpty = true;
              break;
            }
          }
          if (anyNonEmpty) keep.add(c);
        }
        if (keep.isEmpty) {
          return {
            'rows': rows.map((r) => <String>[]).toList(),
            'colors': colors.map((r) => <Color?>[]).toList()
          };
        }
        List<List<String>> newRows = rows.map((r) => keep.map((c) => c < r.length ? r[c] : '').toList()).toList();
        List<List<Color?>> newColors = colors.map((r) => keep.map((c) => c < r.length ? r[c] : null).toList()).toList();
        return {'rows': newRows, 'colors': newColors};
      }

      Map<String, dynamic> _filterDateColumns(List<List<String>> rows, List<List<Color?>> colors) {
        final int maxCols = max(
            rows.map((r) => r.length).fold(0, (a, b) => max(a as int, b)),
            colors.map((r) => r.length).fold(0, (a, b) => max(a as int, b)));
        final List<int> keep = [];
        for (int c = 0; c < maxCols; c++) {
          bool keepCol = false;
          for (int r = 0; r < rows.length; r++) {
            final cell = c < rows[r].length ? (rows[r][c] ?? '') : '';
            if (cell.isNotEmpty && _isDateString(cell)) {
              keepCol = true;
              break;
            }
          }
          if (!keepCol && rows.isNotEmpty) {
            final header = rows[0];
            if (c < header.length && header[c].isNotEmpty && _isDateString(header[c])) keepCol = true;
          }
          if (keepCol) keep.add(c);
        }
        if (keep.isEmpty) {
          return {'rows': rows.map((r) => <String>[]).toList(), 'colors': colors.map((r) => <Color?>[]).toList()};
        }
        final newRows = rows.map((r) => keep.map((c) => c < r.length ? r[c] : '').toList()).toList();
        final newColors = colors.map((r) => keep.map((c) => c < r.length ? r[c] : null).toList()).toList();
        return {'rows': newRows, 'colors': newColors};
      }

      Map<String, dynamic> _removeColumnsWhereFirstEmpty(List<List<String>> rows, List<List<Color?>> colors) {
        if (rows.isEmpty) return {'rows': rows, 'colors': colors};
        final int maxCols = max(
          rows.map((r) => r.length).fold(0, (a, b) => max(a as int, b)),
          colors.map((r) => r.length).fold(0, (a, b) => max(a as int, b)),
        );
        final List<int> keep = [];
        for (int c = 0; c < maxCols; c++) {
          final firstVal = (rows.isNotEmpty && c < rows[0].length) ? (rows[0][c] ?? '') : '';
          if (firstVal.trim().isNotEmpty) keep.add(c);
        }
        if (keep.isEmpty) {
          return {'rows': rows.map((r) => <String>[]).toList(), 'colors': colors.map((r) => <Color?>[]).toList()};
        }
        final newRows = rows.map((r) => keep.map((c) => c < r.length ? r[c] : '').toList()).toList();
        final newColors = colors.map((r) => keep.map((c) => c < r.length ? r[c] : null).toList()).toList();
        return {'rows': newRows, 'colors': newColors};
      }

      for (final sheetName in _asistenciasHorasExtra.keys.toList()) {
        final rowsRaw = _asistenciasHorasExtra[sheetName] ?? [];
        final colsRaw = _asistenciasHorasExtraColors[sheetName] ?? [];
        final dropped = _dropFirstNColumns<String>(rowsRaw, 1);
        final droppedCols = _dropFirstNColumns<Color?>(colsRaw, 1);
        final pair = _removeEmptyColumnsPair(dropped, droppedCols);
        final filtered = _filterDateColumns(List<List<String>>.from(pair['rows']), List<List<Color?>>.from(pair['colors']));
        final List<List<String>> rowsProcessed = List<List<String>>.from(filtered['rows']);
        final List<List<Color?>> colsProcessed = List<List<Color?>>.from(filtered['colors']);
        if (rowsProcessed.isNotEmpty) {
          rowsProcessed.removeAt(0);
          if (colsProcessed.isNotEmpty) colsProcessed.removeAt(0);
        }
        if (rowsProcessed.length > 1) {
          rowsProcessed.removeAt(1);
          if (colsProcessed.length > 1) colsProcessed.removeAt(1);
        }
        List<List<String>> trimmedRows = rowsProcessed.map((r) {
          if (r.length <= 2) return <String>[];
          return r.sublist(0, r.length - 2);
        }).toList();
        List<List<Color?>> trimmedCols = colsProcessed.map((r) {
          if (r.length <= 2) return <Color?>[];
          return r.sublist(0, r.length - 2);
        }).toList();
        final keptPairHE = _removeColumnsWhereFirstEmpty(trimmedRows, trimmedCols);
        _asistenciasHorasExtra[sheetName] = List<List<String>>.from(keptPairHE['rows']);
        _asistenciasHorasExtraColors[sheetName] = List<List<Color?>>.from(keptPairHE['colors']);
      }

      for (final sheetName in _finesDeSemana.keys.toList()) {
        final rowsRaw = _finesDeSemana[sheetName] ?? [];
        final colsRaw = _finesDeSemanaColors[sheetName] ?? [];
        final dropped = _dropFirstNColumns<String>(rowsRaw, 1);
        final droppedCols = _dropFirstNColumns<Color?>(colsRaw, 1);
        final pair = _removeEmptyColumnsPair(dropped, droppedCols);
        final filtered = _filterDateColumns(List<List<String>>.from(pair['rows']), List<List<Color?>>.from(pair['colors']));
        final List<List<String>> rowsProcessed = List<List<String>>.from(filtered['rows']);
        final List<List<Color?>> colsProcessed = List<List<Color?>>.from(filtered['colors']);
        if (rowsProcessed.isNotEmpty) {
          rowsProcessed.removeAt(0);
          if (colsProcessed.isNotEmpty) colsProcessed.removeAt(0);
        }
        if (rowsProcessed.length > 1) {
          rowsProcessed.removeAt(1);
          if (colsProcessed.length > 1) colsProcessed.removeAt(1);
        }
        List<List<String>> trimmedRows = rowsProcessed.map((r) {
          if (r.length <= 3) return <String>[];
          return r.sublist(0, r.length - 3);
        }).toList();
        List<List<Color?>> trimmedCols = colsProcessed.map((r) {
          if (r.length <= 3) return <Color?>[];
          return r.sublist(0, r.length - 3);
        }).toList();
        final keptPairFS = _removeColumnsWhereFirstEmpty(trimmedRows, trimmedCols);
        _finesDeSemana[sheetName] = List<List<String>>.from(keptPairFS['rows']);
        _finesDeSemanaColors[sheetName] = List<List<Color?>>.from(keptPairFS['colors']);
      }

      for (final sheetName in _asistenciaDiaria.keys.toList()) {
        final rowsRaw = _asistenciaDiaria[sheetName] ?? [];
        final colsRaw = _asistenciaDiariaColors[sheetName] ?? [];
        final dropped = _dropFirstNColumns<String>(rowsRaw, 1);
        final droppedCols = _dropFirstNColumns<Color?>(colsRaw, 1);
        final pair = _removeEmptyColumnsPair(dropped, droppedCols);
        final List<List<String>> rowsProcessed = List<List<String>>.from(pair['rows']);
        final List<List<Color?>> colsProcessed = List<List<Color?>>.from(pair['colors']);
        if (rowsProcessed.isNotEmpty) {
          rowsProcessed.removeAt(0);
          if (colsProcessed.isNotEmpty) colsProcessed.removeAt(0);
        }
        if (rowsProcessed.length > 1) {
          rowsProcessed.removeAt(1);
          if (colsProcessed.length > 1) colsProcessed.removeAt(1);
        }
        final List<List<String>> personasRows = (() {
          if (rowsProcessed.length <= 1) return <List<String>>[];
          final remainingRows = rowsProcessed.sublist(1);
          return remainingRows.map((r) {
            final withoutFirstCol = r.length > 1 ? r.sublist(1) : <String>[];
            return withoutFirstCol.length >= 3 ? withoutFirstCol.sublist(0, 3) : List<String>.from(withoutFirstCol);
          }).toList();
        })();
        final List<List<Color?>> personasCols = (() {
          if (colsProcessed.length <= 1) return <List<Color?>>[];
          final remainingCols = colsProcessed.sublist(1);
          return remainingCols.map((r) {
            final withoutFirstCol = r.length > 1 ? r.sublist(1) : <Color?>[];
            return withoutFirstCol.length >= 3 ? withoutFirstCol.sublist(0, 3) : List<Color?>.from(withoutFirstCol);
          }).toList();
        })();
        _personas[sheetName] = personasRows;
        _personasColors[sheetName] = personasCols;

        List<List<String>> trimmedRows = rowsProcessed.map((r) {
          if (r.length <= 2) return <String>[];
          return r.sublist(0, r.length - 2);
        }).toList();
        List<List<Color?>> trimmedCols = colsProcessed.map((r) {
          if (r.length <= 2) return <Color?>[];
          return r.sublist(0, r.length - 2);
        }).toList();
        final keptPairAD = _removeColumnsWhereFirstEmpty(trimmedRows, trimmedCols);
        _asistenciaDiaria[sheetName] = List<List<String>>.from(keptPairAD['rows']);
        _asistenciaDiariaColors[sheetName] = List<List<Color?>>.from(keptPairAD['colors']);
      }

      _sheets = parsed;
      _sheetsColors = parsedColors;

      _setStatus('Lectura completada');
    } catch (e, st) {
      _setError('Error: $e');
      if (kDebugMode) {
        debugPrint('Error en fetchAndProcessExcel: $e\n$st');
      }
    }
  }

  List<PersonaAsistencia> extractPersonasAsistencias({String? sheetName}) {
    final List<String> sheetsToProcess = sheetName != null ? [sheetName] : _personas.keys.toList();
    final List<PersonaAsistencia> allExtracted = [];

    for (final sheet in sheetsToProcess) {
      final extractedForSheet = <PersonaAsistencia>[];
      _personasAsistencia[sheet] = extractedForSheet;

      _personas[sheet] = _personas[sheet] ?? <List<String>>[];
      _asistenciaDiaria[sheet] = _asistenciaDiaria[sheet] ?? <List<String>>[];
      _finesDeSemana[sheet] = _finesDeSemana[sheet] ?? <List<String>>[];
      _asistenciasHorasExtra[sheet] = _asistenciasHorasExtra[sheet] ?? <List<String>>[];

      while ((_personas[sheet]?.isNotEmpty ?? false)) {
        final personRow = _personas[sheet]!.removeLast();

        final nombre = personRow.isNotEmpty ? personRow[0] : '';
        final rut = personRow.length > 1 ? personRow[1] : '';
        final cargo = personRow.length > 2 ? personRow[2] : '';

        List<String> asistenciaDiariaRow = [];
        if ((_asistenciaDiaria[sheet]?.isNotEmpty ?? false)) {
          asistenciaDiariaRow = List<String>.from(_asistenciaDiaria[sheet]!.removeLast());
        }

        List<String> finesRow = [];
        if ((_finesDeSemana[sheet]?.isNotEmpty ?? false)) {
          finesRow = List<String>.from(_finesDeSemana[sheet]!.removeLast());
        }

        List<String> horasRow = [];
        if ((_asistenciasHorasExtra[sheet]?.isNotEmpty ?? false)) {
          horasRow = List<String>.from(_asistenciasHorasExtra[sheet]!.removeLast());
        }

        final rawFechaRow = (_asistenciaDiaria[sheet] != null && _asistenciaDiaria[sheet]!.isNotEmpty)
            ? List<String>.from(_asistenciaDiaria[sheet]!.first)
            : <String>[];
        final fechaRow = rawFechaRow.map((e) => _formatDateToWeekday(e)).toList();

        final persona = PersonaAsistencia(
          nombre: nombre,
          cargo: cargo,
          rut: rut,
          fecha: fechaRow,
          asistenciaDiaria: asistenciaDiariaRow,
          asistenciaFinesSemana: finesRow,
          horasExtra: horasRow,
        );

        extractedForSheet.add(persona);
        allExtracted.add(persona);
      }

      _personasAsistencia[sheet] = extractedForSheet;
    }

    notifyListeners();
    return allExtracted;
  }

  bool _isDateString(String s) {
    final t = s.trim();
    if (t.isEmpty) return false;
    if (DateTime.tryParse(t) != null) return true;
    final re = RegExp(r'^\d{1,2}[\/\-\.\s]\d{1,2}([\/\-\.\s]\d{2,4})?$');
    return re.hasMatch(t);
  }

  /// Descarga sólo el archivo XLSX asociado a la obra (no lo procesa)
  Future<void> fetchOnlyExcel(String obraId) async {
    if (obraId.isEmpty) {
      _setError('obraId vacío');
      return;
    }
    try {
      _setStatus('Descargando archivo desde servidor (solo descarga)...');
      Map<String, dynamic> resp;
      try {
        resp = await downloadLatestExcelFileApi(obraId);
      } catch (e) {
        _setError(e.toString());
        return;
      }
      final fileId = resp['fileId'] as String?;
      final bytes = resp['bytes'] as Uint8List?;
      if (fileId == null || bytes == null) {
        _setError('Respuesta inválida del servidor');
        return;
      }
      _downloadedFiles[fileId] = bytes;
      _setStatus('Archivo descargado: id=$fileId (${bytes.length} bytes)');
    } catch (e, st) {
      _setError('Error descargando archivo: $e');
      if (kDebugMode) debugPrint('Error en fetchOnlyExcel: $e\n$st');
    }
  }
}