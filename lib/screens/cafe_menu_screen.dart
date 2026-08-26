import 'package:flutter/material.dart';
import '../order_service.dart';
import '../supabase_client.dart';

class CafeProduct {
  final String nombre;
  final String categoria;
  final String descripcion;
  final double precio;
  final IconData icono;

  CafeProduct({
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.precio,
    required this.icono,
  });
}

class CafeMenuScreen extends StatefulWidget {
  const CafeMenuScreen({super.key});

  @override
  State<CafeMenuScreen> createState() => _CafeMenuScreenState();
}

class _CafeMenuScreenState extends State<CafeMenuScreen> {
  final OrderService _orderService = OrderService();

  IconData _getIconData(String name) {
    switch (name) {
      case 'coffee_maker':
        return Icons.coffee_maker;
      case 'local_drink':
        return Icons.local_drink;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'cake':
        return Icons.cake;
      case 'coffee':
      default:
        return Icons.coffee;
    }
  }

  List<CafeProduct> _productos = [];
  bool _cargando = true;
  bool _cargandoWebCheckout = false;
  final TextEditingController _observacionesCafeController = TextEditingController();

  final List<CafeProduct> _productosFallback = [
    CafeProduct(
      nombre: 'Espresso Origen',
      categoria: 'Bebidas Calientes',
      descripcion: 'Café intenso elaborado con granos seleccionados',
      precio: 5000,
      icono: Icons.coffee,
    ),
    CafeProduct(
      nombre: 'Cappuccino de la Casa',
      categoria: 'Bebidas Calientes',
      descripcion: 'Espresso con leche emulsionada y toque de canela',
      precio: 7500,
      icono: Icons.coffee_maker,
    ),
    CafeProduct(
      nombre: 'Latte Vainilla',
      categoria: 'Bebidas Calientes',
      descripcion: 'Café suave con leche cremosa y esencia de vainilla',
      precio: 8000,
      icono: Icons.coffee,
    ),
    CafeProduct(
      nombre: 'Cold Brew Frutos Rojos',
      categoria: 'Bebidas Frías',
      descripcion: 'Café extraído en frío por 12 horas con notas frutales',
      precio: 8500,
      icono: Icons.local_drink,
    ),
    CafeProduct(
      nombre: 'Croissant de Almendras',
      categoria: 'Alimentos',
      descripcion: 'Hojaldre crujiente relleno de crema de almendras',
      precio: 6500,
      icono: Icons.bakery_dining,
    ),
    CafeProduct(
      nombre: 'Muffin de Arándanos',
      categoria: 'Alimentos',
      descripcion: 'Esponjoso panecillo con arándanos frescos',
      precio: 5000,
      icono: Icons.cake,
    ),
    CafeProduct(
      nombre: 'Torta Selva Negra',
      categoria: 'Alimentos',
      descripcion: 'Pastel de chocolate premium, cerezas y crema',
      precio: 7000,
      icono: Icons.cake,
    ),
  ];

  String _categoriaSeleccionada = 'Todos';

  Future<void> _cargarProductosDb() async {
    try {
      final List<dynamic> response = await supabase
          .from('productos_cafe')
          .select()
          .order('nombre', ascending: true);

      if (response.isNotEmpty) {
        final List<CafeProduct> dbProds = response.map((item) {
          return CafeProduct(
            nombre: item['nombre'] as String,
            categoria: item['categoria'] as String,
            descripcion: item['descripcion'] as String? ?? '',
            precio: double.parse(item['precio'].toString()),
            icono: _getIconData(item['icono_name'] as String? ?? 'coffee'),
          );
        }).toList();

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
      setState(() {
        _productos = _productosFallback;
        _cargando = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _orderService.addListener(_refrescarUI);
    _cargarProductosDb();
  }

  @override
  void dispose() {
    _orderService.removeListener(_refrescarUI);
    _observacionesCafeController.dispose();
    super.dispose();
  }

  void _refrescarUI() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ['Todos', 'Bebidas Calientes', 'Bebidas Frías', 'Alimentos'];
    final productosFiltrados = _categoriaSeleccionada == 'Todos'
        ? _productos
        : _productos.where((p) => p.categoria == _categoriaSeleccionada).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool esWeb = constraints.maxWidth > 900;

        return Scaffold(
          backgroundColor: const Color(0xFF1E1C1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1C1A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFFA26334)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Café & Alimentos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair Display',
              ),
            ),
            actions: [
              if (!esWeb) ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Color(0xFFA26334), size: 28),
                      onPressed: _verCarrito,
                    ),
                    if (_orderService.carritoCafe.isNotEmpty)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: const Color(0xFFA26334),
                          child: Text(
                            _orderService.carritoCafe.length.toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(width: 10),
              ]
            ],
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PANEL IZQUIERDO: MENÚ
              Expanded(
                flex: esWeb ? 2 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filtros de categoría
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: categorias.length,
                        itemBuilder: (context, index) {
                          final cat = categorias[index];
                          final esSeleccionado = cat == _categoriaSeleccionada;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  color: esSeleccionado ? Colors.white : const Color(0xFFB7B7B6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: esSeleccionado,
                              selectedColor: const Color(0xFFA26334),
                              backgroundColor: const Color(0xFF2E2D2C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Color(0xFF3E3D3C)),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _categoriaSeleccionada = cat;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Lista de productos
                    Expanded(
                      child: _cargando
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFA26334),
                              ),
                            )
                          : (esWeb
                              ? GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: productosFiltrados.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.5,
                                  ),
                                  itemBuilder: (context, index) {
                                    final producto = productosFiltrados[index];
                                    return _buildProductCard(producto);
                                  },
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: productosFiltrados.length,
                                  itemBuilder: (context, index) {
                                    final producto = productosFiltrados[index];
                                    return _buildProductCard(producto);
                                  },
                                )),
                    ),
                  ],
                ),
              ),

              // PANEL DERECHO: CARRITO (WEB ONLY)
              if (esWeb)
                Container(
                  width: 380,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF6F0),
                    border: Border(
                      left: BorderSide(color: Color(0xFFE5DCD0), width: 1),
                    ),
                  ),
                  child: _buildWebCartPanel(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(CafeProduct producto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFF2E2D2C),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3E3D3C),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(producto.icono, color: const Color(0xFFA26334), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producto.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFB7B7B6)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${producto.precio.toStringAsFixed(0)} COP',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFA26334), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _orderService.agregarAlCarritoCafe({
                  'nombre': producto.nombre,
                  'precio': producto.precio,
                  'cantidad': 1,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${producto.nombre} agregado al carrito'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: const Color(0xFFA26334),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA26334),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebCartPanel() {
    final items = _orderService.carritoCafe;
    final double total = items.fold(0, (sum, item) => sum + (item['precio'] * item['cantidad']));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: Color(0xFF0E3821), size: 28),
              SizedBox(width: 8),
              Text(
                'Tu Pedido',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E3821)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_cafe, size: 64, color: Colors.black12),
                    SizedBox(height: 12),
                    Text(
                      'El carrito está vacío',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Agrega productos del menú',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black26, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('Cantidad: ${item['cantidad']} x \$${item['precio']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: _cargandoWebCheckout
                            ? null
                            : () {
                                _orderService.quitarDelCarritoCafe(item['nombre']);
                              },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Text('Observaciones especiales:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 4),
            TextField(
              controller: _observacionesCafeController,
              decoration: InputDecoration(
                hintText: 'Ej: Sin azúcar, leche deslactosada, caliente...',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '\$${total.toStringAsFixed(0)} COP',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E3821)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cargandoWebCheckout
                  ? null
                  : () async {
                      setState(() {
                        _cargandoWebCheckout = true;
                      });
                      try {
                        await _orderService.realizarCheckoutCafe(_observacionesCafeController.text);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Pedido de café registrado con éxito! Visita "Mis Pedidos".'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al realizar el pedido: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _cargandoWebCheckout = false;
                          });
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E3821),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _cargandoWebCheckout
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Realizar Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  void _verCarrito() {
    bool cargandoCheckout = false;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: const Color(0xFFFAF6F0),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final items = _orderService.carritoCafe;
            final double total = items.fold(0, (sum, item) => sum + (item['precio'] * item['cantidad']));

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tu Carrito de Café',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E3821)),
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('El carrito está vacío', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    )
                  else ...[
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Cantidad: ${item['cantidad']} x \$${item['precio']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: cargandoCheckout
                                  ? null
                                  : () {
                                      _orderService.quitarDelCarritoCafe(item['nombre']);
                                      setModalState(() {});
                                      setState(() {});
                                    },
                            ),
                          );
                        },
                      ),
                    ),
                    const Text('Observaciones especiales:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _observacionesCafeController,
                      decoration: InputDecoration(
                        hintText: 'Ej: Sin azúcar, leche deslactosada, caliente...',
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('\$${total.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E3821))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: cargandoCheckout
                          ? null
                          : () async {
                              setModalState(() {
                                cargandoCheckout = true;
                              });
                              try {
                                await _orderService.realizarCheckoutCafe(_observacionesCafeController.text);
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Pedido de café registrado con éxito! Visita "Mis Pedidos".'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al realizar el pedido: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setModalState(() {
                                    cargandoCheckout = false;
                                  });
                                  setState(() {});
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E3821),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: cargandoCheckout
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Realizar Pedido', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
