import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../supabase_client.dart';
import '../admin_panel.dart';
import '../forgot_password_screen.dart';
import '../register_screen.dart';
import '../reset_password_screen.dart';
import 'web_dashboard_screen.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _cargando = false;
  bool _reenviando = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResetPasswordScreen(),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  Future<String> _obtenerRolUsuario(String userId) async {
    try {
      final response = await supabase
          .from('perfiles')
          .select('rol')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['rol'] != null) {
        return response['rol'].toString();
      }

      final fallback = await supabase
          .from('perfiles')
          .select('rol')
          .eq('id', userId)
          .maybeSingle();

      if (fallback != null && fallback['rol'] != null) {
        return fallback['rol'].toString();
      }
    } catch (_) {}
    return 'cliente';
  }

  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo y contraseña')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted && response.user != null) {
        final String role = await _obtenerRolUsuario(response.user!.id);
        if (!mounted) return;
        final String roleNormalized = role.toLowerCase();
        final bool isStaff = roleNormalized == 'admin' || roleNormalized == 'produccion' || roleNormalized == 'caja';
        final bool isAdmin = roleNormalized == 'admin';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido a Café Origen Vivo! Rol: $role'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isStaff
                ? AdminPanelScreen(email: email, role: roleNormalized)
                : WebDashboardScreen(email: email, role: roleNormalized, isAdmin: isAdmin),
          ),
        );
      }
    } on AuthException catch (error) {
      final String mensaje = error.message.toLowerCase().contains('email not confirmed')
          ? 'Tu correo aún no está confirmado. Revisa el email de confirmación.'
          : error.message;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error inesperado al conectar con el servidor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _reenviarCorreoConfirmacion() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo para reenviar la confirmación')),
      );
      return;
    }

    setState(() => _reenviando = true);
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'https://example.com',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha reenviado el correo de confirmación. Revisa tu bandeja.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reenviar el correo: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _reenviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // LADO IZQUIERDO: Panel corporativo con logotipo
          Expanded(
            flex: 6,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D2818), Color(0xFF07140B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(64.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/logo_completo.png',
                          height: 280,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Café, Amor y Territorio',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: const Color(0xFFB8863B),
                        fontFamily: 'Playfair Display',
                        fontSize: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Disfruta de la mejor selección de café artesanal de especialidad y diseña productos sublimados personalizados a tu gusto desde un mismo lugar.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFF5EDE3).withValues(alpha: 0.8),
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // LADO DERECHO: Formulario de Login centrado
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFFF5EDE3),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Bienvenido a la Web',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresa tus credenciales para acceder al panel.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 36),
                        
                        // Email Input
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Color(0xFF2C3E2D)),
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Password Input
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Color(0xFF2C3E2D)),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Botón de Inicio de Sesión
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _cargando
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : const Text(
                                    'Iniciar Sesión',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Enlaces adicionales
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.secondary,
                          ),
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                        
                        TextButton(
                          onPressed: _reenviando ? null : _reenviarCorreoConfirmacion,
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.secondary,
                          ),
                          child: _reenviando
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Reenviar correo de confirmación'),
                        ),
                        
                        const Divider(height: 40),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('¿No tienes cuenta?', style: theme.textTheme.bodyMedium),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.secondary,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              child: const Text('Regístrate'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
