import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/herramientas_provider.dart';

class HerramientasFiltrosDisplay extends StatefulWidget {
  const HerramientasFiltrosDisplay({super.key});

  @override
  State<HerramientasFiltrosDisplay> createState() => _HerramientasFiltrosDisplayState();
}

class _HerramientasFiltrosDisplayState extends State<HerramientasFiltrosDisplay> {

  String? _tipo;
  String? _estado; 
  DateTime? _garantiaDesde;
  DateTime? _garantiaHasta;
  String? _obraAsig;
  RangeValues? _rangoCantidad;


  @override
  void initState() {
    super.initState();
    final provider = Provider.of<HerramientasProvider>(context, listen: false);
    _tipo = provider.tipo;
    _estado = provider.estado;
    _garantiaDesde = provider.garantiaDesde;
    _garantiaHasta = provider.garantiaHasta;
    _obraAsig = provider.obraAsig;
    _rangoCantidad = provider.rangoCantidad;
  }

  void _resetDropdowns() {
    setState(() {
      _tipo = null;
      _estado = null;
      _garantiaDesde = null;
      _garantiaHasta = null;
      _obraAsig = null;
      _rangoCantidad = null;
    });
  }

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<HerramientasProvider>(context);


    return Column(
      children: [
        // ===================== Tipo =====================
        Row(
          children: [
            const Text('Tipo de herramienta'),
            const Spacer(),
            Expanded(
              flex: 2,
              child: Autocomplete<String>(
                initialValue: TextEditingValue(text: _tipo ?? ''),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                 
                  final tiposUnicos = context.read<HerramientasProvider>()
                      .herramientas
                      .map((h) => h.tipo)
                      .where((tipo) => tipo.isNotEmpty)
                      .toSet()
                      .toList();

                  return tiposUnicos.where((tipo) =>
                      tipo.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String tipo) {
                  setState(() {
                    _tipo = tipo; 
                  });
                },
              ),
            ),
          ],
        ),

        // ===================== Estado =====================
        Row(
          children: [
            Text('Estado'),
            Spacer(),
            DropdownMenu<String>(
              initialSelection: _estado,
              hintText: 'Estado',
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Activa', label: 'Activa'),
                DropdownMenuEntry(value: 'De baja', label: 'De baja'),
              ],
              onSelected: (String? value) {
                setState(() {
                  _estado = value;
                });
              },
            ),
          ],
        ),

        // ===================== Garantía =====================
        Row(
          children: [
            const Text('Garantía'),
            const Spacer(),
            // Botón para seleccionar fecha desde
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _garantiaDesde ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                  provider.actualizarFiltros(garantiaDesde: fecha);
                }
              },
              child: Text(
                _garantiaDesde != null
                    ? '${_garantiaDesde!.day}/${_garantiaDesde!.month}/${_garantiaDesde!.year}'
                    : 'Desde',
              ),
            ),
            const SizedBox(width: 8),
            // Botón para seleccionar fecha hasta
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _garantiaHasta ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                  provider.actualizarFiltros(garantiaHasta: fecha);
                }
              },
              child: Text(
                _garantiaHasta != null
                    ? '${_garantiaHasta!.day}/${_garantiaHasta!.month}/${_garantiaHasta!.year}'
                    : 'Hasta',
              ),
            ),
          ],
        ),

        // ===================== Obra asignada =====================
        Row(
          children: [
            const Text('Obra asignada'),
            const Spacer(),
            Expanded(
              flex: 2,
              child: Autocomplete<String>(
                initialValue: TextEditingValue(text: _obraAsig ?? ''),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                 
                  final obrasUnicas = context.read<HerramientasProvider>()
                      .herramientas
                      .map((h) => h.obraAsig ?? '')
                      .where((obra) => obra.isNotEmpty)
                      .toSet()
                      .toList();

                  return obrasUnicas.where((obra) =>
                      obra.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String obra) {
                  setState(() {
                    _obraAsig = obra; 
                  });
                },
              ),
            ),
          ],
        ),

        // ===================== Cantidad =====================
        Row(
          children: [
            Text('Cantidad'),
            Spacer(),
            Expanded(
              child: RangeSlider(
                values: _rangoCantidad ?? const RangeValues(1, 10000),
                min: 1,
                max: 10000,
                divisions: 1000,
                labels: RangeLabels(
                  (_rangoCantidad?.start.round() ?? 1).toString(),
                  (_rangoCantidad?.end.round() ?? 10000).toString(),
                ),
                onChanged: (RangeValues values) {
                  provider.actualizarFiltros(rangoCantidad: values);
                },
              ),
            ),
            Text(
              '${(_rangoCantidad?.start.round() ?? 1)} - ${(_rangoCantidad?.end.round() ?? 10000)} unidades',
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Limpiar todos los filtros'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            provider.reiniciarFiltros();
            _resetDropdowns();
          },
        ),
      ],
    );
  }
}