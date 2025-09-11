import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
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

  late TextEditingController _tipoController;
  late TextEditingController _obraController;


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

    _tipoController = TextEditingController(text: context.read<HerramientasProvider>().tipo ?? '');
    _obraController = TextEditingController(text: context.read<HerramientasProvider>().obraAsig ?? '');
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _obraController.dispose();
    super.dispose();
  }

  void _resetDropdowns() {
    setState(() {
      _tipo = null;
      _estado = null;
      _garantiaDesde = null;
      _garantiaHasta = null;
      _obraAsig = null;
      _rangoCantidad = null;
      _tipoController.clear();
      _obraController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<HerramientasProvider>(context);

    final tiposUnicos = provider
      .herramientas
      .map((h) => h.tipo)
      .toSet()
      .toList();


    final obrasUnicas = provider
      .herramientas
      .map((h) => h.obraAsig)
      .where((obra) => obra != null && obra.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList();

    


    return Column(
      children: [
        // ===================== Tipo =====================
        Row(
          children: [
            const Text('Tipo de herramienta'),
            const Spacer(),
            DropdownMenu<String>(
              initialSelection: _tipo,
              hintText: 'Selecciona tipo',
              key: ValueKey(_tipo),
              dropdownMenuEntries: tiposUnicos
                  .map((tipo) => DropdownMenuEntry(value: tipo, label: tipo ?? 'Sin filtro'))
                  .toList(),
              onSelected: (String? value) {
                setState(() {
                  _tipo = value;
                });
              },
              enableFilter: true,
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
              key: ValueKey(_estado),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Activo', label: 'Activo'),
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
            DropdownMenu<String>(
              initialSelection: _obraAsig,
              hintText: 'Selecciona obra',
              key: ValueKey(_obraAsig),
              dropdownMenuEntries: obrasUnicas
                  .map((obra) => DropdownMenuEntry(value: obra, label: obra))
                  .toList(),
              onSelected: (String? value) {
                setState(() {
                  _obraAsig = value;
                });
              },
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
                  setState(() {
                    _rangoCantidad = values;
                  });
                },
              ),
            ),
            Text(
              '${(_rangoCantidad?.start.round() ?? 1)} - ${(_rangoCantidad?.end.round() ?? 10000)} unidades',
            ),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(text: 'Aplicar Filtros', size: const Size(220, 35), onPressed: (){
          provider.actualizarFiltros(
            tipo: _tipo,
            estado: _estado,
            garantiaDesde: _garantiaDesde,
            garantiaHasta: _garantiaHasta,
            obraAsig: _obraAsig,
            rangoCantidad: _rangoCantidad,
          );
        }),
        const SizedBox(height: 12),
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