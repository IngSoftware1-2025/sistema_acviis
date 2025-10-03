import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';


class OrdenesSearchBar extends StatefulWidget {
  const OrdenesSearchBar({
    super.key
  });

  @override
  State<OrdenesSearchBar> createState() => _OrdenesSearchBarState();
}

class _OrdenesSearchBarState extends State<OrdenesSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrdenesProvider>(context, listen: false);

    return SizedBox(
      height: normalPadding * 2.5,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Buscar orden...',
          contentPadding: EdgeInsets.symmetric(horizontal: normalPadding),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          provider.actualizarFiltros(textoBusqueda: value);
        },
      ),
    );
  }
}