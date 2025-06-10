
/*
### TODO ###
Obra asignada: {Renca, Rancagua, etc}
Fecha de contratacion: -> Tiempo restante de contrato: {X<1año, 2años>X, 1año==X}

Estado civil: {Soltero, Casado, etc}
Fecha de nacimiento: -> Edad: {Ej. X>40, 40>X, 1año==X}

Sistema de salud: {Fonasa, Isapre, etc} => Debatible xd
Sueldos: {X>Y, X<Y, X==Y}

Despido: -> Estado: {Activo, Inactivo, Despedido, Renuncio}

*/
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';

class FiltrosDisplay extends StatefulWidget {
  const FiltrosDisplay({super.key});

  @override
  State<FiltrosDisplay> createState() => _FiltrosDisplayState();
}

class _FiltrosDisplayState extends State<FiltrosDisplay> {
  // Controladores para los DropdownMenu
  String? _obraAsignada;
  String? _cargo;
  String? _estadoCivil;
  String? _sistemaSalud;
  String? _estadoEmpresa;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TrabajadoresProvider>(context, listen: false);
    _obraAsignada = provider.obraAsignada;
    _cargo = provider.cargo;
    _estadoCivil = provider.estadoCivil;
    _sistemaSalud = provider.sistemaSalud;
    _estadoEmpresa = provider.estadoEmpresa;
  }

  void _resetDropdowns() {
    setState(() {
      _obraAsignada = null;
      _cargo = null;
      _estadoCivil = null;
      _sistemaSalud = null;
      _estadoEmpresa = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrabajadoresProvider>(context);

    return Column(
      children: [
        // ===================== Obra asignada =====================
        Row(
          children: [
            Text('Obra asignada'),
            Spacer(),
            DropdownMenu<String>(
              initialSelection: _obraAsignada,
              hintText: 'Obra asignada',
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Obra Norte', label: 'Obra Norte'),
                DropdownMenuEntry(value: 'Obra Sur', label: 'Obra Sur'),
                DropdownMenuEntry(value: 'Obra Este', label: 'Obra Este'),
                DropdownMenuEntry(value: 'Obra Oeste', label: 'Obra Oeste'),
              ],
              onSelected: (String? newValue) {
                setState(() {
                  _obraAsignada = newValue;
                });
                provider.actualizarFiltros(obraAsignada: newValue);
              },
              key: ValueKey(_obraAsignada),
            ),
          ],
        ),

        // ===================== Cargo =====================
        Row(
          children: [
            Text('Cargo'),
            Spacer(),
            DropdownMenu<String>(
              hintText: 'Cargo',
              initialSelection: _cargo,
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Maestro', label: 'Maestro'),
                DropdownMenuEntry(value: 'Ayudante', label: 'Ayudante'),
                DropdownMenuEntry(value: 'Oficina Tecnica', label: 'Oficina Técnica'),
                DropdownMenuEntry(value: 'Electricista', label: 'Electricista'),
                DropdownMenuEntry(value: 'Supervisor', label: 'Supervisor'),
                DropdownMenuEntry(value: 'Jornal', label: 'Jornal'),
              ],
              onSelected: (String? newValue) {
                setState(() {
                  _cargo = newValue;
                });
                provider.actualizarFiltros(cargo: newValue);
              },
              enableSearch: false,
              key: ValueKey(_cargo),
            ),
          ],
        ),

        // ===================== Tiempo Restante de contrato =====================
        Row(
          children: [
            Text('Tiempo restante de contrato'),
            Spacer(),
            InputQty(
              minVal: 0,
              maxVal: 12,
              initVal: provider.tiempoContrato ?? 1,
              qtyFormProps: QtyFormProps(
                enableTyping: false
              ),
              decoration: QtyDecorationProps(
                borderShape: BorderShapeBtn.circle,
                btnColor: Colors.blue,
                isBordered: false,
              ),
              onQtyChanged: (value) {
                value = value is int ? value : (value is double ? value.toInt() : int.tryParse(value.toString()) ?? 0);
                provider.actualizarFiltros(tiempoContrato: value);
              },
            ),
            Text('Año${(provider.tiempoContrato ?? 1) > 1 ? "s" : ""}'),
          ],
        ),

        // ===================== Estado Civil =====================
        Row(
          children: [
            Text('Estado Civil'),
            Spacer(),
            DropdownMenu<String>(
              initialSelection: _estadoCivil,
              hintText: 'Estado civil',
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Soltero', label: 'Soltero'),
                DropdownMenuEntry(value: 'Casado', label: 'Casado'),
              ],
              enableSearch: false,
              onSelected: (String? newValue) {
                setState(() {
                  _estadoCivil = newValue;
                });
                provider.actualizarFiltros(estadoCivil: newValue);
              },
              key: ValueKey(_estadoCivil),
            ),
          ],
        ),

        // ===================== Edad =====================
        Row(
          children: [
            Text('Edad'),
            Spacer(),
            Expanded(
              child: RangeSlider(
                values: provider.rangoEdad ?? const RangeValues(18, 100),
                min: 18,
                max: 100,
                divisions: 82,
                labels: RangeLabels(
                  (provider.rangoEdad?.start.round() ?? 18).toString(),
                  (provider.rangoEdad?.end.round() ?? 100).toString(),
                ),
                onChanged: (RangeValues values) {
                  provider.actualizarFiltros(rangoEdad: values);
                },
              ),
            ),
            Text(
              '${(provider.rangoEdad?.start.round() ?? 18)} - ${(provider.rangoEdad?.end.round() ?? 100)} años',
            ),
          ],
        ),

        // ===================== Sistema de salud =====================
        Row(
          children: [
            Text('Sistema de salud'),
            Spacer(),
            DropdownMenu<String>(
              initialSelection: _sistemaSalud,
              hintText: 'Sistema de salud',
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Fonasa', label: 'Fonasa'),
                DropdownMenuEntry(value: 'Isapre', label: 'Isapre'),
              ],
              enableSearch: false,
              onSelected: (String? value) {
                setState(() {
                  _sistemaSalud = value;
                });
                provider.actualizarFiltros(sistemaSalud: value);
              },
              key: ValueKey(_sistemaSalud),
            ),
          ],
        ),

        // ===================== Sueldos (No contemplados todavia) =====================
        Row(
          children: [
            Text('Rango de Sueldo'),
            Spacer(),
            Column(
              children: [
                RangeSlider(
                  values: provider.rangoSueldo ?? const RangeValues(0, 1),
                  max: 10,
                  divisions: 10,
                  labels: RangeLabels(
                    (provider.rangoSueldo?.start.round() ?? 0).toString(),
                    (provider.rangoSueldo?.end.round() ?? 1).toString(),
                  ),
                  onChanged: (RangeValues values) {
                    provider.actualizarFiltros(rangoSueldo: values);
                  },
                ),
                Center(
                  child: Text(
                    'Rango: ${(provider.rangoSueldo?.start.round() ?? 0) * 1000000}CLP - ${(provider.rangoSueldo?.end.round() ?? 1) * 1000000}CLP'
                  )
                ),
              ],
            )
          ]
        ),

        // ===================== Estado (Temporal) =====================
        Row(
          children: [
            Text('Estado actual en la empresa'),
            Spacer(),
            DropdownMenu<String>(
              initialSelection: _estadoEmpresa,
              hintText: 'Estado',
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'Activo', label: 'Activo'),
                DropdownMenuEntry(value: 'Inactivo', label: 'Inactivo'),
                DropdownMenuEntry(value: 'Despedido', label: 'Despedido'),
                DropdownMenuEntry(value: 'Renuncio', label: 'Renunció'),
              ],
              enableSearch: false,
              onSelected: (String? value) {
                setState(() {
                  _estadoEmpresa = value;
                });
                provider.actualizarFiltros(estadoEmpresa: value);
              },
              key: ValueKey(_estadoEmpresa),
            ),
          ]
        ),

        // ===================== BOTÓN LIMPIAR TODOS =====================
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
