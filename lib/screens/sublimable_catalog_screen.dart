import 'package:flutter/material.dart';
import 'sublimable_products_screen.dart';

class SublimableCategory {
  final String nombre;
  final String descripcion;
  final IconData icono;
  final String tag;

  SublimableCategory({
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.tag,
  });
}

class SublimableCatalogScreen extends StatelessWidget {
  const SublimableCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SublimableCategory> categorias = [
      SublimableCategory(
        nombre: 'Tazas y Vasos',
        descripcion: 'Mugs de cerámica, termos y vasos de acero',
        icono: Icons.local_cafe,
        tag: 'tazas',
      ),
      SublimableCategory(
        nombre: 'Prendas y Ropa',
        descripcion: 'Busos, camisetas de algodón, oversize y para niños',
        icono: Icons.checkroom,
        tag: 'ropa',
      ),
      SublimableCategory(
        nombre: 'Accesorios',
        descripcion: 'Otros productos sublimables y recuerdos',
        icono: Icons.backpack,
        tag: 'accesorios',
      ),
    ];

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
          'Catálogo de Sublimables',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Playfair Display',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Elige una Categoría',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora nuestra selección de productos listos para personalizar con el diseño de tu preferencia.',
              style: TextStyle(fontSize: 14, color: Color(0xFFB7B7B6)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final cat = categorias[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: const Color(0xFF2E2D2C),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SublimableProductsScreen(
                              categoriaFiltro: cat.tag,
                              categoriaNombre: cat.nombre,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E3D3C),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                cat.icono,
                                size: 36,
                                color: const Color(0xFFA26334),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.nombre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat.descripcion,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFB7B7B6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFFA26334),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
