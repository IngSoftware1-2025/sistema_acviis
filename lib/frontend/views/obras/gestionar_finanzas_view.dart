import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/backend/controllers/obra_finanzas/crear_caja_chica.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/providers/finanzas_obra_provider.dart';
import 'package:intl/intl.dart';

class GestionarFinanzasView extends StatefulWidget {
  final String? obraId;
  final String? obraNombre;

  const GestionarFinanzasView({super.key, this.obraId, this.obraNombre});

  @override
  State<GestionarFinanzasView> createState() => _GestionarFinanzasViewState();
}

class _GestionarFinanzasViewState extends State<GestionarFinanzasView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  FinanzasObraProvider? _finanzasProvider;
  
  final formatoMoneda = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);
  
  void _mostrarMensaje(String mensaje, {Duration duracion = const Duration(seconds: 3)}) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensaje), duration: duracion),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarDatos();
  }

  void _cargarDatos() async {
    if (widget.obraId != null && mounted) {
      setState(() => _isLoading = true);
      
      try {
        _finanzasProvider = Provider.of<FinanzasObraProvider>(context, listen: false);
        await _finanzasProvider!.limpiarCacheFinanzasDisponibles();
        await _finanzasProvider!.cargarFinanzasObra(widget.obraId!, forceRefresh: true);
      } catch (e) {
        print('[_cargarDatos] Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar finanzas: $e'))
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.obraNombre != null 
        ? 'Gestionar Finanzas - ${widget.obraNombre}'
        : 'Gestionar Finanzas';

    return PrimaryScaffold(
      title: title,
      body: Consumer<FinanzasObraProvider>(
        builder: (context, finanzasProvider, _) {
          _finanzasProvider = finanzasProvider;
          
          if (finanzasProvider.isLoading || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (finanzasProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${finanzasProvider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarDatos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryDarker,
                unselectedLabelColor: AppColors.textPrimary,
                indicatorSize: TabBarIndicatorSize.label, 
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primaryDarker,
                      width: 3.0,
                    ),
                  ),
                ),
                tabs: const [
                  Tab(text: 'Caja Chica', icon: Icon(Icons.local_atm)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCajaChicaTab(finanzasProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCajaChicaTab(FinanzasObraProvider provider) {
    final cajasChicas = provider.cajasChicasActivas;
    final cajaChica = cajasChicas.isNotEmpty ? cajasChicas.first : null;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: cajaChica == null
          ? _buildNoCajaChica()
          : _buildCajaChicaDetalle(cajaChica),
    );
  }

  Widget _buildNoCajaChica() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_atm, size: 120, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No hay caja chica activa',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Esta obra no tiene una caja chica activa.\nCrea una para gestionar los gastos menores.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _mostrarDialogoCrearCajaChica,
            icon: const Icon(Icons.add, size: 28),
            label: const Text('Crear Caja Chica', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarker,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCajaChicaDetalle(dynamic caja) {
    // Calcular situaciones problemáticas
    final utilizadoExcedeAsignado = caja.montoTotalUtilizado > caja.montoTotalAsignado;
    final excedenteUtilizado = utilizadoExcedeAsignado ? caja.montoTotalUtilizado - caja.montoTotalAsignado : 0;
    
    final pagadoExcedeUtilizado = caja.montoUtilizadoResuelto > caja.montoTotalUtilizado;
    final pagadoExcedeAsignado = caja.montoUtilizadoResuelto > caja.montoTotalAsignado;
    final excedentePagadoVsUtilizado = pagadoExcedeUtilizado ? caja.montoUtilizadoResuelto - caja.montoTotalUtilizado : 0;
    final excedentePagadoVsAsignado = pagadoExcedeAsignado ? caja.montoUtilizadoResuelto - caja.montoTotalAsignado : 0;
    
    // Solo hay problema si pagado excede utilizado Y además pagado supera el asignado
    final hayProblemaExcesoPago = pagadoExcedeUtilizado && pagadoExcedeAsignado;
    
    final hayProblemas = utilizadoExcedeAsignado || hayProblemaExcesoPago;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header con acciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Caja Chica Activa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _mostrarDialogoModificarCajaChica(caja),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modificar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDarker,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _cerrarCajaChica(caja.id),
                    icon: const Icon(Icons.close),
                    label: const Text('Cerrar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bloque de problemas
          if (hayProblemas) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[300]!, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Problemas Detectados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Problema: Utilizado excede asignado
                  if (utilizadoExcedeAsignado) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.report_problem, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monto utilizado excede el monto asignado',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Excedente: ${formatoMoneda.format(excedenteUtilizado)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!hayProblemaExcesoPago) ...[
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Solución: Debe pagarse ${formatoMoneda.format(excedenteUtilizado)} o encargado debe devolver ${formatoMoneda.format(excedenteUtilizado)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (hayProblemaExcesoPago) const SizedBox(height: 16),
                  ],
                  
                  // Problema: Pago excede utilizado (solo si también excede asignado)
                  if (hayProblemaExcesoPago) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.report_problem, color: Colors.red[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monto pagado excede el monto total utilizado',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• Por monto asignado: ${formatoMoneda.format(excedentePagadoVsAsignado)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '• Por monto utilizado: ${formatoMoneda.format(excedentePagadoVsUtilizado)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Solución: Encargado debe devolver ${formatoMoneda.format(excedentePagadoVsUtilizado)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Card principal con información
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Propósito
                  Row(
                    children: [
                      Icon(Icons.local_atm, size: 32, color: AppColors.primaryDarker),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Propósito',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              caja.proposito,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Creada el ${DateFormat('dd/MM/yyyy').format(caja.fechaAsignacion)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Progreso visual
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Utilización del fondo',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${caja.porcentajeUtilizado.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getColorPorcentaje(caja.porcentajeUtilizado),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: caja.porcentajeUtilizado / 100,
                          minHeight: 16,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorPorcentaje(caja.porcentajeUtilizado),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Detalles de montos
                  _buildMontoCard(
                    'Monto Total Asignado',
                    caja.montoTotalAsignado,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildMontoCard(
                    'Monto Disponible',
                    caja.montoDisponible,
                    Colors.green,
                    isBold: true,
                  ),
                  const SizedBox(height: 24),

                  const Divider(thickness: 2),
                  const SizedBox(height: 24),

                  // Sección de montos utilizados
                  const Text(
                    'Desglose de Utilización',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMontoCard(
                    'Total Utilizado',
                    caja.montoTotalUtilizado,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Column(
                      children: [
                        _buildMontoCard(
                          'Sin Pagar',
                          caja.montoUtilizadoImpago,
                          Colors.red,
                          isSmall: true,
                        ),
                        const SizedBox(height: 12),
                        _buildMontoCard(
                          'Pagado/Resuelto',
                          caja.montoUtilizadoResuelto,
                          Colors.green,
                          isSmall: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontoCard(
    String label,
    double monto,
    Color color, {
    bool isBold = false,
    bool isSmall = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            formatoMoneda.format(monto),
            style: TextStyle(
              fontSize: isSmall ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorPorcentaje(double porcentaje) {
    if (porcentaje < 50) return Colors.green;
    if (porcentaje < 80) return Colors.orange;
    return Colors.red;
  }

  void _mostrarDialogoCrearCajaChica() {
    final propositoController = TextEditingController();
    final montoController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.local_atm, color: AppColors.primaryDarker),
              SizedBox(width: 12),
              Text('Crear Nueva Caja Chica'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: propositoController,
                    decoration: const InputDecoration(
                      labelText: 'Propósito del fondo *',
                      hintText: 'Ej: Gastos menores obra central',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El propósito es obligatorio';
                      }
                      if (value.trim().length < 10) {
                        return 'El propósito debe tener al menos 10 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: montoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto total asignado *',
                      hintText: 'Ej: 500000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monetization_on),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El monto es obligatorio';
                      }
                      final monto = double.tryParse(value);
                      if (monto == null || monto <= 0) {
                        return 'Ingrese un monto válido mayor a 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'La caja chica se creará con los montos utilizados en \$0.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final proposito = propositoController.text.trim();
                  final monto = double.parse(montoController.text);
                  
                  Navigator.pop(context);
                  await _crearCajaChica(proposito, monto);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarker,
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoModificarCajaChica(dynamic caja) {
    final montoAsignadoController = TextEditingController(
      text: caja.montoTotalAsignado.toStringAsFixed(0),
    );
    final montoUtilizadoController = TextEditingController(
      text: caja.montoTotalUtilizado.toStringAsFixed(0),
    );
    final montoResueltoController = TextEditingController(
      text: caja.montoUtilizadoResuelto.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Variable para mostrar el cálculo automático
        double montoImpagoCalculado = caja.montoTotalUtilizado - caja.montoUtilizadoResuelto;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Función para recalcular el monto sin pagar
            void recalcularImpago() {
              final utilizado = double.tryParse(montoUtilizadoController.text) ?? 0;
              final resuelto = double.tryParse(montoResueltoController.text) ?? 0;
              setDialogState(() {
                montoImpagoCalculado = utilizado - resuelto;
              });
            }
            
            // Calcular problemas
            final montoAsignado = double.tryParse(montoAsignadoController.text) ?? 0;
            final montoUtilizado = double.tryParse(montoUtilizadoController.text) ?? 0;
            final montoResuelto = double.tryParse(montoResueltoController.text) ?? 0;
            
            final utilizadoExcedeAsignado = montoUtilizado > montoAsignado;
            final excedenteUtilizado = utilizadoExcedeAsignado ? montoUtilizado - montoAsignado : 0;
            
            final pagadoExcedeUtilizado = montoResuelto > montoUtilizado;
            final pagadoExcedeAsignado = montoResuelto > montoAsignado;
            final excedentePagadoVsUtilizado = pagadoExcedeUtilizado ? montoResuelto - montoUtilizado : 0;
            final excedentePagadoVsAsignado = pagadoExcedeAsignado ? montoResuelto - montoAsignado : 0;
            
            // Solo hay problema si pagado excede utilizado Y además pagado supera el asignado
            final hayProblemaExcesoPago = pagadoExcedeUtilizado && pagadoExcedeAsignado;
            
            final hayProblemas = utilizadoExcedeAsignado || hayProblemaExcesoPago;
            
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primaryDarker),
                  SizedBox(width: 12),
                  Text('Modificar Caja Chica'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caja.proposito,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Monto asignado (solo lectura)
                      TextFormField(
                        controller: montoAsignadoController,
                        decoration: const InputDecoration(
                          labelText: 'Monto Total Asignado',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monetization_on),
                          prefixText: '\$ ',
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                        ),
                        enabled: false,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'El monto asignado no se puede modificar',
                                style: TextStyle(fontSize: 11, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Actualizar Utilización',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      
                      // Monto total utilizado (editable - SIN BLOQUEOS)
                      TextFormField(
                        controller: montoUtilizadoController,
                        decoration: const InputDecoration(
                          labelText: 'Monto Total Utilizado *',
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                          helperText: 'Total gastado de la caja chica',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => recalcularImpago(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Monto resuelto (editable - SIN BLOQUEOS)
                      TextFormField(
                        controller: montoResueltoController,
                        decoration: const InputDecoration(
                          labelText: 'Monto Pagado/Resuelto *',
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                          helperText: 'Gastos que ya fueron pagados',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => recalcularImpago(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Bloque de problemas
                      if (hayProblemas) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[700], size: 22),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Problemas Detectados',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Problema: Utilizado excede asignado
                              if (utilizadoExcedeAsignado) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.report_problem, color: Colors.orange[700], size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Monto utilizado excede el monto asignado',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange[900],
                                            ),
                                          ),
                                          Text(
                                            'Excedente: ${formatoMoneda.format(excedenteUtilizado)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.orange[800],
                                            ),
                                          ),
                                          if (!hayProblemaExcesoPago) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.blue[200]!),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 14),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      'Solución: Debe pagarse ${formatoMoneda.format(excedenteUtilizado)} o encargado debe devolver ${formatoMoneda.format(excedenteUtilizado)}',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.blue[900],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (hayProblemaExcesoPago) const SizedBox(height: 12),
                              ],
                              
                              // Problema: Pago excede utilizado (solo si también excede asignado)
                              if (hayProblemaExcesoPago) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.report_problem, color: Colors.red[700], size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Monto pagado excede el monto total utilizado',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[900],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '• Por monto asignado: ${formatoMoneda.format(excedentePagadoVsAsignado)}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.red[800],
                                                  ),
                                                ),
                                                Text(
                                                  '• Por monto utilizado: ${formatoMoneda.format(excedentePagadoVsUtilizado)}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.red[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.blue[200]!),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 14),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Solución: Encargado debe devolver ${formatoMoneda.format(excedentePagadoVsUtilizado)}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.blue[900],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Monto sin pagar (calculado automáticamente)
                      if (montoImpagoCalculado >= 0) ...[
                        Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: montoImpagoCalculado > 0 
                              ? Colors.red[50] 
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: montoImpagoCalculado > 0 
                                ? Colors.red[200]! 
                                : Colors.green[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              montoImpagoCalculado > 0 
                                  ? Icons.schedule 
                                  : Icons.check_circle_outline,
                              color: montoImpagoCalculado > 0 
                                  ? Colors.red 
                                  : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Monto Sin Pagar (Calculado)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatoMoneda.format(montoImpagoCalculado),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: montoImpagoCalculado > 0 
                                          ? Colors.red 
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ],
                      
                      // Ayuda visual
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Cálculo automático:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sin Pagar = Total Utilizado - Pagado/Resuelto',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[800],
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              '${formatoMoneda.format(montoImpagoCalculado)} = ${formatoMoneda.format(double.tryParse(montoUtilizadoController.text) ?? 0)} - ${formatoMoneda.format(double.tryParse(montoResueltoController.text) ?? 0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final montoAsignado = double.parse(montoAsignadoController.text);
                      final montoUtilizado = double.parse(montoUtilizadoController.text);
                      final montoResuelto = double.parse(montoResueltoController.text);
                      final montoImpago = montoUtilizado - montoResuelto;
                      
                      // SIN VALIDACIONES QUE BLOQUEEN
                      
                      Navigator.pop(dialogContext);
                      await _modificarCajaChica(
                        caja.id,
                        montoAsignado,
                        montoUtilizado,
                        montoImpago,
                        montoResuelto,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarker,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Cambios'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _crearCajaChica(String proposito, double monto) async {
    try {
      setState(() => _isLoading = true);
      
      await _finanzasProvider!.crearCajaChica(
        obraId: widget.obraId!,
        proposito: proposito,
        montoTotalAsignado: monto,
      );
      
      if (mounted) {
        _mostrarMensaje('Caja chica creada correctamente');
        await _finanzasProvider!.cargarFinanzasObra(widget.obraId!, forceRefresh: true);
      }
    } catch (e) {
      print('Error al crear caja chica: $e');
      if (mounted) {
        _mostrarMensaje('Error al crear caja chica: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _modificarCajaChica(
    String id,
    double montoAsignado,
    double montoUtilizado,
    double montoImpago,
    double montoResuelto,
  ) async {
    try {
      setState(() => _isLoading = true);
      
      // TODO: Implementar el método modificarCajaChica en el provider
      await _finanzasProvider!.modificarCajaChica(
        id: id,
        montoTotalAsignado: montoAsignado,
        montoTotalUtilizado: montoUtilizado,
        montoUtilizadoImpago: montoImpago,
        montoUtilizadoResuelto: montoResuelto,
      );
      
      if (mounted) {
        _mostrarMensaje('Caja chica modificada correctamente');
        await _finanzasProvider!.cargarFinanzasObra(widget.obraId!, forceRefresh: true);
      }
    } catch (e) {
      print('Error al modificar caja chica: $e');
      if (mounted) {
        _mostrarMensaje('Error al modificar caja chica: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _cerrarCajaChica(String id) {
    showDialog(
      context: context,
      builder: (context) {
        final observacionesController = TextEditingController();
        
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 12),
              Text('Cerrar Caja Chica'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Estás seguro de que deseas cerrar esta caja chica?\n\nEsta acción no se puede deshacer.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones del cierre (opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Cierre por fin de proyecto',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final observaciones = observacionesController.text.trim();
                Navigator.pop(context);
                await _procesarCierreCajaChica(id, observaciones.isEmpty ? null : observaciones);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Caja Chica'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _procesarCierreCajaChica(String id, String? observaciones) async {
    try {
      setState(() => _isLoading = true);
      
      await _finanzasProvider!.cerrarCajaChica(id, observaciones: observaciones);
      
      if (mounted) {
        _mostrarMensaje('Caja chica cerrada correctamente');
        await _finanzasProvider!.cargarFinanzasObra(widget.obraId!, forceRefresh: true);
      }
    } catch (e) {
      print('Error al cerrar caja chica: $e');
      if (mounted) {
        _mostrarMensaje('Error al cerrar caja chica: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}