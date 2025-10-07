import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';


class FinanzasMainView extends StatefulWidget {
  const FinanzasMainView({
    super.key
  });
  @override
  State<FinanzasMainView> createState() => _FinanzasMainViewState();
}

class _FinanzasMainViewState extends State<FinanzasMainView> {

  @override
  Widget build(BuildContext context){
    return PrimaryScaffold(
      title: 'Finanzas',
      body: Column(
        children: [
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
          PrimaryButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home_page/finanzas_main_view/facturas_view');
            },
            text: 'Facturas',
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home_page/finanzas_main_view/pagos_pendientes_view');
            },
            text: 'Pagos Pendientes',
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home_page/finanzas_main_view/configurar_notificaciones_view');
            },
            text: 'Configurar Notificaciones',
          ),
        ],
      ),
    );
  }
}