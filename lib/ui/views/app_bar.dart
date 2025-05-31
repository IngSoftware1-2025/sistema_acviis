import 'package:flutter/material.dart';
import 'package:sistema_acviis/constants/constants.dart';

class PersonalizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const PersonalizedAppBar({
    super.key,
    required this.title,
  });

  static const double appBarHeight = kToolbarHeight;
  @override
  Size get preferredSize => const Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: colorAcviis,
      leading: IconButton(
        icon: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: const Icon(
            Icons.home,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/home_page');
        },
      ),
    );
  }
}