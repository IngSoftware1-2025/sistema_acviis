import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/finanzas/utils/lista_facturas.dart';
import 'package:sistema_acviis/frontend/views/finanzas/Dialogs/agregar_factura.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';

class FacturasView extends StatelessWidget {
  const FacturasView({super.key});
  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Facturas',
      body: Column(
        children: [
          Row(),
          PrimaryButton(
            text: 'Agregar Factura',
            onPressed: () async {
              final resultado = await showDialog(
                context: context,
                builder: (context) => AgregarFacturaDialog(),
              );
              if (resultado == true) {
                // Puedes refrescar la lista de facturas aquí si lo necesitas
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Factura agregada correctamente')),
                );
              }
            },
          ),
          Padding(
          padding: EdgeInsets.symmetric(vertical: normalPadding),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 10,
            color: Colors.black,
          ),
          ),
        ),
          Expanded(child: ListaFacturas()),
        ],
      ),
    );
  }
}