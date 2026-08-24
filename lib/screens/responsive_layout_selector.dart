import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'web/web_login_screen.dart';

class ResponsiveLayoutSelector extends StatelessWidget {
  const ResponsiveLayoutSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // Si el ancho es mayor a 900, mostramos la versión web optimizada para PC.
    // De lo contrario, cargamos la versión móvil tradicional.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return const WebLoginScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
