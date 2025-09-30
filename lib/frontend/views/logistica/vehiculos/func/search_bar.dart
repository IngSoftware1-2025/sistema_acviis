import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/vehiculos_provider.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';


class VehiculosSearchBar extends StatefulWidget {
  const VehiculosSearchBar({
    super.key
  });

  @override
  State<VehiculosSearchBar> createState() => _VehiculosSearchBarState();
}

class _VehiculosSearchBarState extends State<VehiculosSearchBar> {
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
    final provider = Provider.of<VehiculosProvider>(context, listen: false);

    return SizedBox(
      height: normalPadding * 2.5,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Buscar vehículo por patente...',
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