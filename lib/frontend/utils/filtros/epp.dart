import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';

class EppFiltrosDisplay extends StatefulWidget {
  final VoidCallback? onClose;
  
  const EppFiltrosDisplay({super.key, this.onClose});

  @override
  State<EppFiltrosDisplay> createState() => _EppFiltrosDisplayState();
}

class _EppFiltrosDisplayState extends State<EppFiltrosDisplay> {
  // Filtros seleccionados
  Set<String> _tiposSeleccionados = {};
  Set<String> _obrasSeleccionadas = {};
  RangeValues? _rangoCantidad;
  bool? _tieneCertificado;

  // ✅ CORRECCIÓN 1: LISTA SINCRONIZADA CON AGREGAR/MODIFICAR
  final List<String> _todosLosTipos = [
    'Guante Cabritilla',
    'Guante Multiflex',
    'Tapón Auditivo',
    'Tapón Auditivo tipo Fono',
    'Antiparra de Seguridad Clara',
    'Antiparra de Seguridad Oscura',
    'Sobre lente Claro',
    'Sobre lente Oscuro',
    'Casco Azul',
    'Casco Blanco',
    'Geólogo',
    'Polera',
    'Arnés de Seguridad',
    'Cabo de Vida',
    'Zapato de Seguridad',
    'Guante Soldador',
    'Guante Mosquetero',
    'Chaqueta Soldador',
    'Polainas Soldador',
    'Careta Facial',
    'Soporte Careta Facial',
  ];

  // ✅ CORRECCIÓN 2: AGREGAR "Oficina Central"
  final List<String> _todasLasObras = [
    'Oficina Central', // <--- Importante
    'Instalación Residencial Las Condes',
    'Proyecto Industrial Maipú',
    'Mantenimiento Red Eléctrica Centro',
    'Construcción Subestación Norte',
    'Reparación Sistema Alumbrado Sur',
    'Sin asignar',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Más ancho para acomodar checkboxes
      padding: EdgeInsets.all(normalPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            SizedBox(height: normalPadding),
            
            // Tipos de EPP
            _buildCheckboxSection(
              title: 'Tipos de EPP',
              items: _todosLosTipos,
              selectedItems: _tiposSeleccionados,
              onChanged: (item, selected) {
                setState(() {
                  if (selected) {
                    _tiposSeleccionados.add(item);
                  } else {
                    _tiposSeleccionados.remove(item);
                  }
                });
              },
            ),
            
            SizedBox(height: normalPadding),
            
            // Obras Asignadas
            _buildCheckboxSection(
              title: 'Obras Asignadas',
              items: _todasLasObras,
              selectedItems: _obrasSeleccionadas,
              onChanged: (item, selected) {
                setState(() {
                  if (selected) {
                    _obrasSeleccionadas.add(item);
                  } else {
                    _obrasSeleccionadas.remove(item);
                  }
                });
              },
            ),
            
            SizedBox(height: normalPadding),
            
            // Rango de cantidad
            _buildRangeSlider(),
            
            SizedBox(height: normalPadding),
            
            // Certificado
            _buildCertificadoFilter(),
            
            SizedBox(height: normalPadding * 2),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: BorderButton(
                    onPressed: _limpiarFiltros,
                    text: 'Limpiar Todo',
                    size: Size(double.infinity, 40),
                  ),
                ),
                SizedBox(width: normalPadding / 2),
                Expanded(
                  child: PrimaryButton(
                    onPressed: _aplicarFiltros,
                    text: 'Aplicar',
                    size: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: normalPadding),
            
            // Instrucciones para cerrar
            Container(
              padding: EdgeInsets.all(normalPadding / 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para cerrar este panel, haz clic en el boton de filtro',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: normalPadding),
            
            // Resumen de filtros seleccionados
            _buildResumenFiltros(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.filter_alt, color: Colors.blue[700]),
        SizedBox(width: 8),
        Text(
          'Filtros EPP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue[700],
          ),
        ),
        Spacer(),
        if (_hayFiltrosActivos())
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ACTIVOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckboxSection({
    required String title,
    required List<String> items,
    required Set<String> selectedItems,
    required Function(String, bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la sección
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            Spacer(),
            // Seleccionar todos / Deseleccionar todos
            TextButton(
              onPressed: () {
                setState(() {
                  if (selectedItems.length == items.length) {
                    selectedItems.clear();
                  } else {
                    selectedItems.addAll(items);
                  }
                });
              },
              child: Text(
                selectedItems.length == items.length ? 'Deseleccionar todo' : 'Seleccionar todo',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        
        SizedBox(height: normalPadding / 2),
        
        // Container con los checkboxes
        Container(
          padding: EdgeInsets.all(normalPadding / 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            children: items.map((item) => CheckboxListTile(
              title: Text(
                item,
                style: TextStyle(fontSize: 14),
              ),
              value: selectedItems.contains(item),
              onChanged: (bool? value) {
                onChanged(item, value ?? false);
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.blue[600],
            )).toList(),
          ),
        ),
        
        // Contador de seleccionados
        if (selectedItems.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '${selectedItems.length} seleccionado(s)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Cantidad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: normalPadding / 2),
        Container(
          padding: EdgeInsets.all(normalPadding),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              RangeSlider(
                values: _rangoCantidad ?? const RangeValues(1, 100),
                min: 1,
                max: 1000,
                divisions: 20,
                labels: RangeLabels(
                  (_rangoCantidad?.start ?? 1).round().toString(),
                  (_rangoCantidad?.end ?? 100).round().toString(),
                ),
                onChanged: (values) {
                  setState(() => _rangoCantidad = values);
                },
                activeColor: Colors.blue[600],
              ),
              Text(
                'Entre ${(_rangoCantidad?.start ?? 1).round()} y ${(_rangoCantidad?.end ?? 100).round()} unidades',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertificadoFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado de Certificado',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: normalPadding / 2),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              RadioListTile<bool?>(
                title: Text('Todos', style: TextStyle(fontSize: 14)),
                value: null,
                groupValue: _tieneCertificado,
                onChanged: (value) => setState(() => _tieneCertificado = value),
                dense: true,
                activeColor: Colors.blue[600],
              ),
              Divider(height: 1),
              RadioListTile<bool?>(
                title: Text('Con certificado', style: TextStyle(fontSize: 14)),
                value: true,
                groupValue: _tieneCertificado,
                onChanged: (value) => setState(() => _tieneCertificado = value),
                dense: true,
                activeColor: Colors.blue[600],
              ),
              Divider(height: 1),
              RadioListTile<bool?>(
                title: Text('Sin certificado', style: TextStyle(fontSize: 14)),
                value: false,
                groupValue: _tieneCertificado,
                onChanged: (value) => setState(() => _tieneCertificado = value),
                dense: true,
                activeColor: Colors.blue[600],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumenFiltros() {
    if (!_hayFiltrosActivos()) return SizedBox();
    
    return Container(
      padding: EdgeInsets.all(normalPadding),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              SizedBox(width: 4),
              Text(
                'Filtros que se aplicarán:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          
          if (_tiposSeleccionados.isNotEmpty)
            Text(
              '• Tipos: ${_tiposSeleccionados.join(", ")}',
              style: TextStyle(fontSize: 11, color: Colors.blue[700]),
            ),
          
          if (_obrasSeleccionadas.isNotEmpty)
            Text(
              '• Obras: ${_obrasSeleccionadas.join(", ")}',
              style: TextStyle(fontSize: 11, color: Colors.blue[700]),
            ),
          
          if (_rangoCantidad != null)
            Text(
              '• Cantidad: ${_rangoCantidad!.start.round()} - ${_rangoCantidad!.end.round()} unidades',
              style: TextStyle(fontSize: 11, color: Colors.blue[700]),
            ),
          
          if (_tieneCertificado != null)
            Text(
              '• Certificado: ${_tieneCertificado! ? "Con certificado" : "Sin certificado"}',
              style: TextStyle(fontSize: 11, color: Colors.blue[700]),
            ),
        ],
      ),
    );
  }

  bool _hayFiltrosActivos() {
    return _tiposSeleccionados.isNotEmpty ||
           _obrasSeleccionadas.isNotEmpty ||
           _rangoCantidad != null ||
           _tieneCertificado != null;
  }

  void _aplicarFiltros() {
    try {
      final eppProvider = Provider.of<EppProvider>(context, listen: false);
      
      // Aplicar filtros con múltiples valores
      eppProvider.aplicarFiltrosMultiples(
        tipos: _tiposSeleccionados.toList(),
        obras: _obrasSeleccionadas.toList(),
        cantidadMinima: _rangoCantidad?.start.round(),
        cantidadMaxima: _rangoCantidad?.end.round(),
        tieneCertificado: _tieneCertificado,
      );
      
      // NO intentar cerrar el panel - dejarlo abierto
      // El usuario puede cerrarlo haciendo clic fuera
      
      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Filtros aplicados - Haz clic fuera para cerrar el panel'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      print('Error aplicando filtros: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aplicar filtros'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _limpiarFiltros() {
    try {
      setState(() {
        _tiposSeleccionados.clear();
        _obrasSeleccionadas.clear();
        _rangoCantidad = null;
        _tieneCertificado = null;
      });
      
      final eppProvider = Provider.of<EppProvider>(context, listen: false);
      eppProvider.limpiarFiltros();
      
      // Mostrar confirmación sin cerrar el panel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Todos los filtros han sido limpiados'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      
    } catch (e) {
      print('Error limpiando filtros: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al limpiar filtros'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
