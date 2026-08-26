import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_client.dart';
import 'dashboard_screen.dart';
import 'admin_panel.dart';
import 'web/web_dashboard_screen.dart';
import 'responsive_layout_selector.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _checking = true;
  User? _user;
  String _role = 'cliente';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        _user = session.user;
        // Obtener el rol del usuario de la tabla perfiles
        final response = await supabase
            .from('perfiles')
            .select('rol')
            .eq('user_id', _user!.id)
            .maybeSingle();

        if (response != null && response['rol'] != null) {
          _role = response['rol'].toString().toLowerCase().trim();
        } else {
          final fallback = await supabase
              .from('perfiles')
              .select('rol')
              .eq('id', _user!.id)
              .maybeSingle();
          if (fallback != null && fallback['rol'] != null) {
            _role = fallback['rol'].toString().toLowerCase().trim();
          }
        }
      }
    } catch (_) {
      // Ignorar errores y mantener rol cliente
    } finally {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D2818),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_cafe_outlined, size: 72, color: Color(0xFFB8863B)),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8863B)),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return const ResponsiveLayoutSelector();
    }

    final String email = _user!.email ?? '';
    final bool isStaff = _role == 'admin' || _role == 'produccion' || _role == 'caja';
    final bool isAdmin = _role == 'admin';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return isStaff
              ? AdminPanelScreen(email: email, role: _role)
              : WebDashboardScreen(email: email, role: _role, isAdmin: isAdmin);
        } else {
          return isStaff
              ? AdminPanelScreen(email: email, role: _role)
              : DashboardScreen(email: email, role: _role, isAdmin: isAdmin);
        }
      },
    );
  }
}
