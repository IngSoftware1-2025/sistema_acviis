import 'package:flutter/material.dart';
import 'package:sistema_acviis/constants/constants.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';

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
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primaryDark,
      leading: currentRoute == '/home_page'
          ? null
          : IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white.withAlpha(51), // 0.2 * 255 ≈ 51
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                // Obtiene la ruta actual (donde se encuentra este widget)
                final uri = Uri.parse(currentRoute);
                final segments = List<String>.from(uri.pathSegments);
                if (segments.isNotEmpty) {
                  segments.removeLast();
                }
                String parentRoute = '/${segments.join('/')}';
                if (parentRoute == '/') {
                  parentRoute = '/home_page';
                }
                Navigator.of(context).pushReplacementNamed(parentRoute);
              },
            ),
    );
  }
}