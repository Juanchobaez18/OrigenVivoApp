import 'package:flutter/material.dart';
import '../order_service.dart';
import '../supabase_client.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final OrderService _orderService = OrderService();

  List<dynamic> _productosCafe = [];
  List<dynamic> _productosSublimables = [];
  List<dynamic> _disenos = [];
  List<dynamic> _colecciones = [];

  bool _cargandoCafe = true;
  bool _cargandoSub = true;
  bool _cargandoDisenos = true;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    await Future.wait([
      _cargarCafe(),
      _cargarSublimables(),
      _cargarDisenos(),
    ]);
  }

  Future<void> _cargarCafe() async {
    try {
      final List<dynamic> res = await supabase.from('productos_cafe').select().order('nombre');
      if (mounted) {
        setState(() {
          _productosCafe = res;
          _cargandoCafe = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar café: $e');
      if (mounted) setState(() => _cargandoCafe = false);
    }
  }

  Future<void> _cargarSublimables() async {
    try {
      final List<dynamic> res = await supabase.from('productos_sublimables').select().order('nombre');
      if (mounted) {
        setState(() {
          _productosSublimables = res;
          _cargandoSub = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar sublimables: $e');
      if (mounted) setState(() => _cargandoSub = false);
    }
  }

  Future<void> _cargarDisenos() async {
    try {
      final List<dynamic> res = await supabase.from('disenos').select('*, colecciones(*)').order('nombre');
      final List<dynamic> cols = await supabase.from('colecciones').select().order('nombre');
      if (mounted) {
        setState(() {
          _disenos = res;
          _colecciones = cols;
          _cargandoDisenos = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar diseños: $e');
      if (mounted) setState(() => _cargandoDisenos = false);
    }
  }

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
      case 'landscape':
        return Icons.landscape;
      case 'landscape_outlined':
        return Icons.landscape_outlined;
      case 'checkroom':
        return Icons.checkroom;
      case 'checkroom_outlined':
        return Icons.checkroom_outlined;
      case 'dry_cleaning':
        return Icons.dry_cleaning;
      case 'dry_cleaning_outlined':
        return Icons.dry_cleaning_outlined;
      case 'palette':
        return Icons.palette;
      case 'coffee':
      default:
        return Icons.coffee;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5EDE3),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D2818),
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text(
            'Gestión de Catálogo',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Playfair Display', color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFB8863B),
            labelColor: Color(0xFFB8863B),
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Cafetería', icon: Icon(Icons.local_cafe)),
              Tab(text: 'Sublimables', icon: Icon(Icons.checkroom)),
              Tab(text: 'Diseños', icon: Icon(Icons.palette)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCafeTab(),
            _buildSublimablesTab(),
            _buildDisenosTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: CAFETERÍA ---
  Widget _buildCafeTab() {
    if (_cargandoCafe) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D2818)));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D2818),
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormularioCafe(null),
        child: const Icon(Icons.add),
      ),
      body: _productosCafe.isEmpty
          ? const Center(child: Text('No hay productos de cafetería creados.', style: TextStyle(color: Color(0xFF0D2818))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _productosCafe.length,
              itemBuilder: (context, index) {
                final prod = _productosCafe[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF5EDE3),
                      child: Icon(_getIconData(prod['icono_name'] ?? 'coffee'), color: const Color(0xFF0D2818)),
                    ),
                    title: Text(prod['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2818))),
                    subtitle: Text(
                      '${prod['categoria']} | \$${(prod['precio'] as num).toStringAsFixed(0)}\n${prod['descripcion']}',
                      style: const TextStyle(color: Color(0xFF4A5D4C), fontSize: 12),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _abrirFormularioCafe(prod),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminarCafe(prod),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _abrirFormularioCafe(Map<String, dynamic>? prod) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: prod?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: prod?['descripcion'] ?? '');
    final priceCtrl = TextEditingController(text: prod != null ? (prod['precio'] as num).toStringAsFixed(0) : '');
    String selectedCat = prod?['categoria'] ?? 'Bebidas Calientes';
    String selectedIcon = prod?['icono_name'] ?? 'coffee';
    bool guardando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFAF6F0),
              title: Text(prod == null ? 'Nuevo Producto Café' : 'Editar Producto Café', style: const TextStyle(color: Color(0xFF0D2818), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCat,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: ['Bebidas Calientes', 'Bebidas Frías', 'Alimentos'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setDialogState(() => selectedCat = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa una descripción' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(labelText: 'Precio (COP)'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Ingresa un precio válido' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedIcon,
                        decoration: const InputDecoration(labelText: 'Icono'),
                        items: ['coffee', 'coffee_maker', 'local_drink', 'bakery_dining', 'cake'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                        onChanged: (v) => setDialogState(() => selectedIcon = v!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: guardando ? null : () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => guardando = true);
                          try {
                            if (prod == null) {
                              await _orderService.crearProductoCafe(
                                nombre: nameCtrl.text.trim(),
                                categoria: selectedCat,
                                descripcion: descCtrl.text.trim(),
                                precio: double.parse(priceCtrl.text.trim()),
                                iconoName: selectedIcon,
                              );
                            } else {
                              await _orderService.actualizarProductoCafe(
                                id: prod['id'] as int,
                                nombre: nameCtrl.text.trim(),
                                categoria: selectedCat,
                                descripcion: descCtrl.text.trim(),
                                precio: double.parse(priceCtrl.text.trim()),
                                iconoName: selectedIcon,
                              );
                            }
                            await _cargarCafe();
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            setDialogState(() => guardando = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red));
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2818), foregroundColor: Colors.white),
                  child: guardando ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminarCafe(Map<String, dynamic> prod) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFAF6F0),
          title: const Text('Eliminar Producto', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('¿Deseas eliminar el producto "${prod['nombre']}" de la base de datos?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('No', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                try {
                  await _orderService.eliminarProductoCafe(prod['id'] as int);
                  await _cargarCafe();
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Sí, Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- TAB 2: SUBLIMABLES ---
  Widget _buildSublimablesTab() {
    if (_cargandoSub) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D2818)));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D2818),
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormularioSublimable(null),
        child: const Icon(Icons.add),
      ),
      body: _productosSublimables.isEmpty
          ? const Center(child: Text('No hay productos sublimables creados.', style: TextStyle(color: Color(0xFF0D2818))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _productosSublimables.length,
              itemBuilder: (context, index) {
                final prod = _productosSublimables[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF5EDE3),
                      child: Icon(_getIconData(prod['icono_name'] ?? 'checkroom'), color: const Color(0xFF0D2818)),
                    ),
                    title: Text(prod['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2818))),
                    subtitle: Text(prod['descripcion'] ?? '', style: const TextStyle(color: Color(0xFF4A5D4C), fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _abrirFormularioSublimable(prod),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminarSublimable(prod),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _abrirFormularioSublimable(Map<String, dynamic>? prod) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: prod?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: prod?['descripcion'] ?? '');
    String selectedIcon = prod?['icono_name'] ?? 'checkroom';
    bool guardando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFAF6F0),
              title: Text(prod == null ? 'Nuevo Producto Sublimable' : 'Editar Producto Sublimable', style: const TextStyle(color: Color(0xFF0D2818), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa una descripción' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedIcon,
                        decoration: const InputDecoration(labelText: 'Icono'),
                        items: ['checkroom', 'checkroom_outlined', 'dry_cleaning', 'dry_cleaning_outlined', 'local_cafe', 'accessibility_new', 'child_care', 'opacity'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                        onChanged: (v) => setDialogState(() => selectedIcon = v!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: guardando ? null : () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => guardando = true);
                          try {
                            if (prod == null) {
                              await _orderService.crearProductoSublimable(
                                nombre: nameCtrl.text.trim(),
                                descripcion: descCtrl.text.trim(),
                                iconoName: selectedIcon,
                              );
                            } else {
                              await _orderService.actualizarProductoSublimable(
                                id: prod['id'] as int,
                                nombre: nameCtrl.text.trim(),
                                descripcion: descCtrl.text.trim(),
                                iconoName: selectedIcon,
                              );
                            }
                            await _cargarSublimables();
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            setDialogState(() => guardando = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red));
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2818), foregroundColor: Colors.white),
                  child: guardando ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminarSublimable(Map<String, dynamic> prod) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFAF6F0),
          title: const Text('Eliminar Producto', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('¿Deseas eliminar el producto "${prod['nombre']}" de la base de datos?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('No', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                try {
                  await _orderService.eliminarProductoSublimable(prod['id'] as int);
                  await _cargarSublimables();
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Sí, Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- TAB 3: DISEÑOS ---
  Widget _buildDisenosTab() {
    if (_cargandoDisenos) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D2818)));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D2818),
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormularioDiseno(null),
        child: const Icon(Icons.add),
      ),
      body: _disenos.isEmpty
          ? const Center(child: Text('No hay diseños de prendas creados.', style: TextStyle(color: Color(0xFF0D2818))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _disenos.length,
              itemBuilder: (context, index) {
                final dis = _disenos[index];
                final coleccionData = dis['colecciones'];
                final String colName = coleccionData != null ? coleccionData['nombre'] as String? ?? 'Desconocida' : 'Desconocida';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF5EDE3),
                      child: Icon(_getIconData(dis['icono_name'] ?? 'palette'), color: const Color(0xFF0D2818)),
                    ),
                    title: Text(dis['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2818))),
                    subtitle: Text(
                      'Colección: $colName\n${dis['descripcion'] ?? ''}',
                      style: const TextStyle(color: Color(0xFF4A5D4C), fontSize: 12),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _abrirFormularioDiseno(dis),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminarDiseno(dis),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _abrirFormularioDiseno(Map<String, dynamic>? dis) {
    if (_colecciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pueden crear diseños porque no existen colecciones. Carga el dashboard para autoinicializar.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: dis?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: dis?['descripcion'] ?? '');
    int? selectedColId = dis?['coleccion_id'] as int?;
    if (selectedColId == null && _colecciones.isNotEmpty) {
      selectedColId = _colecciones.first['id'] as int;
    }
    String selectedIcon = dis?['icono_name'] ?? 'palette';
    bool guardando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFAF6F0),
              title: Text(dis == null ? 'Nuevo Diseño' : 'Editar Diseño', style: const TextStyle(color: Color(0xFF0D2818), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: selectedColId,
                        decoration: const InputDecoration(labelText: 'Colección'),
                        items: _colecciones.map((c) {
                          return DropdownMenuItem<int>(
                            value: c['id'] as int,
                            child: Text(c['nombre']),
                          );
                        }).toList(),
                        onChanged: (v) => setDialogState(() => selectedColId = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa una descripción' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedIcon,
                        decoration: const InputDecoration(labelText: 'Icono'),
                        items: ['palette', 'landscape', 'landscape_outlined', 'coffee', 'coffee_maker', 'checkroom', 'checkroom_outlined', 'dry_cleaning'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                        onChanged: (v) => setDialogState(() => selectedIcon = v!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: guardando ? null : () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate() || selectedColId == null) return;
                          setDialogState(() => guardando = true);
                          try {
                            if (dis == null) {
                              await _orderService.crearDiseno(
                                nombre: nameCtrl.text.trim(),
                                descripcion: descCtrl.text.trim(),
                                coleccionId: selectedColId!,
                                iconoName: selectedIcon,
                              );
                            } else {
                              await _orderService.actualizarDiseno(
                                id: dis['id'] as int,
                                nombre: nameCtrl.text.trim(),
                                descripcion: descCtrl.text.trim(),
                                coleccionId: selectedColId!,
                                iconoName: selectedIcon,
                              );
                            }
                            await _cargarDisenos();
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            setDialogState(() => guardando = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red));
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2818), foregroundColor: Colors.white),
                  child: guardando ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminarDiseno(Map<String, dynamic> dis) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFAF6F0),
          title: const Text('Eliminar Diseño', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('¿Deseas eliminar el diseño "${dis['nombre']}" de la base de datos?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('No', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                try {
                  await _orderService.eliminarDiseno(dis['id'] as int);
                  await _cargarDisenos();
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Sí, Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
