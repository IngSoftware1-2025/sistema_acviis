import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/providers/vehiculos_provider.dart';

class VehiculosFiltrosDisplay extends StatefulWidget {
  const VehiculosFiltrosDisplay({super.key});

  @override
  State<VehiculosFiltrosDisplay> createState() => _VehiculosFiltrosDisplayState();
}

class _VehiculosFiltrosDisplayState extends State<VehiculosFiltrosDisplay> {

  DateTime? _tecnicaDesde;
  DateTime? _tecnicaHasta;
  DateTime? _gasesDesde;
  DateTime? _gasesHasta;
  DateTime? _mantencionDesde;
  DateTime? _mantencionHasta;
  RangeValues? _rangoCapacidad; 
  String? _tipoNeumatico;
  String? _estado; 

  late TextEditingController _tipoNeumaticoController;


  @override
  void initState() {
    super.initState();
    final provider = Provider.of<VehiculosProvider>(context, listen: false);
    _tecnicaDesde = provider.tecnicaDesde;
    _tecnicaHasta = provider.tecnicaHasta;
    _gasesDesde = provider.gasesDesde;
    _gasesHasta = provider.gasesHasta;
    _mantencionDesde = provider.mantencionDesde;
    _mantencionHasta = provider.mantencionHasta;
    _rangoCapacidad = provider.rangoCapacidad;
    _tipoNeumatico = provider.tipoNeumatico;
    _estado = provider.estado;

    _tipoNeumaticoController = TextEditingController(text: context.read<VehiculosProvider>().tipoNeumatico ?? '');
  }

  @override
  void dispose() {
    _tipoNeumaticoController.dispose();
    super.dispose();
  }

  void _resetDropdowns() {
    setState(() {
      _tecnicaDesde = null;
      _tecnicaHasta = null;
      _gasesDesde = null;
      _gasesHasta = null;
      _mantencionDesde = null;
      _mantencionHasta = null;
      _rangoCapacidad = null;
      _tipoNeumatico = null;
      _estado = null;
      _tipoNeumaticoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<VehiculosProvider>(context);
    final tiposUnicosNeumaticos = provider
    .vehiculos
    .map((v) => v.neumaticos)
    .toSet()
    .toList();


    return Column(
      children: [
        // ===================== Tipo de neumático =====================
        Row(
          children: [
            const Text('Tipo de herramienta'),
            const Spacer(),
            DropdownMenu<String>(
              initialSelection: _tipoNeumatico,
              hintText: 'Selecciona tipo',
              key: ValueKey(_tipoNeumatico),
              dropdownMenuEntries: tiposUnicosNeumaticos
                  .map((tipo) => DropdownMenuEntry(value: tipo, label: tipo))
                  .toList(),
              onSelected: (String? value) {
                setState(() {
                  _tipoNeumatico = value;
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
        // ===================== Revisión técnica =====================
        Row(
          children: [
            const Text('Última revisión técnica'),
            const Spacer(),
            // Botón para seleccionar fecha desde
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _tecnicaDesde ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                }
              },
              child: Text(
                _tecnicaDesde != null
                    ? '${_tecnicaDesde!.day}/${_tecnicaDesde!.month}/${_tecnicaDesde!.year}'
                    : 'Desde',
              ),
            ),
            const SizedBox(width: 8),
            // Botón para seleccionar fecha hasta
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _tecnicaHasta ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                }
              },
              child: Text(
                _tecnicaHasta != null
                    ? '${_tecnicaHasta!.day}/${_tecnicaHasta!.month}/${_tecnicaHasta!.year}'
                    : 'Hasta',
              ),
            ),
          ],
        ),
        // ===================== Revisión de gases =====================
        Row(
          children: [
            const Text('Última revisión de gases'),
            const Spacer(),
            // Botón para seleccionar fecha desde
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _gasesDesde ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                }
              },
              child: Text(
                _gasesDesde != null
                    ? '${_gasesDesde!.day}/${_gasesDesde!.month}/${_gasesDesde!.year}'
                    : 'Desde',
              ),
            ),
            const SizedBox(width: 8),
            // Botón para seleccionar fecha hasta
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _gasesHasta ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                }
              },
              child: Text(
                _gasesHasta != null
                    ? '${_gasesHasta!.day}/${_gasesHasta!.month}/${_gasesHasta!.year}'
                    : 'Hasta',
              ),
            ),
          ],
        ),
        // ===================== Próxima mantención =====================
        Row(
          children: [
            const Text('Próxima mantención'),
            const Spacer(),
            // Botón para seleccionar fecha desde
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _mantencionDesde ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                }
              },
              child: Text(
                _mantencionDesde != null
                    ? '${_mantencionDesde!.day}/${_mantencionDesde!.month}/${_mantencionDesde!.year}'
                    : 'Desde',
              ),
            ),
            const SizedBox(width: 8),
            // Botón para seleccionar fecha hasta
            ElevatedButton(
              onPressed: () async {
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _mantencionHasta ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                }
              },
              child: Text(
                _mantencionHasta != null
                    ? '${_mantencionHasta!.day}/${_mantencionHasta!.month}/${_mantencionHasta!.year}'
                    : 'Hasta',
              ),
            ),
          ],
        ),
        // ===================== Rango de capacidad =====================
        Row(
          children: [
            Text('Capacidad'),
            Spacer(),
            Expanded(
              child: RangeSlider(
                values: _rangoCapacidad ?? const RangeValues(1, 10000),
                min: 1,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  (_rangoCapacidad?.start.round() ?? 100).toString(),
                  (_rangoCapacidad?.end.round() ?? 10000).toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _rangoCapacidad = values;
                  });
                },
              ),
            ),
            Text(
              '${(_rangoCapacidad?.start.round() ?? 1)} - ${(_rangoCapacidad?.end.round() ?? 10000)} kilogramos',
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        PrimaryButton(
          text: 'Aplicar Filtros',
          size: const Size(220, 35),
          onPressed: (){
           provider.actualizarFiltros(
              tecnicaDesde: _tecnicaDesde,
              tecnicaHasta: _tecnicaHasta,
              gasesDesde: _gasesDesde,
              gasesHasta: _gasesHasta,
              mantencionDesde: _mantencionDesde,
              mantencionHasta: _mantencionHasta,
              rangoCapacidad: _rangoCapacidad,
              tipoNeumatico: _tipoNeumatico,
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