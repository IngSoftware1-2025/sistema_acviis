import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/epp.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';

class AsignarEppView extends StatefulWidget {
  final EPP epp;

  const AsignarEppView({
    super.key,
    required this.epp,
  });

  @override
  State<AsignarEppView> createState() => _AsignarEppViewState();
}

class _AsignarEppViewState extends State<AsignarEppView> {
  List<String> _obrasSeleccionadas = [];
  
  // Lista de obras disponibles (esto debería venir de un provider/API en el futuro)
  final List<String> _obrasDisponibles = [
    'Instalación Residencial Las Condes',
    'Proyecto Industrial Maipú',
    'Mantenimiento Red Eléctrica Centro',
    'Construcción Subestación Norte',
    'Reparación Sistema Alumbrado Sur',
    'Instalación Comercial Providencia',
    'Proyecto Habitacional San Miguel',
    'Mantenimiento Planta Solar',
    'Instalación Hospital El Salvador',
    'Proyecto Metro Línea 8',
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar con las obras ya asignadas
    _obrasSeleccionadas = List.from(widget.epp.obrasAsignadas);
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Asignar EPP a Obras',
      body: Consumer<EppProvider>(
        builder: (context, eppProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(normalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del EPP
                _buildEppInfo(),
                
                SizedBox(height: normalPadding * 2),
                
                // Estado actual de asignaciones
                _buildEstadoActual(),
                
                SizedBox(height: normalPadding * 2),
                
                // Sección de selección de obras
                _buildSeccionObras(),
                
                SizedBox(height: normalPadding * 3),
                
                // Botones de acción
                _buildActionButtons(eppProvider),
                
                SizedBox(height: normalPadding),
                
                // Mostrar error si existe
                if (eppProvider.error != null)
                  _buildErrorMessage(eppProvider.error!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEppInfo() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(normalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.blue[700], size: 28),
                SizedBox(width: normalPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.epp.tipo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        'ID: ${widget.epp.id} | Cantidad: ${widget.epp.cantidad} unidades',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoActual() {
    final tieneObras = widget.epp.obrasAsignadas.isNotEmpty;
    
    return Card(
      color: tieneObras ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(normalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  tieneObras ? Icons.assignment_turned_in : Icons.assignment_late,
                  color: tieneObras ? Colors.green[700] : Colors.orange[700],
                  size: 24,
                ),
                SizedBox(width: normalPadding / 2),
                Text(
                  'Asignaciones Actuales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: tieneObras ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: normalPadding / 2),
            if (tieneObras) ...[
              Text(
                'Este EPP está asignado a ${widget.epp.obrasAsignadas.length} obra(s):',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: normalPadding / 2),
              ...widget.epp.obrasAsignadas.map((obra) => Padding(
                padding: EdgeInsets.only(left: normalPadding, bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.fiber_manual_record, size: 8, color: Colors.green[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        obra,
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ] else ...[
              Text(
                'Este EPP no está asignado a ninguna obra específica',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionObras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asignar a Obras',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarker,
          ),
        ),
        SizedBox(height: normalPadding),
        
        Text(
          'Selecciona las obras donde se utilizará este EPP:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: normalPadding),
        
        // Lista de obras con checkboxes
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Opción "Sin asignar"
              CheckboxListTile(
                title: Text(
                  'Sin asignar a obra específica',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'EPP disponible para cualquier obra',
                  style: TextStyle(color: Colors.orange[600], fontSize: 12),
                ),
                value: _obrasSeleccionadas.isEmpty,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _obrasSeleccionadas.clear();
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.orange,
              ),
              
              Divider(height: 1, color: Colors.grey[300]),
              
              // Lista de obras específicas
              ...(_obrasDisponibles.map((obra) {
                final isSelected = _obrasSeleccionadas.contains(obra);
                return CheckboxListTile(
                  title: Text(obra),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _obrasSeleccionadas.add(obra);
                      } else {
                        _obrasSeleccionadas.remove(obra);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                );
              }).toList()),
            ],
          ),
        ),
        
        SizedBox(height: normalPadding),
        
        // Resumen de selección
        if (_obrasSeleccionadas.isNotEmpty) ...[
          Container(
            width: double.infinity,
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
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    SizedBox(width: normalPadding / 2),
                    Text(
                      'Resumen de asignación:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: normalPadding / 2),
                Text(
                  'Este EPP será asignado a ${_obrasSeleccionadas.length} obra(s) seleccionada(s).',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(EppProvider eppProvider) {
    final hasChanges = !_listEquals(_obrasSeleccionadas, widget.epp.obrasAsignadas);
    final canSave = hasChanges && !eppProvider.isLoading;
    
    return Row(
      children: [
        Expanded(
          child: BorderButton(
            onPressed: () {
              if (!eppProvider.isLoading) {
                Navigator.pop(context);
              }
            },
            text: 'Cancelar',
            size: Size(double.infinity, 50),
          ),
        ),
        SizedBox(width: normalPadding),
        Expanded(
          flex: 2,
          child: PrimaryButton(
            onPressed: () {
              if (canSave) {
                _guardarAsignacion(eppProvider);
              }
            },
            text: eppProvider.isLoading 
              ? 'Guardando...' 
              : hasChanges 
                ? 'Guardar Asignación'
                : 'Sin cambios',
            size: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(normalPadding),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          SizedBox(width: normalPadding / 2),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarAsignacion(EppProvider eppProvider) async {
    try {
      final success = await eppProvider.modificarEPP(
        id: widget.epp.id!,
        tipo: widget.epp.tipo,
        obrasAsignadas: _obrasSeleccionadas,
        cantidad: widget.epp.cantidad,
      );

      if (success) {
        await eppProvider.fetchEpps();
        
        final message = _obrasSeleccionadas.isEmpty 
          ? 'EPP desasignado de todas las obras'
          : 'EPP asignado a ${_obrasSeleccionadas.length} obra(s) exitosamente';
          
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar asignación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    
    // Crear copias ordenadas para comparar
    final sorted1 = List<String>.from(list1)..sort();
    final sorted2 = List<String>.from(list2)..sort();
    
    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i] != sorted2[i]) return false;
    }
    
    return true;
  }
}