import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';

class PrimaryCard extends StatelessWidget {
  final String title;
  final String description;
  final Icon icon;

  const PrimaryCard({required this.title, required this.description, required this.icon, super.key});


  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    return Card(
      elevation: 30,
      shadowColor: Colors.black,
      color: AppColors.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryDarker,
              radius: anchoPantalla * 0.04,
              child: CircleAvatar(
                backgroundColor: AppColors.background,
                radius: anchoPantalla * 0.035,
                child: Icon(
                  icon.icon,
                  size: anchoPantalla * 0.055,
                  color: AppColors.primaryDarker,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              description, 
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
          ]
        ) 
      )
    );
  }
}

class GridCards extends StatelessWidget {
  final List<Map<String, dynamic>> opciones;   

  
  const GridCards({required this.opciones, super.key});

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final anchoCard = anchoPantalla * 0.3;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: opciones.map((opcion) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                opcion['screen'],
              );
            },
            child: SizedBox(
              width: anchoCard,
              child: PrimaryCard(
                title: opcion['title'],
                description: opcion['description'],
                icon: opcion['icon']
              ),
            ),
          );
        }).toList() 
      ),
    );
  }
}