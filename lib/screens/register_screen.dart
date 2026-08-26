import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_client.dart';

// Definimos un StatefulWidget porque el formulario cambia de estado (muestra spinner de carga)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores de texto para capturar los datos ingresados por el usuario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variable de estado para controlar el indicador de carga en el botón
  bool _cargando = false;

  // Función principal para procesar el registro de un nuevo cliente
  Future<void> _registrarUsuario() async {
    // 1. Extraemos y limpiamos los espacios en blanco de los inputs
    final nombre = _nombreController.text.trim();
    final telefono = _telefonoController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validación: campos vacíos
    if (nombre.isEmpty || telefono.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    // Validación: formato de correo electrónico
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo electrónico válido')),
      );
      return;
    }

    // Validación: mínimo 8 caracteres
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres')),
      );
      return;
    }

    // Validación: al menos una letra mayúscula
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos una letra mayúscula')),
      );
      return;
    }

    // Validación: al menos un número
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe contener al menos un número')),
      );
      return;
    }

    // Validación: contraseñas coinciden
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    // Activamos el estado de carga para deshabilitar el botón y mostrar el indicador circular
    setState(() => _cargando = true);

    try {
      // 4. Registrar al usuario en Supabase Auth
      // Nota: Enviamos nombre y teléfono en 'data' (metadatos). 
      // El Trigger en la Base de Datos capturará estos datos e insertará la fila en 'public.perfiles' con el rol 'cliente'.
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': nombre,
          'telefono': telefono,
        },
      );

      // Si el registro fue exitoso y el widget sigue montado en la vista
      if (mounted && response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta de cliente creada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Cerramos la pantalla de registro y volvemos a la de Login
        Navigator.pop(context);
      }
    } on AuthException catch (error) {
      // Capturamos errores específicos devueltos por Supabase (ej. correo ya registrado)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // Capturamos cualquier otro error de red o del sistema
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error inesperado al registrar el usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Desactivamos el estado de carga al finalizar todo el proceso
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  // Liberamos la memoria consumida por los controladores cuando la pantalla se destruye
  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2818), Color(0xFF07140B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EDE3),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       Container(
                        height: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D2818), Color(0xFF1B4D2B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/logo_sencillo.png',
                            height: 110,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Crear Cuenta',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Regístrate para formar parte de Café Origen Vivo.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),

                            TextField(
                              controller: _nombreController,
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(color: Color(0xFF2C3E2D)),
                              decoration: InputDecoration(
                                labelText: 'Nombre Completo',
                                labelStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.6)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: Color(0xFFE2D6C5), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(color: colorScheme.secondary, width: 1.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _telefonoController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Color(0xFF2C3E2D)),
                              decoration: InputDecoration(
                                labelText: 'Teléfono',
                                labelStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.6)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.phone, color: colorScheme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: Color(0xFFE2D6C5), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(color: colorScheme.secondary, width: 1.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Color(0xFF2C3E2D)),
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                labelStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.6)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: Color(0xFFE2D6C5), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(color: colorScheme.secondary, width: 1.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Color(0xFF2C3E2D)),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.6)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: Color(0xFFE2D6C5), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(color: colorScheme.secondary, width: 1.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Color(0xFF2C3E2D)),
                              decoration: InputDecoration(
                                labelText: 'Confirmar Contraseña',
                                labelStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.6)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: Color(0xFFE2D6C5), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(color: colorScheme.secondary, width: 1.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _cargando ? null : _registrarUsuario,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
                                ),
                                child: _cargando
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      )
                                    : const Text(
                                        'Registrarse',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('¿Ya tienes una cuenta?', style: theme.textTheme.bodyMedium),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.secondary,
                                  ),
                                  child: const Text(
                                    'Inicia sesión',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}