import 'package:flutter/material.dart';

class ProveedorFiltrosDisplay extends StatelessWidget {
  final TextEditingController rutController;
  final TextEditingController nombreController;
  final TextEditingController productoController;
  final TextEditingController creditoMinController;
  final TextEditingController creditoMaxController;
  final VoidCallback onFilter;
  final VoidCallback onClear;

  const ProveedorFiltrosDisplay({
    super.key,
    required this.rutController,
    required this.nombreController,
    required this.productoController,
    required this.creditoMinController,
    required this.creditoMaxController,
    required this.onFilter,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            controller: rutController,
            decoration: const InputDecoration(labelText: 'RUT'),
            onChanged: (_) => onFilter(),
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: nombreController,
            decoration: const InputDecoration(labelText: 'Nombre vendedor'),
            onChanged: (_) => onFilter(),
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: productoController,
            decoration: const InputDecoration(labelText: 'Producto/Servicio'),
            onChanged: (_) => onFilter(),
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: creditoMinController,
            decoration: const InputDecoration(labelText: 'Crédito min'),
            keyboardType: TextInputType.number,
            onChanged: (_) => onFilter(),
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: creditoMaxController,
            decoration: const InputDecoration(labelText: 'Crédito max'),
            keyboardType: TextInputType.number,
            onChanged: (_) => onFilter(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: onFilter, child: const Text('Filtrar')),
            TextButton(onPressed: onClear, child: const Text('Limpiar')),
          ],
        )
      ],
    );
  }
}