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
    // Carga la aplicación en el árbol de widgets.
    await tester.pumpWidget(const MiApp());
    await tester.pump();

    // Verifica que se muestren los textos principales de la pantalla de login.
    expect(find.text('Origen Vivo'), findsOneWidget);
    expect(find.text('Café, amor y territorio'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
