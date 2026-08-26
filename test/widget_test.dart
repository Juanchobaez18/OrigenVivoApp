import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:origen_vivo/main.dart';

void main() {
  setUpAll(() async {
    // Configurar valores iniciales simulados para SharedPreferences antes de iniciar Supabase.
    SharedPreferences.setMockInitialValues({});

    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        publishableKey: 'sb_publishable_placeholder',
      );
    } catch (_) {
      // Ignorar si ya se encuentra inicializado.
    }
  });

  testWidgets('Verifica renderizado de LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MiApp());
    await tester.pumpAndSettle();

    // Verifica que se muestren los elementos principales de la pantalla de login.
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Correo Electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Accede a tu cuenta y empieza a disfrutar la experiencia.'), findsOneWidget);
  });
}
