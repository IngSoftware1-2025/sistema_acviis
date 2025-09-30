import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/pagos_provider.dart';

class FiltroFacturasDialog extends StatefulWidget {
  const FiltroFacturasDialog({super.key});

  @override
  State<FiltroFacturasDialog> createState() => _FiltroFacturasDialogState();
}

class _FiltroFacturasDialogState extends State<FiltroFacturasDialog> {
  // Controllers para los campos de filtro
  final TextEditingController _servicioController = TextEditingController();
  final TextEditingController _valorMinController = TextEditingController();
  final TextEditingController _valorMaxController = TextEditingController();
  
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  String? _estadoPagoSeleccionado;
  String? _tipoFacturaSeleccionado; // Nuevo filtro por tipo
  
  // Opciones de estado de pago
  final List<String> _estadosPago = ['Todos', 'Pagado', 'Pendiente', 'Vencido'];
  
  // Opciones de tipo de factura
  final List<String> _tiposFactura = ['Todos', 'Factura Normal', 'Caja Chica'];

  @override
  void initState() {
    super.initState();
    // Cargar filtros actuales del provider si existen
    final provider = Provider.of<PagosProvider>(context, listen: false);
    if (provider.filtrosFacturas != null) {
      _servicioController.text = provider.filtrosFacturas!['servicio'] ?? '';
      _valorMinController.text = provider.filtrosFacturas!['valorMin']?.toString() ?? '';
      _valorMaxController.text = provider.filtrosFacturas!['valorMax']?.toString() ?? '';
      _fechaDesde = provider.filtrosFacturas!['fechaDesde'];
      _fechaHasta = provider.filtrosFacturas!['fechaHasta'];
      _estadoPagoSeleccionado = provider.filtrosFacturas!['estadoPago'] ?? 'Todos';
      
      // Mapear el tipo de factura guardado al mostrado
      String tipoGuardado = provider.filtrosFacturas!['tipoFactura'] ?? '';
      if (tipoGuardado == 'factura') {
        _tipoFacturaSeleccionado = 'Factura Normal';
      } else if (tipoGuardado == 'caja_chica') {
        _tipoFacturaSeleccionado = 'Caja Chica';
      } else {
        _tipoFacturaSeleccionado = 'Todos';
      }
    } else {
      _estadoPagoSeleccionado = 'Todos';
      _tipoFacturaSeleccionado = 'Todos';
    }
  }

  @override
  void dispose() {
    _servicioController.dispose();
    _valorMinController.dispose();
    _valorMaxController.dispose();
    super.dispose();
  }

  void _aplicarFiltros() {
    final filtros = <String, dynamic>{};
    
    // Recopilar valores de filtros
    if (_servicioController.text.isNotEmpty) {
      filtros['servicio'] = _servicioController.text;
    }
    
    if (_valorMinController.text.isNotEmpty) {
      filtros['valorMin'] = double.tryParse(_valorMinController.text);
    }
    
    if (_valorMaxController.text.isNotEmpty) {
      filtros['valorMax'] = double.tryParse(_valorMaxController.text);
    }
    
    if (_fechaDesde != null) {
      filtros['fechaDesde'] = _fechaDesde;
    }
    
    if (_fechaHasta != null) {
      filtros['fechaHasta'] = _fechaHasta;
    }
    
    if (_estadoPagoSeleccionado != null && _estadoPagoSeleccionado != 'Todos') {
      filtros['estadoPago'] = _estadoPagoSeleccionado;
    }
    
    // Nuevo filtro por tipo de factura
    if (_tipoFacturaSeleccionado != null && _tipoFacturaSeleccionado != 'Todos') {
      if (_tipoFacturaSeleccionado == 'Factura Normal') {
        filtros['tipoFactura'] = 'factura';
      } else if (_tipoFacturaSeleccionado == 'Caja Chica') {
        filtros['tipoFactura'] = 'caja_chica';
      }
    }
    
    // Aplicar filtros a través del provider
    Provider.of<PagosProvider>(context, listen: false).aplicarFiltrosFacturas(filtros);
    Navigator.pop(context, true);
  }

  void _limpiarFiltros() {
    setState(() {
      _servicioController.clear();
      _valorMinController.clear();
      _valorMaxController.clear();
      _fechaDesde = null;
      _fechaHasta = null;
      _estadoPagoSeleccionado = 'Todos';
      _tipoFacturaSeleccionado = 'Todos';
    });
    
    // Limpiar filtros en el provider
    Provider.of<PagosProvider>(context, listen: false).limpiarFiltrosFacturas();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filtrar Facturas'),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _limpiarFiltros,
            tooltip: 'Limpiar todos los filtros',
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nuevo filtro por tipo de factura
              const Text('Tipo de Factura', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipoFacturaSeleccionado,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _tiposFactura.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Row(
                      children: [
                        Icon(
                          tipo == 'Caja Chica' 
                            ? Icons.account_balance_wallet 
                            : tipo == 'Factura Normal'
                              ? Icons.receipt_long
                              : Icons.all_inclusive,
                          size: 16,
                          color: tipo == 'Caja Chica' 
                            ? Colors.orange 
                            : tipo == 'Factura Normal'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(tipo),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _tipoFacturaSeleccionado = value);
                },
              ),
              const SizedBox(height: 16),
              
              // Filtro por servicio ofrecido
              const Text('Servicio Ofrecido', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _servicioController,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre del servicio...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Filtro por rango de valores
              const Text('Rango de Valor', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valorMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Mínimo',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _valorMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Máximo',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Filtro por plazo de pago
              const Text('Plazo para Pagar', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: _fechaDesde ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (fecha != null) {
                          setState(() => _fechaDesde = fecha);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Desde',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _fechaDesde != null 
                            ? '${_fechaDesde!.day}/${_fechaDesde!.month}/${_fechaDesde!.year}'
                            : 'Seleccionar',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: _fechaHasta ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (fecha != null) {
                          setState(() => _fechaHasta = fecha);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hasta',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _fechaHasta != null 
                            ? '${_fechaHasta!.day}/${_fechaHasta!.month}/${_fechaHasta!.year}'
                            : 'Seleccionar',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Filtro por estado de pago
              const Text('Estado de Pago', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _estadoPagoSeleccionado,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _estadosPago.map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _estadoPagoSeleccionado = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _aplicarFiltros,
          icon: const Icon(Icons.filter_alt),
          label: const Text('Aplicar Filtros'),
        ),
      ],
    );
  }
}
