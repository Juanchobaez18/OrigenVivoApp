import 'package:flutter/material.dart';
import 'supabase_client.dart';

class OrderItem {
  final String id;
  final String tipo; // 'Bebidas y Alimentos' o 'Sublimación'
  final String nombre;
  final String detalle; // e.g. "Diseño: Boyacá" o "Cafetería Origen Vivo"
  final int cantidad;
  final double precio;
  final DateTime fecha;
  String estado; // 'Pendiente', 'Preparando', 'Completado', 'Cancelado'
  final String? clienteNombre;
  final String? clienteEmail;

  OrderItem({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.detalle,
    required this.cantidad,
    required this.precio,
    required this.fecha,
    this.estado = 'Pendiente',
    this.clienteNombre,
    this.clienteEmail,
  });
}

class OrderService {
  // Singleton pattern
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;

  OrderService._internal() {
    // Carga inicial asíncrona de pedidos desde Supabase e inicialización de datos
    _inicializarApp();
  }

  Future<void> _inicializarApp() async {
    await cargarPedidosDesdeDB();
    await inicializarDatosPredeterminados();
  }

  final List<OrderItem> _pedidos = [];
  final List<Map<String, dynamic>> _carritoCafe = [];
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  List<OrderItem> get pedidos => List.unmodifiable(_pedidos);
  List<Map<String, dynamic>> get carritoCafe => List.unmodifiable(_carritoCafe);

  // Cargar pedidos desde la Base de Datos de Supabase con información de perfiles
  Future<void> cargarPedidosDesdeDB() async {
    try {
      final response = await supabase
          .from('pedido_detalles')
          .select('*, pedidos(*, perfiles(*))');

      final List<OrderItem> dbItems = [];
      for (final row in response) {
        final parent = row['pedidos'];
        if (parent == null) continue;
        final perfil = parent['perfiles'];
        final String? clNombre = perfil != null ? perfil['nombre'] as String? : null;
        final String? clEmail = perfil != null ? perfil['email'] as String? : null;

        dbItems.add(
          OrderItem(
            id: row['id'].toString(),
            tipo: parent['tipo'] as String? ?? 'Bebidas y Alimentos',
            nombre: row['nombre_producto'] as String? ?? '',
            detalle: row['detalle_personalizacion'] as String? ?? '',
            cantidad: row['cantidad'] as int? ?? 1,
            precio: (row['precio_unitario'] as num? ?? 0.0).toDouble(),
            fecha: DateTime.tryParse(parent['fecha'] as String? ?? '') ?? DateTime.now(),
            estado: parent['estado'] as String? ?? 'Pendiente',
            clienteNombre: clNombre,
            clienteEmail: clEmail,
          ),
        );
      }
      _pedidos.clear();
      _pedidos.addAll(dbItems);
      _notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar pedidos de Supabase: $e');
    }
  }

  // Módulo Café: Agregar al carrito
  void agregarAlCarritoCafe(Map<String, dynamic> item) {
    final index = _carritoCafe.indexWhere((element) => element['nombre'] == item['nombre']);
    if (index != -1) {
      _carritoCafe[index]['cantidad'] += item['cantidad'];
    } else {
      _carritoCafe.add(Map<String, dynamic>.from(item));
    }
    _notifyListeners();
  }

  // Módulo Café: Quitar del carrito
  void quitarDelCarritoCafe(String nombre) {
    _carritoCafe.removeWhere((element) => element['nombre'] == nombre);
    _notifyListeners();
  }

  // Módulo Café: Limpiar carrito
  void limpiarCarritoCafe() {
    _carritoCafe.clear();
    _notifyListeners();
  }

  // Registrar pedido de Sublimación en la Base de Datos
  Future<OrderItem?> registrarPedidoSublimacion({
    required String producto,
    required String diseno,
    required double precio,
  }) async {
    try {
      final pedidoId = 'SUB-${DateTime.now().millisecondsSinceEpoch}';
      final userId = supabase.auth.currentUser?.id;

      // 1. Insertar en tabla principal de pedidos
      await supabase.from('pedidos').insert({
        'id': pedidoId,
        'user_id': userId,
        'tipo': 'Sublimación',
        'estado': 'Pendiente',
        'total': precio,
      });

      // 2. Insertar en detalles del pedido
      final responseDetalle = await supabase.from('pedido_detalles').insert({
        'pedido_id': pedidoId,
        'nombre_producto': producto,
        'detalle_personalizacion': diseno,
        'cantidad': 1,
        'precio_unitario': precio,
      }).select();

      // 3. Sincronizar UI cargando de Supabase
      await cargarPedidosDesdeDB();

      if (responseDetalle.isNotEmpty) {
        final insertedRow = responseDetalle.first;
        final detailId = insertedRow['id'].toString();
        
        final match = _pedidos.firstWhere(
          (p) => p.id == detailId,
          orElse: () => OrderItem(
            id: detailId,
            tipo: 'Sublimación',
            nombre: producto,
            detalle: diseno,
            cantidad: 1,
            precio: precio,
            fecha: DateTime.now(),
            estado: 'Pendiente',
          ),
        );
        return match;
      }
    } catch (e) {
      debugPrint('Error al registrar pedido de sublimación: $e');
    }
    return null;
  }

  Future<void> realizarCheckoutCafe([String? observaciones]) async {
    if (_carritoCafe.isEmpty) return;

    try {
      final pedidoId = 'CAF-${DateTime.now().millisecondsSinceEpoch}';
      final userId = supabase.auth.currentUser?.id;
      
      double total = 0.0;
      for (final item in _carritoCafe) {
        total += (item['precio'] as double) * (item['cantidad'] as int);
      }

      // 1. Insertar el Pedido principal
      await supabase.from('pedidos').insert({
        'id': pedidoId,
        'user_id': userId,
        'tipo': 'Bebidas y Alimentos',
        'estado': 'Pendiente',
        'total': total,
      });

      final String detalleFinal = (observaciones != null && observaciones.trim().isNotEmpty)
          ? 'Cafetería Origen Vivo | Obs: ${observaciones.trim()}'
          : 'Cafetería Origen Vivo';

      // 2. Insertar los Detalles de cada producto del carrito
      for (final item in _carritoCafe) {
        await supabase.from('pedido_detalles').insert({
          'pedido_id': pedidoId,
          'nombre_producto': item['nombre'] as String,
          'detalle_personalizacion': detalleFinal,
          'cantidad': item['cantidad'] as int,
          'precio_unitario': item['precio'] as double,
        });
      }

      limpiarCarritoCafe();

      // 3. Sincronizar UI cargando de Supabase
      await cargarPedidosDesdeDB();
    } catch (e) {
      debugPrint('Error al realizar checkout de café: $e');
    }
  }

  // Funciones de Administración: Actualizar estado en la base de datos
  Future<void> actualizarEstadoPedido(String id, String nuevoEstado) async {
    try {
      // Buscar el pedido_id al que pertenece este detalle
      final res = await supabase
          .from('pedido_detalles')
          .select('pedido_id')
          .eq('id', int.parse(id))
          .maybeSingle();

      if (res != null && res['pedido_id'] != null) {
        final String pid = res['pedido_id'] as String;
        
        // Actualizar el estado en la tabla pedidos
        await supabase
            .from('pedidos')
            .update({'estado': nuevoEstado})
            .eq('id', pid);

        // Recargar pedidos
        await cargarPedidosDesdeDB();
      }
    } catch (e) {
      debugPrint('Error al actualizar estado del pedido: $e');
    }
  }

  // Funciones de Administración: Eliminar pedido de la base de datos
  Future<void> eliminarPedido(String id) async {
    try {
      final res = await supabase
          .from('pedido_detalles')
          .select('pedido_id')
          .eq('id', int.parse(id))
          .maybeSingle();

      if (res != null && res['pedido_id'] != null) {
        final String pid = res['pedido_id'] as String;

        // Eliminar de pedidos (eliminará en cascada los detalles)
        await supabase
            .from('pedidos')
            .delete()
            .eq('id', pid);

        // Recargar pedidos
        await cargarPedidosDesdeDB();
      }
    } catch (e) {
      debugPrint('Error al eliminar pedido de la DB: $e');
    }
  }

  // --- CRUD PRODUCTOS CAFETERÍA ---
  Future<void> crearProductoCafe({
    required String nombre,
    required String categoria,
    required String descripcion,
    required double precio,
    required String iconoName,
  }) async {
    await supabase.from('productos_cafe').insert({
      'nombre': nombre,
      'categoria': categoria,
      'descripcion': descripcion,
      'precio': precio,
      'icono_name': iconoName,
    });
  }

  Future<void> actualizarProductoCafe({
    required int id,
    required String nombre,
    required String categoria,
    required String descripcion,
    required double precio,
    required String iconoName,
  }) async {
    await supabase.from('productos_cafe').update({
      'nombre': nombre,
      'categoria': categoria,
      'descripcion': descripcion,
      'precio': precio,
      'icono_name': iconoName,
    }).eq('id', id);
  }

  Future<void> eliminarProductoCafe(int id) async {
    await supabase.from('productos_cafe').delete().eq('id', id);
  }

  // --- CRUD PRODUCTOS SUBLIMABLES ---
  Future<void> crearProductoSublimable({
    required String nombre,
    required String descripcion,
    required String iconoName,
  }) async {
    await supabase.from('productos_sublimables').insert({
      'nombre': nombre,
      'descripcion': descripcion,
      'icono_name': iconoName,
    });
  }

  Future<void> actualizarProductoSublimable({
    required int id,
    required String nombre,
    required String descripcion,
    required String iconoName,
  }) async {
    await supabase.from('productos_sublimables').update({
      'nombre': nombre,
      'descripcion': descripcion,
      'icono_name': iconoName,
    }).eq('id', id);
  }

  Future<void> eliminarProductoSublimable(int id) async {
    await supabase.from('productos_sublimables').delete().eq('id', id);
  }

  // --- CRUD DISEÑOS ---
  Future<void> crearDiseno({
    required String nombre,
    required String descripcion,
    required int coleccionId,
    required String iconoName,
  }) async {
    await supabase.from('disenos').insert({
      'nombre': nombre,
      'descripcion': descripcion,
      'coleccion_id': coleccionId,
      'icono_name': iconoName,
    });
  }

  Future<void> actualizarDiseno({
    required int id,
    required String nombre,
    required String descripcion,
    required int coleccionId,
    required String iconoName,
  }) async {
    await supabase.from('disenos').update({
      'nombre': nombre,
      'descripcion': descripcion,
      'coleccion_id': coleccionId,
      'icono_name': iconoName,
    }).eq('id', id);
  }

  Future<void> eliminarDiseno(int id) async {
    await supabase.from('disenos').delete().eq('id', id);
  }

  // --- INICIALIZACIÓN DE DATOS PREDETERMINADOS ---
  Future<void> inicializarDatosPredeterminados() async {
    try {
      final cols = await supabase.from('colecciones').select();
      if (cols.isEmpty) {
        final List<Map<String, dynamic>> coleccionesFicticias = [
          {'nombre': 'Boyacá', 'descripcion': 'Diseños tradicionales del departamento de Boyacá'},
          {'nombre': 'Café', 'descripcion': 'Diseños inspirados en la cultura cafetera'},
          {'nombre': 'Amor', 'descripcion': 'Diseños románticos y afectuosos'},
          {'nombre': 'Mascotas', 'descripcion': 'Diseños divertidos para amantes de las mascotas'},
          {'nombre': 'Infantil', 'descripcion': 'Diseños infantiles y coloridos'},
          {'nombre': 'Empresas', 'descripcion': 'Diseños corporativos y de marcas'},
          {'nombre': 'Temporadas', 'descripcion': 'Diseños especiales de festividades'},
        ];

        final List<dynamic> insertedCols = await supabase
            .from('colecciones')
            .insert(coleccionesFicticias)
            .select();

        if (insertedCols.isNotEmpty) {
          final List<Map<String, dynamic>> disenosIniciales = [];
          for (final col in insertedCols) {
            final colId = col['id'] as int;
            final colNombre = col['nombre'] as String;

            if (colNombre == 'Boyacá') {
              disenosIniciales.addAll([
                {
                  'nombre': 'MÁS BOYACENSE QUE LA RUANA',
                  'descripcion': 'Diseño tradicional campesino con ruana y sombrero',
                  'coleccion_id': colId,
                  'icono_name': 'landscape_outlined',
                },
                {
                  'nombre': 'TUMBA EL MONTE',
                  'descripcion': 'Ilustración del campo y la labranza boyacense',
                  'coleccion_id': colId,
                  'icono_name': 'landscape',
                },
              ]);
            } else if (colNombre == 'Café') {
              disenosIniciales.addAll([
                {
                  'nombre': 'AMO EL CAFÉ',
                  'descripcion': 'Diseño minimalista con grano y taza de café caliente',
                  'coleccion_id': colId,
                  'icono_name': 'coffee',
                },
                {
                  'nombre': 'ORIGEN ARTESANAL',
                  'descripcion': 'Diseño de prensa francesa y granos tostados',
                  'coleccion_id': colId,
                  'icono_name': 'coffee_maker',
                },
              ]);
            } else {
              disenosIniciales.add({
                'nombre': 'DISEÑO GENÉRICO DE ${colNombre.toUpperCase()}',
                'descripcion': 'Estilo estético de la colección $colNombre',
                'coleccion_id': colId,
                'icono_name': 'checkroom',
              });
            }
          }
          await supabase.from('disenos').insert(disenosIniciales);
        }
      }

      // Inicializar productos de cafetería por defecto
      final cafeProds = await supabase.from('productos_cafe').select();
      if (cafeProds.isEmpty) {
        final List<Map<String, dynamic>> cafeIniciales = [
          {
            'nombre': 'Espresso Origen',
            'categoria': 'Bebidas Calientes',
            'descripcion': 'Café intenso elaborado con granos seleccionados',
            'precio': 5000.0,
            'icono_name': 'coffee',
          },
          {
            'nombre': 'Cappuccino de la Casa',
            'categoria': 'Bebidas Calientes',
            'descripcion': 'Espresso con leche emulsionada y toque de canela',
            'precio': 7500.0,
            'icono_name': 'coffee_maker',
          },
          {
            'nombre': 'Latte Vainilla',
            'categoria': 'Bebidas Calientes',
            'descripcion': 'Café suave con leche cremosa y esencia de vainilla',
            'precio': 8000.0,
            'icono_name': 'coffee',
          },
          {
            'nombre': 'Cold Brew Frutos Rojos',
            'categoria': 'Bebidas Frías',
            'descripcion': 'Café extraído en frío por 12 horas con notas frutales',
            'precio': 8500.0,
            'icono_name': 'local_drink',
          },
          {
            'nombre': 'Croissant de Almendras',
            'categoria': 'Alimentos',
            'descripcion': 'Hojaldre crujiente relleno de crema de almendras',
            'precio': 6500.0,
            'icono_name': 'bakery_dining',
          },
          {
            'nombre': 'Muffin de Arándanos',
            'categoria': 'Alimentos',
            'descripcion': 'Esponjoso panecillo con arándanos frescos',
            'precio': 5000.0,
            'icono_name': 'cake',
          },
        ];
        await supabase.from('productos_cafe').insert(cafeIniciales);
      }

      // Inicializar productos sublimables por defecto
      final subProds = await supabase.from('productos_sublimables').select();
      if (subProds.isEmpty) {
        final List<Map<String, dynamic>> subIniciales = [
          {
            'nombre': 'Mugs 6 oz',
            'descripcion': 'Taza pequeña de cerámica ideal para espresso',
            'icono_name': 'local_cafe_outlined',
          },
          {
            'nombre': 'Mugs 12 oz',
            'descripcion': 'Taza estándar de cerámica para bebidas calientes',
            'icono_name': 'local_cafe',
          },
          {
            'nombre': 'Vaso térmico',
            'descripcion': 'Vaso de acero térmico de viaje',
            'icono_name': 'coffee_maker_outlined',
          },
          {
            'nombre': 'Mágico',
            'descripcion': 'Taza especial que cambia de color con calor',
            'icono_name': 'opacity',
          },
          {
            'nombre': 'Buso',
            'descripcion': 'Buso o sudadera de algodón de alta calidad',
            'icono_name': 'checkroom',
          },
          {
            'nombre': 'Camiseta básica',
            'descripcion': 'Camiseta de algodón básica y fresca',
            'icono_name': 'dry_cleaning',
          },
        ];
        await supabase.from('productos_sublimables').insert(subIniciales);
      }
    } catch (e) {
      debugPrint('Error al inicializar datos predeterminados: $e');
    }
  }
}

