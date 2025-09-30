import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/finanzas/utils/lista_facturas.dart';
import 'package:sistema_acviis/frontend/views/finanzas/Dialogs/agregar_factura.dart';
import 'package:sistema_acviis/frontend/views/finanzas/Dialogs/agregar_factura_caja_chica.dart';
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
          // Botón existente para agregar factura normal
          PrimaryButton(
            text: 'Agregar Factura',
            onPressed: () async {
              final resultado = await showDialog(
                context: context,
                builder: (context) => AgregarFacturaDialog(),
              );
              if (resultado == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Factura agregada correctamente')),
                );
              }
            },
          ),
          
          SizedBox(height: 8), // Espaciado entre botones
          
          // Nuevo botón para facturas de caja chica
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.account_balance_wallet),
              label: Text('Agregar Factura de Caja Chica'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final resultado = await showDialog(
                  context: context,
                  builder: (context) => AgregarFacturaCajaChicaDialog(),
                );
                if (resultado == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Factura de caja chica registrada correctamente')),
                  );
                }
              },
            ),
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
