import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';
import 'package:sistema_acviis/ui/views/bottom_navigation_bar.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';

class PrimaryScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const PrimaryScaffold({required this.title, required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PersonalizedAppBar(title: title),
      body: Container(
        width: double.infinity,
        color: AppColors.background,
        child: Padding(
          padding: EdgeInsets.all(normalPadding),
          child: body,
        )
      ),
      bottomNavigationBar: NavigationBottomBar(), // Barra de navegacion
    );
  }
}