import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/finanzas/utils/lista_pagos_pendientes.dart';
import 'package:sistema_acviis/frontend/views/finanzas/Dialogs/agregar_pago.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';

class PagosPendientesView extends StatelessWidget {
  const PagosPendientesView({super.key});
  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Pagos Pendientes',
      body: Column(
        children: [
          Row(          ),
          SizedBox(height: normalPadding),
          PrimaryButton(
            text: 'Agregar Pago Pendiente',
            onPressed: () async {
              final resultado = await showDialog(
                context: context,
                builder: (context) => const AgregarPagoDialog(),
              );
              if (resultado == true) {
                // refresca la lista cuando se agrega un nuevo pago pendiente
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pago pendiente agregado correctamente')),
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
          Expanded(child: ListaPagosPendientes()),
        ],
      ),
    );
  }
}