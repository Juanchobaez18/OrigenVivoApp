import 'package:flutter/material.dart';
import 'collections_screen.dart';
import '../supabase_client.dart';

class SublimableProduct {
  final String nombre;
  final IconData icono;
  final String descripcion;

  SublimableProduct({
    required this.nombre,
    required this.icono,
    required this.descripcion,
  });
}

class SublimableProductsScreen extends StatefulWidget {
  final String? categoriaFiltro;
  final String? categoriaNombre;

  const SublimableProductsScreen({
    super.key,
    this.categoriaFiltro,
    this.categoriaNombre,
  });

  @override
  State<SublimableProductsScreen> createState() => _SublimableProductsScreenState();
}

class _SublimableProductsScreenState extends State<SublimableProductsScreen> {
  IconData _getIconData(String name) {
    switch (name) {
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_cafe_outlined':
        return Icons.local_cafe_outlined;
      case 'coffee_maker_outlined':
        return Icons.coffee_maker_outlined;
      case 'opacity':
        return Icons.opacity;
      case 'checkroom_outlined':
        return Icons.checkroom_outlined;
      case 'dry_cleaning':
        return Icons.dry_cleaning;
      case 'dry_cleaning_outlined':
        return Icons.dry_cleaning_outlined;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'child_care':
        return Icons.child_care;
      case 'checkroom':
      default:
        return Icons.checkroom;
    }
  }

  List<SublimableProduct> _productos = [];
  bool _cargando = true;

  final List<SublimableProduct> _productosFallback = [
    SublimableProduct(
      nombre: 'mugs 6 oz',
      icono: Icons.local_cafe_outlined,
      descripcion: 'Taza pequeña sublimable',
    ),
    SublimableProduct(
      nombre: 'mugs 12 oz',
      icono: Icons.local_cafe,
      descripcion: 'Taza estándar de cerámica',
    ),
    SublimableProduct(
      nombre: 'vaso termico',
      icono: Icons.coffee_maker_outlined,
      descripcion: 'Vaso de acero térmico',
    ),
    SublimableProduct(
      nombre: 'Magico',
      icono: Icons.opacity,
      descripcion: 'Taza mágica cambia color',
    ),
    SublimableProduct(
      nombre: 'Buso',
      icono: Icons.checkroom,
      descripcion: 'Sweatshirt / Buso clásico',
    ),
    SublimableProduct(
      nombre: 'camiseta B',
      icono: Icons.dry_cleaning,
      descripcion: 'Camiseta de algodón básica',
    ),
    SublimableProduct(
      nombre: 'busos de Color',
      icono: Icons.checkroom_outlined,
      descripcion: 'Busos con gama de color',
    ),
    SublimableProduct(
      nombre: 'Camiseta Color',
      icono: Icons.dry_cleaning_outlined,
      descripcion: 'Camisetas coloridas sublimadas',
    ),
    SublimableProduct(
      nombre: 'camisetas oversize',
      icono: Icons.accessibility_new,
      descripcion: 'Estilo holgado y moderno',
    ),
    SublimableProduct(
      nombre: 'camiseta niños',
      icono: Icons.child_care,
      descripcion: 'Tallas pequeñas infantiles',
    ),
  ];

  bool _perteneceACategoria(SublimableProduct prod, String tag) {
    final nombreLower = prod.nombre.toLowerCase();
    if (tag == 'tazas') {
      return nombreLower.contains('mug') || nombreLower.contains('vaso') || nombreLower.contains('termico') || nombreLower.contains('magico');
    } else if (tag == 'ropa') {
      return nombreLower.contains('buso') || nombreLower.contains('camiseta') || nombreLower.contains('clothing') || nombreLower.contains('oversize');
    } else if (tag == 'accesorios') {
      return !nombreLower.contains('mug') && !nombreLower.contains('vaso') && !nombreLower.contains('termico') && !nombreLower.contains('magico') &&
             !nombreLower.contains('buso') && !nombreLower.contains('camiseta') && !nombreLower.contains('clothing') && !nombreLower.contains('oversize');
    }
    return true;
  }

  Future<void> _cargarSublimables() async {
    try {
      final List<dynamic> response = await supabase
          .from('productos_sublimables')
          .select()
          .order('nombre', ascending: true);

      if (response.isNotEmpty) {
        List<SublimableProduct> dbProds = response.map((item) {
          return SublimableProduct(
            nombre: item['nombre'] as String,
            descripcion: item['descripcion'] as String? ?? '',
            icono: _getIconData(item['icono_name'] as String? ?? 'checkroom'),
          );
        }).toList();

        if (widget.categoriaFiltro != null) {
          dbProds = dbProds.where((p) => _perteneceACategoria(p, widget.categoriaFiltro!)).toList();
        }

        if (mounted) {
          setState(() {
            _productos = dbProds;
            _cargando = false;
          });
        }
        return;
      }
    } catch (_) {
      // Ignorar error para usar el fallback
    }

    if (mounted) {
      var prods = _productosFallback;
      if (widget.categoriaFiltro != null) {
        prods = prods.where((p) => _perteneceACategoria(p, widget.categoriaFiltro!)).toList();
      }
      setState(() {
        _productos = prods;
        _cargando = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarSublimables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1C1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFA26334)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoriaNombre ?? 'Selección de Producto',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Playfair Display',
          ),
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA26334)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _productos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final producto = _productos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectionsScreen(
                          productoSeleccionado: producto.nombre,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2D2C),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3E3D3C),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            producto.icono,
                            size: 48,
                            color: const Color(0xFFA26334),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          producto.nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          producto.descripcion,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB7B7B6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
