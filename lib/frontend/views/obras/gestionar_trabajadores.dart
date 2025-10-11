import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/obras_provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/models/trabajador.dart';

class GestionarTrabajadoresView extends StatefulWidget {
  const GestionarTrabajadoresView({super.key});

  @override
  State<GestionarTrabajadoresView> createState() => _GestionarTrabajadoresViewState();
}

class _GestionarTrabajadoresViewState extends State<GestionarTrabajadoresView> {
  String? obraId;
  String? obraNombre;
  List<String> trabajadoresAsignados = [];
  bool isLoading = false;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    // Cargar los datos cuando la vista se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      
      try {
        // Obtener los argumentos de la ruta
        final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
        obraId = args['obraId'];
        obraNombre = args['obraNombre'];
        
        if (obraId != null) {
          print('Cargando datos para la obra: $obraId ($obraNombre)');
          
          // Cargar todos los trabajadores
          final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context, listen: false);
          await trabajadoresProvider.fetchTrabajadores();
          
          // Cargar los trabajadores asignados a la obra
          final obrasProvider = Provider.of<ObrasProvider>(context, listen: false);
          final trabajadores = await obrasProvider.getTrabajadoresDeObra(obraId!);
          
          // Actualizamos la lista de IDs de trabajadores asignados
          setState(() {
            trabajadoresAsignados = trabajadores.map((t) => t.id).toList();
            print('Trabajadores asignados: ${trabajadoresAsignados.length}');
          });
        } else {
          print('Error: No se proporcionó un ID de obra');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se proporcionó un ID de obra')),
          );
        }
      } catch (e) {
        print('Error al cargar datos: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener los argumentos pasados a esta ruta
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    obraId = args['obraId'];
    obraNombre = args['obraNombre'];
    
    final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context);
    final obrasProvider = Provider.of<ObrasProvider>(context);
    
    // Filtrar los trabajadores según el texto de búsqueda y el estado
    // Excluir los trabajadores con estado "Despedido" y los que ya están asignados
    final trabajadoresDisponibles = trabajadoresProvider.trabajadores
        .where((t) => 
            // No incluir trabajadores despedidos
            t.estado.toLowerCase() != 'despedido' &&
            // No incluir trabajadores ya asignados
            !trabajadoresAsignados.contains(t.id) &&
            // Filtrar por texto de búsqueda
            (t.nombreCompleto.toLowerCase().contains(_searchText.toLowerCase()) ||
             t.rut.toLowerCase().contains(_searchText.toLowerCase())))
        .toList();
    
    // Obtener los trabajadores asignados usando los IDs almacenados
    // Esta lista se usará más adelante para mostrar los trabajadores asignados
    final trabajadoresAsignadosCompletos = trabajadoresProvider.trabajadores
        .where((t) => trabajadoresAsignados.contains(t.id))
        .toList();

    return PrimaryScaffold(
      title: 'Gestionar trabajadores de obra${obraNombre != null ? ": $obraNombre" : ""}',
      body: isLoading || trabajadoresProvider.isLoading || obrasProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Asigna trabajadores a esta obra',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                
                // Búsqueda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar trabajador por nombre o RUT',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sección de trabajadores disponibles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trabajadores disponibles',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: trabajadoresDisponibles.isEmpty
                            ? Center(child: Text('No hay trabajadores disponibles'))
                            : ListView.builder(
                                itemCount: trabajadoresDisponibles.length,
                                itemBuilder: (context, index) {
                                  final trabajador = trabajadoresDisponibles[index];
                                  return _buildTrabajadorCard(
                                    trabajador: trabajador,
                                    isAssigned: false,
                                    onToggle: () async {
                                      if (obraId != null) {
                                        setState(() => isLoading = true);
                                        
                                        try {
                                          // Asignar el trabajador a la obra usando el provider
                                          final success = await obrasProvider.asignarTrabajadorAObra(
                                            obraId!,
                                            trabajador.id,
                                            rolEnObra: trabajador.rolQueAsumeEnLaObra.isNotEmpty 
                                                ? trabajador.rolQueAsumeEnLaObra 
                                                : null,
                                          );
                                          
                                          if (success) {
                                            setState(() {
                                              trabajadoresAsignados.add(trabajador.id);
                                            });
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${trabajador.nombreCompleto} asignado a la obra')),
                                            );
                                          }
                                        } catch (e) {
                                          print('Error al asignar trabajador: $e');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al asignar trabajador: $e')),
                                          );
                                        } finally {
                                          setState(() => isLoading = false);
                                        }
                                      }
                                    }
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(thickness: 1),
                
                // Sección de trabajadores asignados a la obra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Trabajadores asignados a la obra',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: trabajadoresAsignados.isEmpty
                          ? Center(child: Text('No hay trabajadores asignados a esta obra'))
                          : ListView.builder(
                              itemCount: trabajadoresAsignadosCompletos.length,
                              itemBuilder: (context, index) {
                                final trabajador = trabajadoresAsignadosCompletos[index];
                                return _buildTrabajadorCard(
                                  trabajador: trabajador,
                                  isAssigned: true,
                                  onToggle: () async {
                                    if (obraId != null) {
                                      setState(() => isLoading = true);
                                      
                                      try {
                                        // Quitar el trabajador de la obra
                                        final success = await obrasProvider.quitarTrabajadorDeObra(
                                          obraId!,
                                          trabajador.id,
                                        );
                                        
                                        if (success) {
                                          setState(() {
                                            trabajadoresAsignados.remove(trabajador.id);
                                          });
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${trabajador.nombreCompleto} removido de la obra')),
                                          );
                                        }
                                      } catch (e) {
                                        print('Error al quitar trabajador: $e');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al quitar trabajador: $e')),
                                        );
                                      } finally {
                                        setState(() => isLoading = false);
                                      }
                                    }
                                  }
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Botón para guardar cambios (opcional)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PrimaryButton(
                    text: 'Volver',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    size: Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildTrabajadorCard({
    required Trabajador trabajador,
    required bool isAssigned,
    required VoidCallback onToggle,
  }) {
    // Determinamos si el trabajador tiene un rol asignado
    final bool tieneRol = trabajador.rolQueAsumeEnLaObra.isNotEmpty;
    
    // Iniciales para el avatar
    final String iniciales = trabajador.nombreCompleto.isNotEmpty 
        ? trabajador.nombreCompleto.split(' ').map((name) => name.isNotEmpty ? name[0] : '').join('').toUpperCase()
        : '?';
        
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(
            iniciales.length > 2 ? iniciales.substring(0, 2) : iniciales,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarker,
            ),
          ),
        ),
        title: Text(
          trabajador.nombreCompleto,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RUT: ${trabajador.rut}',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
            if (tieneRol) 
              Text(
                'Rol: ${trabajador.rolQueAsumeEnLaObra}',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: AppColors.primaryDarker,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isAssigned ? Icons.remove_circle_outline : Icons.add_circle_outline,
            color: isAssigned ? AppColors.error : AppColors.success,
          ),
          onPressed: onToggle,
          tooltip: isAssigned ? 'Quitar de la obra' : 'Asignar a la obra',
        ),
      ),
    );
  }
}