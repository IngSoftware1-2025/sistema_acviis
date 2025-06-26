import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';

class TrabajadoresSearchBar extends StatefulWidget {
  const TrabajadoresSearchBar({
    super.key
  });

  @override
  State<TrabajadoresSearchBar> createState() => _TrabajadoresSearchBarState();
}

class _TrabajadoresSearchBarState extends State<TrabajadoresSearchBar> {
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
    final provider = Provider.of<TrabajadoresProvider>(context, listen: false);

    return SizedBox(
      height: normalPadding * 2.5,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Buscar trabajador por nombre...',
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