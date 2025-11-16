import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/providers/historial_asistencia_provider.dart';

class HistorialAsistenciaView extends StatefulWidget {
  const HistorialAsistenciaView({super.key});

  @override
  State<HistorialAsistenciaView> createState() => _HistorialAsistenciaViewState();
}

class _HistorialAsistenciaViewState extends State<HistorialAsistenciaView> {
  final ScrollController _horizontalBodyController = ScrollController();
  final Map<String, int?> _selectedPersonaIndex = {};
  String? _selectedSheet;
  Timer? _autoLoadTimer;
  bool _autoLoadTriggeredForSheet = false;

  @override
  void dispose() {
    _horizontalBodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Limpiar todos los datos del Excel al entrar en la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = Provider.of<HistorialAsistenciaProvider>(context, listen: false);
        // Limpiar todo el estado del provider y resetar selección local
        provider.clearAll();
        setState(() {
          _selectedSheet = null;
          _selectedPersonaIndex.clear();
        });
      } catch (_) {
        // Si el provider no está disponible en este momento, no bloquear la UI.
      }
    });
  }

  String _formatDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    final dt = DateTime.tryParse(s);
    if (dt != null) {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
    final matchYmd = RegExp(r'^(\d{4})[^\d]?(\d{1,2})[^\d]?(\d{1,2})$').firstMatch(s);
    if (matchYmd != null) {
      final y = int.parse(matchYmd[1]!);
      final m = int.parse(matchYmd[2]!);
      final d = int.parse(matchYmd[3]!);
      return '${d.toString().padLeft(2, '0')}/${m.toString().padLeft(2, '0')}/${y}';
    }
    final matchDmy = RegExp(r'^(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})$').firstMatch(s);
    if (matchDmy != null) {
      final d = int.parse(matchDmy[1]!);
      final m = int.parse(matchDmy[2]!);
      var y = int.parse(matchDmy[3]!);
      if (y < 100) y += 2000;
      return '${d.toString().padLeft(2, '0')}/${m.toString().padLeft(2, '0')}/${y}';
    }
    return s;
  }

  Future<void> _pickAndUpload(BuildContext context, String? obraId) async {
    final provider = Provider.of<HistorialAsistenciaProvider>(context, listen: false);
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

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(const SnackBar(content: Text('Subiendo archivo...'), duration: Duration(days: 1)));
    try {
      await provider.uploadFileFromBytes(bytes, file.name, obraId: obraId);
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(const SnackBar(content: Text('Subida exitosa.')));
      if (obraId != null) {
        await provider.fetchAndProcessExcel(obraId);
        if (provider.lastError != null) scaffold.showSnackBar(SnackBar(content: Text('Error: ${provider.lastError}')));
        else if (provider.statusMessage != null) scaffold.showSnackBar(SnackBar(content: Text(provider.statusMessage!)));
      }
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(content: Text('Error al subir archivo: $e')));
    }
  }

  // El botón descarga y procesa
  Future<void> _fetchAndReadExcel(BuildContext context, String? obraId) async {
    if (obraId == null || obraId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('obraId no disponible.')));
      return;
    }
    final provider = Provider.of<HistorialAsistenciaProvider>(context, listen: false);
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(const SnackBar(content: Text('Descargando y procesando archivo...'), duration: Duration(seconds: 2)));
    await provider.fetchAndProcessExcel(obraId);
    if (provider.lastError != null) scaffold.showSnackBar(SnackBar(content: Text('Error: ${provider.lastError}')));
    else if (provider.statusMessage != null) scaffold.showSnackBar(SnackBar(content: Text(provider.statusMessage!)));
  }

  Widget _buildPersonasList(HistorialAsistenciaProvider provider, String sheetName) {
    final personas = (provider.personasAsistencia[sheetName] ?? []).reversed.toList();
    if (personas.isEmpty) return const Center(child: Text('No hay personas procesadas.'));

    String _initials(String name) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isEmpty) return '';
      if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }

    List<String> _asStringList(dynamic v) {
      if (v == null) return <String>[];
      if (v is List<String>) return v;
      if (v is List) return v.map((e) => e?.toString() ?? '').toList();
      return <String>[];
    }

    int _countLetter(List<dynamic> list, String letter) {
      var c = 0;
      for (var v in list) {
        final s = v?.toString() ?? '';
        if (s.toLowerCase().contains(letter)) c++;
      }
      return c;
    }

    int _diasAsistidos(List<dynamic> lista) {
      var total = 0;
      for (var v in lista) {
        final s = v?.toString().trim() ?? '';
        if (s.isEmpty) continue;
        final d = double.tryParse(s.replaceAll(',', '.'));
        if (d != null) {
          total += d.toInt();
          continue;
        }
        final match = RegExp(r'-?\d+').firstMatch(s);
        if (match != null) total += int.tryParse(match.group(0)!) ?? 0;
      }
      return total;
    }

    double _horasExtraSum(List<dynamic> lista) {
      var sum = 0.0;
      for (var v in lista) {
        final s = v?.toString().trim() ?? '';
        if (s.isEmpty) continue;
        final d = double.tryParse(s.replaceAll(',', '.'));
        if (d != null) {
          sum += d;
          continue;
        }
        final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(s.replaceAll(',', '.'));
        if (match != null) sum += double.tryParse(match.group(0)!) ?? 0;
      }
      return sum;
    }

    Widget _summaryChip(String label, String value, {Color? color}) {
      // Mostrar etiqueta y valor en una sola fila
      return Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minWidth: 140),
        decoration: BoxDecoration(
          color: color ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '$label: ',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget _badge(String text, Color bg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        );

    Widget _rowWithLabel(String label, List<String> fila, Widget Function(String) cellBuilder) {
      return Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Row(
            children: List.generate(
              fila.length,
              (i) => Container(
                width: 72,
                height: 36,
                alignment: Alignment.center,
                child: cellBuilder(fila[i]),
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildPersonMatrix(p) {
      // normalizar listas del objeto persona antes de usarlas
      final fechaList = _asStringList(p.fecha);
      final diariaList = _asStringList(p.asistenciaDiaria);
      final finesList = _asStringList(p.asistenciaFinesSemana);
      final horasList = _asStringList(p.horasExtra);

      final maxForP = [fechaList.length, diariaList.length, finesList.length, horasList.length].fold(0, (a, b) => a > b ? a : b);

      // Espacios aumentados para que el texto quede visible y alineado
      const double labelWidth = 120.0;
      const double cellWidth = 72.0;
      const double cellHeight = 40.0;
      const double gap = 6.0;
      const double fontSizeLabel = 13.0;
      const double fontSizeCell = 12.0;

      Widget _cellBox(String s) {
        final t = s.trim();
        if (t.isEmpty) return const SizedBox.shrink();
        final lower = t.toLowerCase();
        if (lower.contains('p')) return _badge('Permiso', Colors.amber.shade100);
        if (lower.contains('f')) return _badge('Falla', Colors.red.shade100);
        if (lower.contains('l')) return _badge('Licencia', Colors.blue.shade100);
        if (lower.contains('r')) return _badge('Renuncia', Colors.grey.shade300);
        final numVal = double.tryParse(t.replaceAll(',', '.'));
        if (numVal != null) {
          final text = (numVal == numVal.truncateToDouble()) ? numVal.toInt().toString() : numVal.toStringAsFixed(1);
          return Text(text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSizeCell));
        }
        return Text(t, style: TextStyle(fontSize: fontSizeCell), maxLines: 2, overflow: TextOverflow.ellipsis);
      }

      final borderColor = Colors.grey.shade300;
      final borderWidth = 0.6;

      // columnas con más espacio por fila y líneas divisorias
      final List<Widget> columns = List.generate(maxForP, (i) {
        final fecha = i < fechaList.length ? _formatDate(fechaList[i]) : '';
        final diaria = i < diariaList.length ? diariaList[i] : '';
        final fines = i < finesList.length ? finesList[i] : '';
        final horas = i < horasList.length ? horasList[i] : '';
        return Container(
          width: cellWidth,
          margin: EdgeInsets.only(right: gap),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: borderColor, width: borderWidth)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fecha
              Container(
                width: cellWidth,
                height: cellHeight,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: borderWidth))),
                child: Text(fecha, textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeLabel, fontWeight: FontWeight.w700)),
              ),
              // Asistencia diaria
              Container(
                width: cellWidth,
                height: cellHeight,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: borderWidth))),
                child: _cellBox(diaria),
              ),
              // Fines de semana
              Container(
                width: cellWidth,
                height: cellHeight,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: borderWidth))),
                child: _cellBox(fines),
              ),
              // Horas extra
              Container(
                width: cellWidth,
                height: cellHeight,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                alignment: Alignment.center,
                child: _cellBox(horas),
              ),
            ],
          ),
        );
      });

      final double totalColumnsWidth = (cellWidth + gap) * maxForP;
      final double minAreaWidth = MediaQuery.of(context).size.width - labelWidth - 32;
      final double areaWidth = totalColumnsWidth < minAreaWidth ? minAreaWidth : totalColumnsWidth;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 260),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // labels alineadas con las filas, cada label usa la misma altura que una fila de celda
            SizedBox(
              width: labelWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: cellHeight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: borderWidth))),
                    child: Text('Fecha', style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSizeLabel)),
                  ),
                  Container(
                    height: cellHeight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: borderWidth))),
                    child: Text('Asistencia diaria', style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSizeLabel)),
                  ),
                  Container(
                    height: cellHeight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: borderWidth))),
                    child: Text('Fines de semana', style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSizeLabel)),
                  ),
                  Container(
                    height: cellHeight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Horas extra', style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSizeLabel)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _horizontalBodyController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalBodyController,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    width: areaWidth,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: personas.length,
      itemBuilder: (context, i) {
        final p = personas[i];
        final diaria = _asStringList(p.asistenciaDiaria);
        final fines = _asStringList(p.asistenciaFinesSemana);
        final combined = [...diaria, ...fines];
        final dias = _diasAsistidos(combined);
        final horasSum = _horasExtraSum(_asStringList(p.horasExtra));
        final horasText = (horasSum == horasSum.truncateToDouble()) ? horasSum.toInt().toString() : horasSum.toStringAsFixed(2);

        // resumen previo a la selección
        final cntP = _countLetter(combined, 'p');
        final cntF = _countLetter(combined, 'f');
        final cntL = _countLetter(combined, 'l');
        final cntR = _countLetter(combined, 'r');
        final cols = _asStringList(p.fecha).length;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade100,
              child: Text(_initials(p.nombre), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            ),
            // título compuesto: a la izquierda nombre/cargo/rut; a la derecha resumen 2x3 en la misma altura
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(p.cargo, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      Text(p.rut, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _summaryChip('Asistencia Diaria', dias.toString(), color: Colors.green.shade50),
                        const SizedBox(width: 8),
                        _summaryChip('Horas Extra', horasText, color: Colors.orange.shade50),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _summaryChip('Permiso', cntP.toString(), color: Colors.amber.shade50),
                        const SizedBox(width: 8),
                        _summaryChip('Falla', cntF.toString(), color: Colors.red.shade50),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _summaryChip('Licencia', cntL.toString(), color: Colors.blue.shade50),
                        const SizedBox(width: 8),
                        _summaryChip('Renuncia', cntR.toString(), color: Colors.grey.shade200),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Al expandir solo mostrar la matriz con los datos de la persona
            children: [
              Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                child: _buildPersonMatrix(p),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetSelector(HistorialAsistenciaProvider provider, String? selectedSheet, void Function(String) onSelect) {
    final sheets = provider.sheets;
    if (sheets.isEmpty) {
      return const SizedBox(height: 40, child: Align(alignment: Alignment.centerLeft, child: Text('No hay hojas cargadas.'))); 
    }
    final sheetNames = sheets.keys.toList();
    final selected = selectedSheet ?? sheetNames.first;

    final primaryColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.cyan.shade200;
 
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: sheetNames.map((name) {
        final sel = name == selected;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: sel ? primaryColor : Colors.white,
            foregroundColor: sel ? Colors.black : Colors.black87, // texto negro cuando está seleccionado
            side: BorderSide(color: sel ? Colors.transparent : Colors.grey.shade300),
            elevation: sel ? 2 : 0,
          ),
          onPressed: () => onSelect(name),
          child: Text(name),
        );
      }).toList(),
    );
  }

  Widget _buildSheetSummary(HistorialAsistenciaProvider provider, String sheetName) {
    final asistencia = provider.asistenciaDiaria[sheetName] ?? <List<String>>[];
    final horasExtra = provider.asistenciasHorasExtra[sheetName] ?? <List<String>>[];

    if (asistencia.isEmpty) return const SizedBox.shrink();

    final header = asistencia.first;
    final int cols = header.length;

    // contar asistencias por columna
    final List<int> asistCount = List<int>.filled(cols, 0);
    for (int r = 1; r < asistencia.length; r++) {
      final row = asistencia[r];
      for (int c = 0; c < cols; c++) {
        final cell = (c < row.length ? (row[c] ?? '') : '').toString().trim();
        if (cell.isNotEmpty) asistCount[c] = asistCount[c] + 1;
      }
    }

    // sumar horas extra por columna
    final List<double> horasSum = List<double>.filled(cols, 0.0);
    for (int r = 0; r < horasExtra.length; r++) {
      final row = horasExtra[r];
      for (int c = 0; c < cols; c++) {
        final raw = (c < row.length ? (row[c] ?? '') : '').toString().trim();
        if (raw.isEmpty) continue;
        final v = double.tryParse(raw.replaceAll(',', '.'));
        if (v != null) horasSum[c] = horasSum[c] + v;
        else {
          final m = RegExp(r'-?\d+(\.\d+)?').firstMatch(raw.replaceAll(',', '.'));
          if (m != null) horasSum[c] = horasSum[c] + (double.tryParse(m.group(0)!) ?? 0.0);
        }
      }
    }

    // fila horizontal desplazable
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(cols, (i) {
            final dateLabel = _formatDate(header[i] ?? '');
            final asist = asistCount[i];
            final horas = horasSum[i];
            final horasText = (horas == horas.truncateToDouble()) ? horas.toInt().toString() : horas.toStringAsFixed(1);
            return Container(
              width: 92,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8), color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dateLabel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)), child: Text('D: $asist', style: const TextStyle(fontSize: 12))),
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)), child: Text('HE: $horasText', style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments as Map<String, dynamic>?;
    final obraId = args?['obraId']?.toString();
    final obraNombre = args?['obraNombre']?.toString();

    final primaryColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.cyan.shade200;
 
    return Consumer<HistorialAsistenciaProvider>(builder: (context, provider, child) {
      if (_selectedSheet == null && provider.sheets.isNotEmpty) _selectedSheet = provider.sheets.keys.first;
 
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black, // texto e iconos en negro
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Subir archivo XLSX'),
                      onPressed: () => _pickAndUpload(context, obraId),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black, // texto e iconos en negro
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.download),
                      label: const Text('Descargar y cargar XLSX'),
                      onPressed: () => _fetchAndReadExcel(context, obraId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSheetSelector(provider, _selectedSheet, (name) {
                setState(() => _selectedSheet = name);
              }),
              const SizedBox(height: 12),
              Expanded(
                child: _selectedSheet == null
                    ? const Center(child: Text('No hay hojas cargadas.'))
                    : Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.all(8),
                        child: Builder(builder: (context) {
                          final sheet = _selectedSheet!;
                          if ((provider.personasAsistencia[sheet] ?? []).isEmpty && (provider.personas[sheet]?.isNotEmpty ?? false)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              provider.extractPersonasAsistencias(sheetName: sheet);
                            });
                            return const Center(child: CircularProgressIndicator());
                          }
                          // Mostrar únicamente la lista de personas
                          return _buildPersonasList(provider, sheet);
                        }),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}