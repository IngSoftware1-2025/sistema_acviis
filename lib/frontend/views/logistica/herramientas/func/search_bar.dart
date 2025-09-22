import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/herramientas_provider.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';


class HerramientasSearchBar extends StatefulWidget {
  const HerramientasSearchBar({
    super.key
  });

  @override
  State<HerramientasSearchBar> createState() => _HerramientasSearchBarState();
}

class _HerramientasSearchBarState extends State<HerramientasSearchBar> {
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
    final provider = Provider.of<HerramientasProvider>(context, listen: false);

    return SizedBox(
      height: normalPadding * 2.5,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Buscar herramienta por nombre...',
          contentPadding: EdgeInsets.symmetric(horizontal: normalPadding),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          provider.actualizarBusqueda(value);
        },
      ),
    );
  }
}