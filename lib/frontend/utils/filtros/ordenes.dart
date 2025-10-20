import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';

class OrdenesFiltrosDisplay extends StatefulWidget {
  const OrdenesFiltrosDisplay({super.key});

  @override
  State<OrdenesFiltrosDisplay> createState() => _OrdenesFiltrosDisplayState();
}

class _OrdenesFiltrosDisplayState extends State<OrdenesFiltrosDisplay> {
  late TextEditingController _numeroOrdenController;
  late TextEditingController _centroCostoController;
  late TextEditingController _seccionItemizadoController;
  late TextEditingController _direccionController;
  late TextEditingController _servicioController;

  RangeValues _rangoValor = const RangeValues(0, 1000000);
  bool? _descuento;

  @override
  void initState() {
    super.initState();
    final provider = context.read<OrdenesProvider>();
    _numeroOrdenController = TextEditingController(text: provider.numeroOrden ?? '');
    _centroCostoController = TextEditingController(text: provider.centroCosto ?? '');
    _seccionItemizadoController = TextEditingController(text: provider.seccionItemizado ?? '');
    _direccionController = TextEditingController(text: provider.direccion ?? '');
    _servicioController = TextEditingController(text: provider.servicioOfrecido ?? '');
    if (provider.valorDesde != null && provider.valorHasta != null) {
      _rangoValor = RangeValues(provider.valorDesde!.toDouble(), provider.valorHasta!.toDouble());
    }
    _descuento = provider.descuento;
  }

  @override
  void dispose() {
    _numeroOrdenController.dispose();
    _centroCostoController.dispose();
    _seccionItemizadoController.dispose();
    _direccionController.dispose();
    _servicioController.dispose();
    super.dispose();
  }

  void _resetFields() {
    _numeroOrdenController.clear();
    _centroCostoController.clear();
    _seccionItemizadoController.clear();
    _direccionController.clear();
    _servicioController.clear();
    _rangoValor = const RangeValues(0, 1000000);
    _descuento = null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdenesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _numeroOrdenController,
          decoration: const InputDecoration(labelText: 'Número de Orden'),
        ),
        TextField(
          controller: _centroCostoController,
          decoration: const InputDecoration(labelText: 'Centro de Costo'),
        ),
        TextField(
          controller: _seccionItemizadoController,
          decoration: const InputDecoration(labelText: 'Sección Itemizado'),
        ),
        TextField(
          controller: _direccionController,
          decoration: const InputDecoration(labelText: 'Dirección'),
        ),
        TextField(
          controller: _servicioController,
          decoration: const InputDecoration(labelText: 'Servicio Ofrecido'),
        ),
        const SizedBox(height: 12),

        Text('Valor'),
        RangeSlider(
          values: _rangoValor,
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels(
            _rangoValor.start.round().toString(),
            _rangoValor.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _rangoValor = values;
            });
          },
        ),

        Row(
          children: [
            const Text('Descuento'),
            const Spacer(),
            DropdownMenu<bool?>(
              key: const ValueKey('descuento'),
              initialSelection: _descuento,
              hintText: 'Cualquiera',
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: true, label: 'Sí'),
                DropdownMenuEntry(value: false, label: 'No'),
              ],
              onSelected: (value) {
                setState(() {
                  _descuento = value;
                });
              },
            ),
          ],
        ),

        const SizedBox(width: 8),

        PrimaryButton(
          text: 'Aplicar Filtros',
          size: const Size(220, 35),
          onPressed: () {
            provider.actualizarFiltros(
              numeroOrden: _numeroOrdenController.text,
              centroCosto: _centroCostoController.text,
              seccionItemizado: _seccionItemizadoController.text,
              direccion: _direccionController.text,
              servicioOfrecido: _servicioController.text,
              valorDesde: _rangoValor.start.toInt(),
              valorHasta: _rangoValor.end.toInt(),
              descuento: _descuento,
            );
          },
        ),
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
            _resetFields();
            setState(() {});
          },
        ),
      ],
    );
  }
}
