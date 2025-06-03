import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';

class PrimaryCard extends StatelessWidget {
  final String title;
  final String description;
  final Icon icon;

  const PrimaryCard({required this.title, required this.description, required this.icon, super.key});


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 30,
      shadowColor: Colors.black,
      color: AppColors.primaryLight,
      child: SizedBox(
        width: 320,
        height: 320,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryDarker,
                radius: 83,
                child: CircleAvatar(
                  backgroundColor: AppColors.background,
                  radius: 75,
                  child: icon,
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
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 8
              ),
              Text(
                description, 
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 8,
              ),

            ]
          ) 
      )
      )
    );
  }
}