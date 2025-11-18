import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/providers/recursos_obra_provider.dart';

class GestionarRecursosView extends StatefulWidget {
  final String? obraId;
  final String? obraNombre;

  const GestionarRecursosView({super.key, this.obraId, this.obraNombre});

  @override
  State<GestionarRecursosView> createState() => _GestionarRecursosViewState();
}

class _GestionarRecursosViewState extends State<GestionarRecursosView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  RecursosObraProvider? _recursosProvider;
  
  // Método seguro para mostrar mensajes
  void _mostrarMensaje(String mensaje, {Duration duracion = const Duration(seconds: 3)}) {
    // Solo intentar mostrar el mensaje si el widget está montado
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              duration: duracion,
            ),
          );
        }
      });
    } else {
      // Solo para depuración
      print('No se pudo mostrar el mensaje porque el widget no está montado: $mensaje');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // SOLUCIÓN: Cargar datos cada vez que cambian las dependencias
    // Esto asegura que siempre tengamos los datos más recientes
    _cargarDatos();
  }

  void _cargarDatos() async {
    if (widget.obraId != null && mounted) {
      print('[_cargarDatos] Iniciando carga de datos para obra ID: ${widget.obraId}');
      setState(() => _isLoading = true);
      
      try {
        // Obtener el provider ya creado en el árbol de widgets
        _recursosProvider = Provider.of<RecursosObraProvider>(context, listen: false);
        
        // Forzar limpieza del caché y recarga completa
        await _recursosProvider!.limpiarCacheRecursosDisponibles();
        
        // Cargar recursos desde cero
        await _recursosProvider!.cargarRecursosObra(widget.obraId!, forceRefresh: true);
        
        print('[_cargarDatos] Datos cargados con éxito. Total recursos: ${_recursosProvider!.recursos.length}');
        print('[_cargarDatos] Vehículos: ${_recursosProvider!.getRecursosPorTipo('vehiculo').length}');
        print('[_cargarDatos] Herramientas: ${_recursosProvider!.getRecursosPorTipo('herramienta').length}');
        print('[_cargarDatos] EPP: ${_recursosProvider!.getRecursosPorTipo('epp').length}');
      } catch (e) {
        print('[_cargarDatos] Error: $e');
        // Mostrar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar recursos: $e'))
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
        ? 'Gestionar Recursos - ${widget.obraNombre}'
        : 'Gestionar Recursos';

    // Mostrar datos para depuración cuando se reconstruye el widget
    if (_recursosProvider != null) {
      print('[build] Reconstruyendo widget de recursos. Estado:');
      print('- Total recursos: ${_recursosProvider!.recursos.length}');
      print('- Vehículos: ${_recursosProvider!.getRecursosPorTipo('vehiculo').length}');
      print('- Herramientas: ${_recursosProvider!.getRecursosPorTipo('herramienta').length}');
      print('- EPP: ${_recursosProvider!.getRecursosPorTipo('epp').length}');
    }

    return PrimaryScaffold(
      title: title,
      body: Consumer<RecursosObraProvider>(
        builder: (context, recursosProvider, _) {
          // Actualiza la referencia al provider para usarla en otros métodos
          _recursosProvider = recursosProvider;
          
          if (recursosProvider.isLoading || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (recursosProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${recursosProvider.error}', textAlign: TextAlign.center),
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
                  Tab(text: 'Vehículos', icon: Icon(Icons.drive_eta)),
                  Tab(text: 'Herramientas', icon: Icon(Icons.handyman)),
                  Tab(text: 'EPP', icon: Icon(Icons.security)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Contenido para la pestaña de vehículos
                    _buildVehiculosTab(recursosProvider),
                    
                    // Contenido para la pestaña de herramientas
                    _buildHerramientasTab(recursosProvider),
                    
                    // Contenido para la pestaña de EPP
                    _buildEppTab(recursosProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVehiculosTab(RecursosObraProvider provider) {
    final vehiculosAsignados = provider.getRecursosPorTipo('vehiculo');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botones principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vehículos asignados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoAsignarRecurso('vehiculo'),
                icon: const Icon(Icons.add),
                label: const Text('Asignar Vehículo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Lista de vehículos asignados
          Expanded(
            child: vehiculosAsignados.isEmpty
                ? const Center(
                    child: Text(
                      'No hay vehículos asignados a esta obra',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    itemCount: vehiculosAsignados.length,
                    itemBuilder: (context, index) {
                      final recurso = vehiculosAsignados[index];
                      final detalles = recurso.detalles;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.drive_eta),
                          ),
                          title: Text(detalles?['patente'] ?? 'Vehículo ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tipo: ${detalles?['tipo'] ?? 'No especificado'}'),
                              Text('Capacidad: ${detalles?['capacidad_kg'] ?? 'N/A'} kg'),
                              Text('Estado: ${recurso.estado}'),
                            ],
                          ),
                          trailing: recurso.estado == 'activo' 
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _retirarRecurso(recurso.id),
                                )
                              : const Icon(Icons.check_circle, color: Colors.grey),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHerramientasTab(RecursosObraProvider provider) {
    final herramientasAsignadas = provider.getRecursosPorTipo('herramienta');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botones principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Herramientas asignadas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoAsignarRecurso('herramienta'),
                icon: const Icon(Icons.add),
                label: const Text('Asignar Herramienta'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Lista de herramientas asignadas
          Expanded(
            child: herramientasAsignadas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay herramientas asignadas a esta obra',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    itemCount: herramientasAsignadas.length,
                    itemBuilder: (context, index) {
                      final recurso = herramientasAsignadas[index];
                      final detalles = recurso.detalles;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.handyman),
                          ),
                          title: Text(detalles?['tipo'] ?? 'Herramienta ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cantidad: ${recurso.cantidad}'),
                              Text('Estado: ${recurso.estado}'),
                              if (recurso.observaciones != null)
                                Text('Observaciones: ${recurso.observaciones}'),
                            ],
                          ),
                          trailing: recurso.estado == 'activo' 
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _retirarRecurso(recurso.id),
                                )
                              : const Icon(Icons.check_circle, color: Colors.grey),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEppTab(RecursosObraProvider provider) {
    final eppAsignados = provider.getRecursosPorTipo('epp');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botones principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'EPP asignados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoAsignarRecurso('epp'),
                icon: const Icon(Icons.add),
                label: const Text('Asignar EPP'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Lista de EPP asignados
          Expanded(
            child: eppAsignados.isEmpty
                ? const Center(
                    child: Text(
                      'No hay EPP asignados a esta obra',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    itemCount: eppAsignados.length,
                    itemBuilder: (context, index) {
                      final recurso = eppAsignados[index];
                      final detalles = recurso.detalles;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.security),
                          ),
                          title: Text(detalles?['tipo'] ?? 'EPP ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cantidad: ${recurso.cantidad}'),
                              Text('Estado: ${recurso.estado}'),
                              if (recurso.observaciones != null)
                                Text('Observaciones: ${recurso.observaciones}'),
                            ],
                          ),
                          trailing: recurso.estado == 'activo' 
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _retirarRecurso(recurso.id),
                                )
                              : const Icon(Icons.check_circle, color: Colors.grey),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Muestra diálogo para asignar un nuevo recurso
  void _mostrarDialogoAsignarRecurso(String tipo) async {
    // Datos para el formulario
    String? recursoId;
    int cantidad = 1;
    String? observaciones;
    List<dynamic> recursosDisponibles = [];
    int? cantidadMaximaDisponible; // Para limitar la cantidad según el recurso seleccionado
    
    try {
      // Mostrar indicador de carga
      setState(() => _isLoading = true);
      
      // Forzar actualización de caché para obtener datos frescos
      await _recursosProvider!.limpiarCacheRecursosDisponibles();
      
      // Obtener los recursos disponibles con actualización forzada
      recursosDisponibles = await _recursosProvider!.cargarRecursosDisponibles(tipo, forceRefresh: true);
      
      // Depuración - Mostrar lo que recibimos
      print('Recursos disponibles (${tipo}): ${recursosDisponibles.length}');
      print('Datos recibidos: $recursosDisponibles');
      
      // Verificar si el widget todavía está montado
      if (!mounted) {
        print('Widget no está montado después de cargar recursos');
        return;
      }
      
      setState(() => _isLoading = false);
      
      if (recursosDisponibles.isEmpty) {
        // Usar una función para mostrar el SnackBar
        _mostrarMensaje(
          'No hay ${tipo}s disponibles para asignar. Asegúrese de que existan ${tipo}s con estado "activo" que no estén asignados a otra obra.',
          duracion: const Duration(seconds: 5),
        );
        return;
      }
    } catch (e) {
      print('ERROR al cargar recursos disponibles: $e');
      // Verificar si el widget todavía está montado
      if (!mounted) {
        print('Widget no está montado después de error');
        return;
      }
      
      setState(() => _isLoading = false);
      
      // Usar una función para mostrar el SnackBar
      _mostrarMensaje('Error al cargar recursos disponibles: $e');
      return;
    }
    
    // Mostrar diálogo para seleccionar el recurso
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Asignar ${_capitalizeFirst(tipo)}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown para seleccionar el recurso
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Selecciona ${tipo}'),
                      hint: const Text('Seleccionar...'),
                      value: recursoId,
                      items: recursosDisponibles.map((recurso) {
                        String label = '';
                        String value = '';
                        
                        switch (tipo) {
                          case 'vehiculo':
                            label = '${recurso['patente']} - ${recurso['tipo']}';
                            value = recurso['id'];
                            break;
                          case 'herramienta':
                            label = '${recurso['tipo']} - Disponible: ${recurso['cantidad_disponible']} unidades';
                            value = recurso['id'];
                            break;
                          case 'epp':
                            label = '${recurso['tipo']} - ${recurso['cantidad']} unidades';
                            value = recurso['id'].toString();
                            break;
                        }
                        
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          recursoId = value;
                          
                          // Actualizar cantidad máxima disponible cuando se selecciona una herramienta
                          if (tipo == 'herramienta' && value != null) {
                            final recursoSeleccionado = recursosDisponibles.firstWhere(
                              (r) => r['id'] == value,
                              orElse: () => null,
                            );
                            if (recursoSeleccionado != null) {
                              cantidadMaximaDisponible = recursoSeleccionado['cantidad_disponible'] as int?;
                              // Resetear cantidad a 1 o al máximo si es menor
                              cantidad = cantidadMaximaDisponible != null && cantidadMaximaDisponible! > 0
                                  ? (cantidadMaximaDisponible! < cantidad ? cantidadMaximaDisponible! : cantidad)
                                  : 1;
                            }
                          }
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo para la cantidad (solo visible para herramientas y EPP)
                    if (tipo != 'vehiculo')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Cantidad',
                              border: OutlineInputBorder(),
                              helperText: tipo == 'herramienta' && cantidadMaximaDisponible != null
                                  ? 'Máximo disponible: $cantidadMaximaDisponible'
                                  : null,
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: '1',
                            onChanged: (value) {
                              final nuevaCantidad = int.tryParse(value) ?? 1;
                              
                              // Validar que no exceda el máximo disponible para herramientas
                              if (tipo == 'herramienta' && cantidadMaximaDisponible != null) {
                                if (nuevaCantidad > cantidadMaximaDisponible!) {
                                  setState(() {
                                    cantidad = cantidadMaximaDisponible!;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('La cantidad no puede ser mayor a $cantidadMaximaDisponible'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  cantidad = nuevaCantidad;
                                }
                              } else {
                                cantidad = nuevaCantidad;
                              }
                            },
                          ),
                        ],
                      ),
                    
                    if (tipo != 'vehiculo')
                      const SizedBox(height: 16),
                    
                    // Campo para observaciones
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Observaciones (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        observaciones = value;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (recursoId == null) {
                  // Mostrar mensaje sin cerrar el diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debes seleccionar un recurso')),
                  );
                  return;
                }
                
                // Validación adicional para herramientas
                if (tipo == 'herramienta' && cantidadMaximaDisponible != null) {
                  if (cantidad > cantidadMaximaDisponible!) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('La cantidad no puede ser mayor a $cantidadMaximaDisponible')),
                    );
                    return;
                  }
                }
                
                // Guardar la información que necesitamos antes de cerrar el diálogo
                final String selectedRecursoId = recursoId!;
                final int selectedCantidad = cantidad;
                final String? selectedObservaciones = observaciones;
                
                // Cerrar el diálogo
                Navigator.pop(context);
                
                // Realizar la asignación en una función separada
                _asignarRecurso(
                  tipo: tipo,
                  recursoId: selectedRecursoId,
                  cantidad: selectedCantidad,
                  observaciones: selectedObservaciones
                );
              },
              child: const Text('Asignar'),
            ),
          ],
        );
      },
    );
  }
  
  // Función para retirar un recurso
  void _retirarRecurso(String id) {
    showDialog(
      context: context,
      builder: (context) {
        String? observaciones;
        
        return AlertDialog(
          title: const Text('Retirar recurso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Estás seguro de que deseas retirar este recurso de la obra?'),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Observaciones sobre el retiro (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  observaciones = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Guardar información necesaria
                final String resourceId = id;
                final String? notes = observaciones;
                
                // Cerrar el diálogo
                Navigator.pop(context);
                
                // Retirar recurso en una función separada
                _procesarRetiroRecurso(resourceId, notes);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retirar'),
            ),
          ],
        );
      },
    );
  }
  
  // Método para procesar el retiro de un recurso
  Future<void> _procesarRetiroRecurso(String id, String? observaciones) async {
    try {
      
      await _recursosProvider!.retirarRecursoObra(id, observaciones: observaciones);
      
      if (mounted) {
        _mostrarMensaje('Recurso retirado correctamente');
      }
      
      if (mounted) {
        
        // Reinicializar el estado del widget
        setState(() {
          _isLoading = true;
          _recursosProvider = null; // Forzar una reinicialización completa
        });
        
        // Esperar un poco para asegurar que la base de datos se actualice
        await Future.delayed(const Duration(seconds: 1));
        
        // Inicializar nuevamente el provider
        if (mounted) {
          _recursosProvider = Provider.of<RecursosObraProvider>(context, listen: false);
          
          // Limpiar cualquier caché
          await _recursosProvider!.limpiarCacheRecursosDisponibles();
          
          // Recargar todo desde cero
          await _recursosProvider!.cargarRecursosObra(widget.obraId!, forceRefresh: true);
          
          // Actualizar la interfaz
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e) {
      print('Error al retirar recurso: $e');
      if (mounted) {
        _mostrarMensaje('Error al retirar recurso: $e');
      }
    }
  }
  
  // Método para asignar un recurso de forma segura
  Future<void> _asignarRecurso({
    required String tipo, 
    required String recursoId,
    required int cantidad,
    String? observaciones
  }) async {
    try {
      
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      // Realizar la asignación usando el método del provider, pero sin depender
      // de sus mecanismos de actualización después
      switch (tipo) {
        case 'vehiculo':
          await _recursosProvider!.asignarNuevoRecurso(
            obraId: widget.obraId!,
            recursoTipo: tipo,
            vehiculoId: recursoId,
            cantidad: cantidad,
            observaciones: observaciones,
          );
          break;
        case 'herramienta':
          await _recursosProvider!.asignarNuevoRecurso(
            obraId: widget.obraId!,
            recursoTipo: tipo,
            herramientaId: recursoId,
            cantidad: cantidad,
            observaciones: observaciones,
          );
          break;
        case 'epp':
          await _recursosProvider!.asignarNuevoRecurso(
            obraId: widget.obraId!,
            recursoTipo: tipo,
            eppId: int.tryParse(recursoId),
            cantidad: cantidad,
            observaciones: observaciones,
          );
          break;
      }
      
      // Mostrar mensaje de éxito
      if (mounted) {
        _mostrarMensaje('${_capitalizeFirst(tipo)} asignado correctamente');
      }
      
      if (mounted) {
        
        // Reinicializar el estado del widget
        setState(() {
          _isLoading = true;
          _recursosProvider = null; // Forzar una reinicialización completa
        });
        
        // Esperar un poco para asegurar que la base de datos se actualice
        await Future.delayed(const Duration(seconds: 1));
        
        // Inicializar nuevamente el provider
        if (mounted) {
          _recursosProvider = Provider.of<RecursosObraProvider>(context, listen: false);
          
          // Limpiar cualquier caché
          await _recursosProvider!.limpiarCacheRecursosDisponibles();
          
          // Recargar todo desde cero
          await _recursosProvider!.cargarRecursosObra(widget.obraId!, forceRefresh: true);
          
          // Actualizar la interfaz
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
      
      // Mostrar mensaje de éxito
      if (mounted) {
        _mostrarMensaje('${_capitalizeFirst(tipo)} asignado correctamente');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error al asignar recurso: $e');
      // Mostrar mensaje de error
      if (mounted) {
        _mostrarMensaje('Error al asignar recurso: $e');
      }
    }
  }
  
  // Método auxiliar para capitalizar la primera letra de un string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}