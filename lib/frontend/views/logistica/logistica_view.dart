import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/cards.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';

class LogisticaView extends StatefulWidget {
  const LogisticaView({super.key});

  @override
  State<LogisticaView> createState() => _LogisticaViewState();
}

class _LogisticaViewState extends State<LogisticaView> {
  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Logística',
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1000, // Limita el ancho máximo
            maxHeight: 1000, // Limita la altura máxima
          ),
          child: GridCards(
            opciones: [
              {
                'title': 'EPP',
                'description': 'Equipos de Protección Personal: Registrar, Consultar, Asignar',
                'icon': Icon(Icons.security, color: AppColors.primaryDarker),
                'screen': '/home_page/logistica_view/epp_view'
              },
              {
                'title': 'Herramientas',
                'description': 'Gestión de herramientas: Inventario, Asignación, Mantenimiento',
                'icon': Icon(Icons.build, color: AppColors.primaryDarker),
                'screen': '/home_page/logistica_view/herramientas_view'
              },
              {
                'title': 'Vehículos',
                'description': 'Gestión de vehículos: Mantenimiento, Asignación, Combustible',
                'icon': Icon(Icons.directions_car, color: AppColors.primaryDarker),
                'screen': '/home_page/logistica_view/vehiculos_view'
              },
            ]
          ),
        ),
      ),
    );
  }
}
