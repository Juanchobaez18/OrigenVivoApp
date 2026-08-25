import 'package:flutter/material.dart';
import '../../order_service.dart';
import '../../supabase_client.dart';
import '../collections_screen.dart';
import '../cafe_menu_screen.dart';
import '../sublimable_catalog_screen.dart';
import '../order_tracking_screen.dart';
import '../responsive_layout_selector.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class WebDashboardScreen extends StatefulWidget {
  final String email;
  final String role;
  final bool isAdmin;

  const WebDashboardScreen({
    super.key,
    required this.email,
    required this.role,
    required this.isAdmin,
  });

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  int _currentIndex = 0;
  final OrderService _orderService = OrderService();

  final List<String> _avataresPredefinidos = [
    'https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=150&auto=format&fit=crop&q=60',
    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=150&auto=format&fit=crop&q=60',
    'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=150&auto=format&fit=crop&q=60',
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=150&auto=format&fit=crop&q=60',
    'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=150&auto=format&fit=crop&q=60',
  ];

  ImageProvider? _obtenerAvatarProvider(String avatarUrl) {
    if (avatarUrl.isEmpty) return null;
    if (avatarUrl.startsWith('data:')) {
      try {
        final base64String = avatarUrl.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(avatarUrl);
  }

  @override
  void initState() {
    super.initState();
    _orderService.addListener(_refrescarUI);
    _orderService.cargarPedidosDesdeDB();
  }

  @override
  void dispose() {
    _orderService.removeListener(_refrescarUI);
    super.dispose();
  }

  void _refrescarUI() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _cerrarSesion() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ResponsiveLayoutSelector()),
        (route) => false,
      );
    }
  }

  void _mostrarDialogoEditarPerfil() {
    final user = supabase.auth.currentUser;
    final nombreInicial = user?.userMetadata?['nombre'] ?? '';
    final avatarInicial = user?.userMetadata?['avatar_url'] ?? '';

    final TextEditingController nombreEditController = TextEditingController(text: nombreInicial);
    String avatarSeleccionado = avatarInicial;
    bool guardando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5EDE3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        bool subiendoImagen = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Editar Perfil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2818),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFF0E3821),
                      backgroundImage: _obtenerAvatarProvider(avatarSeleccionado),
                      child: avatarSeleccionado.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: subiendoImagen ? null : () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 300,
                          maxHeight: 300,
                          imageQuality: 85,
                        );
                        
                        if (image != null) {
                          setModalState(() => subiendoImagen = true);
                          try {
                            final bytes = await image.readAsBytes();
                            final String base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
                            
                            String finalUrl = '';
                            try {
                              final String fileExt = image.name.split('.').last;
                              final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
                              final String filePath = '${user?.id ?? "temp"}/$fileName';
                              
                              await supabase.storage.from('avatars').uploadBinary(
                                filePath,
                                bytes,
                                fileOptions: const FileOptions(
                                  cacheControl: '3600',
                                  upsert: true,
                                ),
                              );
                              
                              finalUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
                            } catch (_) {
                              finalUrl = base64Image;
                            }
                            
                            setModalState(() {
                              avatarSeleccionado = finalUrl;
                            });
                          } catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text('Error al procesar la imagen: $e')),
                            );
                          } finally {
                            setModalState(() => subiendoImagen = false);
                          }
                        }
                      },
                      icon: subiendoImagen 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Color(0xFFB8863B)),
                              ),
                            )
                          : const Icon(Icons.photo_library, size: 16),
                      label: Text(subiendoImagen ? 'Procesando...' : 'Subir desde galería'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB8863B),
                        side: const BorderSide(color: Color(0xFFB8863B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Selecciona un avatar de café:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2818)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _avataresPredefinidos.length,
                      itemBuilder: (context, index) {
                        final avatarUrl = _avataresPredefinidos[index];
                        final esSeleccionado = avatarSeleccionado == avatarUrl;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              avatarSeleccionado = avatarUrl;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: esSeleccionado ? const Color(0xFFB8863B) : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(avatarUrl),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nombreEditController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: Color(0xFF2C3E2D)),
                    decoration: InputDecoration(
                      labelText: 'Nombre de Usuario',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF0D2818)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFE2D6C5), width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFB8863B), width: 1.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: guardando ? null : () async {
                        final nuevoNombre = nombreEditController.text.trim();
                        if (nuevoNombre.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, ingresa un nombre')),
                          );
                          return;
                        }
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        setModalState(() => guardando = true);
                        try {
                          await supabase.auth.updateUser(
                            UserAttributes(
                              data: {
                                'nombre': nuevoNombre,
                                'avatar_url': avatarSeleccionado,
                              },
                            ),
                          );
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Perfil actualizado correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          navigator.pop();
                          if (mounted) {
                            setState(() {});
                          }
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Error al actualizar: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setModalState(() => guardando = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D2818),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: guardando
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 1: INICIO ---
  Widget _buildInicioTab() {
    final user = supabase.auth.currentUser;
    final nombreMetadata = user?.userMetadata?['nombre'] ?? '';
    
    final String nombreFormateado;
    if (nombreMetadata.isNotEmpty) {
      nombreFormateado = nombreMetadata;
    } else {
      final nombreUsuario = widget.email.split('@').first;
      nombreFormateado = nombreUsuario.isNotEmpty 
          ? nombreUsuario[0].toUpperCase() + nombreUsuario.substring(1)
          : 'Usuario';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '¡Hola, $nombreFormateado!',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D2818),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bienvenido a tu panel web de Café Origen Vivo.',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4A5D4C),
            ),
          ),
          const SizedBox(height: 48),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta 1: Pedido (Bebidas y alimentos)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CafeMenuScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA26334), Color(0xFF6E4B2E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Pedido',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ordena tus bebidas y alimentos favoritos de nuestra cafetería artesanal.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 40,
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Color(0xFFA26334),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              
              // Tarjeta 2: Personaliza tu Producto
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SublimableCatalogScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E2D2C), Color(0xFF1E1C1A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF3E3D3C), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Personaliza tu Producto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Elige un souvenir de nuestra tienda y añádele tus propios diseños en sublimación.',
                                style: TextStyle(
                                  color: Color(0xFFB7B7B6),
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 40,
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFA26334),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 3: MIS PEDIDOS ---
  Widget _buildMisPedidosTab() {
    final pedidos = _orderService.pedidos;

    if (pedidos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 90, color: Colors.grey),
              SizedBox(height: 24),
              Text(
                'No tienes pedidos activos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Tus compras y souvenirs en sublimación aparecerán listados aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: pedidos.length,
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        final esSublimacion = pedido.tipo == 'Sublimación';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFF2E2D2C),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderTrackingScreen(pedido: pedido),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            leading: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF3E3D3C),
                shape: BoxShape.circle,
              ),
              child: Icon(
                esSublimacion ? Icons.palette : Icons.local_cafe,
                color: const Color(0xFFA26334),
                size: 28,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pedido.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                ),
                Text(
                  '${pedido.cantidad}x',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB7B7B6), fontSize: 16),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(pedido.detalle, style: const TextStyle(fontSize: 14, color: Color(0xFFB7B7B6))),
                const SizedBox(height: 4),
                Text(
                  '${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year} - ${pedido.tipo}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFB7B7B6)),
                ),
              ],
            ),
            trailing: Text(
              '\$${(pedido.precio * pedido.cantidad).toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFA26334), fontSize: 20),
            ),
          ),
        );
      },
    );
  }

  // --- TAB 4: MI PERFIL ---
  Widget _buildMiPerfilTab() {
    final user = supabase.auth.currentUser;
    final nombre = user?.userMetadata?['nombre'] ?? 'Cliente Origen Vivo';
    final avatarUrl = user?.userMetadata?['avatar_url'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: const Color(0xFF0E3821),
                  backgroundImage: _obtenerAvatarProvider(avatarUrl),
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 80, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB8863B),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit, size: 22, color: Colors.white),
                      onPressed: _mostrarDialogoEditarPerfil,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D2818)),
          ),
          const SizedBox(height: 6),
          Text(
            widget.email,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF4A5D4C)),
          ),
          const SizedBox(height: 6),
          Text(
            'Rol: ${widget.role.toUpperCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB8863B), fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _mostrarDialogoEditarPerfil,
                  icon: const Icon(Icons.settings),
                  label: const Text('Editar Datos del Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E3821),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E34),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = supabase.auth.currentUser;
    final nombre = user?.userMetadata?['nombre'] ?? 'Cliente Origen Vivo';
    final avatarUrl = user?.userMetadata?['avatar_url'] ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // BARRA LATERAL (SIDEBAR) FIJA A LA IZQUIERDA
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF0D2818), // Verde Origen Vivo
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabecera de la Sidebar con el logotipo circular completo
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Image.asset(
                    'assets/logo_completo.png',
                    height: 130,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 24),
                
                // Enlaces de navegación en Sidebar
                _buildSidebarMenuItem(
                  index: 0,
                  icon: Icons.home,
                  label: 'Inicio',
                ),
                _buildSidebarMenuItem(
                  index: 1,
                  icon: Icons.grid_view,
                  label: 'Categorías',
                ),
                _buildSidebarMenuItem(
                  index: 2,
                  icon: Icons.archive_outlined,
                  label: 'Mis Pedidos',
                ),
                _buildSidebarMenuItem(
                  index: 3,
                  icon: Icons.person,
                  label: 'Mi Perfil',
                ),
                
                const Spacer(),
                const Divider(color: Colors.white24, height: 1),
                
                // Panel de información de usuario en la base
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white10,
                        backgroundImage: _obtenerAvatarProvider(avatarUrl),
                        child: avatarUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 24)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.email,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón de Cerrar Sesión en Sidebar
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
                  child: ElevatedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E34),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // CONTENIDO PRINCIPAL A LA DERECHA (PÁGINA SELECCIONADA)
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildInicioTab(),
                const CollectionsScreen(isEmbedded: true),
                _buildMisPedidosTab(),
                _buildMiPerfilTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenuItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool esSeleccionado = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: esSeleccionado ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: esSeleccionado ? const Color(0xFFB8863B) : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: esSeleccionado ? Colors.white : Colors.white70,
                  fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
