import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';

class EppSearchBar extends StatefulWidget {
  const EppSearchBar({super.key});

  @override
  State<EppSearchBar> createState() => _EppSearchBarState();
}

class _EppSearchBarState extends State<EppSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar búsqueda actual del provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eppProvider = Provider.of<EppProvider>(context, listen: false);
      _searchController.text = eppProvider.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EppProvider>(
      builder: (context, eppProvider, child) {
        return TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar EPP por tipo o obra...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de búsqueda activa
                if (eppProvider.searchQuery.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(right: 4),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'BÚSQUEDA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Botón limpiar
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            filled: true,
            fillColor: eppProvider.searchQuery.isNotEmpty 
                ? Colors.blue[50] 
                : Colors.grey[100],
          ),
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchChanged,
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    final eppProvider = Provider.of<EppProvider>(context, listen: false);
    eppProvider.buscarEpps(query);
    
    // Actualizar el estado para mostrar/ocultar botón clear
    setState(() {});
  }
}