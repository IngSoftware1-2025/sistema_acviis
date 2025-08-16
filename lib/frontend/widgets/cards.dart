import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';

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
                  size: anchoPantalla * 0.7, // No funciona no entiendo qué pasa
                  //size: 300, // No funciona tampoco
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
  const GridCards({super.key, required this.opciones});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columnas
        crossAxisSpacing: 32,
        mainAxisSpacing: 32,
        childAspectRatio: 1.4,
      ),
      itemCount: opciones.length,
      itemBuilder: (context, index) {
        final opcion = opciones[index];
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: Colors.lightBlueAccent.shade100,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: opcion['screen'] != null
                ? () => Navigator.pushNamed(context, opcion['screen'])
                : null,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  opcion['icon'] ?? const SizedBox.shrink(),
                  const SizedBox(height: 18),
                  Text(
                    opcion['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    opcion['description'] ?? '',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}