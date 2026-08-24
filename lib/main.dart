import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/responsive_layout_selector.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wbecrnnlxhblleuucahq.supabase.co',
    publishableKey: 'sb_publishable_Q09fRgBv1YVmAE3eYI9qlg_B6BfG-UT',
  );

  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Origen Vivo',
      theme: OrigenVivoTheme.lightTheme,
      home: const ResponsiveLayoutSelector(), 
    );
  }
}