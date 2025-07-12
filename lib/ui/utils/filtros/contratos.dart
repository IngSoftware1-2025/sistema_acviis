import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';

class ContratosFiltrosDisplay extends StatefulWidget {
  const ContratosFiltrosDisplay({
    super.key
  });
  @override
  State<ContratosFiltrosDisplay> createState() => _ContratosFiltrosDisplayState();
}

class _ContratosFiltrosDisplayState extends State<ContratosFiltrosDisplay> {
  String? _estadoContrato;
  int _tiempoContrato = 1;
  int _cantidadContratos = 1; // Nuevo estado

  @override
  void initState(){
    super.initState();
    final provider = Provider.of<TrabajadoresProvider>(context, listen: false);
    _estadoContrato = provider.estadoContrato;
    _tiempoContrato = provider.tiempoContrato ?? 1;
    _cantidadContratos = provider.cantidadContratos ?? 1; // Nuevo
  }

  void _resetDropdowns() {
    setState(() {
      _estadoContrato = null;
      _tiempoContrato = 1;
      _cantidadContratos = 1; // Nuevo
    });
  }

  @override
  Widget build(BuildContext context){
    final provider = Provider.of<TrabajadoresProvider>(context);

    return Column(
      children: [
        Row(
          children: [
            Text('Estado de contrato'),
            Spacer(),
            DropdownMenu<String>(
              key: ValueKey(_estadoContrato),
              initialSelection: _estadoContrato,
              onSelected: (value) {
              setState(() {
                _estadoContrato = value;
              });
              provider.actualizarFiltros(estadoContrato: value);
              },
              dropdownMenuEntries: 
              ['Activo', 'Reemplazado']
                .map((estado) => DropdownMenuEntry(
                  value: estado,
                  label: estado,
                  ))
                .toList(),
              hintText: 'Seleccionar',
            ),
          ]
        ),
        Row(
          children: [
            Text('Tiempo restante de contrato'),
            Spacer(),
            InputQty(
              minVal: 0,
              maxVal: 12,
              initVal: _tiempoContrato,
              qtyFormProps: QtyFormProps(
                enableTyping: false
              ),
              key: ValueKey(_tiempoContrato),
              decoration: QtyDecorationProps(
                borderShape: BorderShapeBtn.circle,
                btnColor: Colors.blue,
                isBordered: false,
              ),
              onQtyChanged: (value) {
                int val = value is int ? value : (value is double ? value.toInt() : int.tryParse(value.toString()) ?? 0);
                setState(() {
                  _tiempoContrato = val;
                });
                provider.actualizarFiltros(tiempoContrato: val);
              },
            ),
            Text('Año${(_tiempoContrato) > 1 ? "s" : ""}'),
          ],
        ),
        Row(
          children: [
            Text('Cantidad de contratos'),
            Spacer(),
            InputQty(
              minVal: 1,
              maxVal: 20,
              initVal: _cantidadContratos,
              key: ValueKey(_cantidadContratos),
              qtyFormProps: QtyFormProps(
                enableTyping: false
              ),
              decoration: QtyDecorationProps(
                borderShape: BorderShapeBtn.circle,
                btnColor: Colors.blue,
                isBordered: false,
              ),
              onQtyChanged: (value) {
                int val = value is int ? value : (value is double ? value.toInt() : int.tryParse(value.toString()) ?? 1);
                setState(() {
                  _cantidadContratos = val;
                });
                provider.actualizarFiltros(cantidadContratos: val);
              },
            ),
          ],
        ),
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
      ]
    );
  }
}