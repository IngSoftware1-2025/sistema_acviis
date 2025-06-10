import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';

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
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Satoshi', // Aquí estoy probando la nueva fuente. Tiene 3 niveles de negrilla, 300, 500 y 700.
          fontWeight: FontWeight.w500,
          color: AppColors.background,
        ),
      ),
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: currentRoute == '/home_page' || title=='Home'
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
      actions: MediaQuery.of(context).size.width < 600
          ? <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.background,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.primaryDark),
                          const SizedBox(width: 8),
                          const Text('Perfil de usuario'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'user',
                      child: Text(
                        'Usuario: <Nombre de usuario>',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: AppColors.primaryDark),
                          const SizedBox(width: 8),
                          const Text('Cerrar sesión'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'profile') {
                      // Acción para perfil de usuario
                    } else if (value == 'logout') {
                      // Acción para cerrar sesión
                    }
                  },
                ),
              ),
            ]
          : <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: AppColors.background,
                ),
                tooltip: 'Perfil de usuario',
                onPressed: () {},
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Usuario: <Nombre de usuario>',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w500,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.background,
                ),
                tooltip: 'Cerrar sesión',
                onPressed: () {},
              ),
            ],
    );
  }
}