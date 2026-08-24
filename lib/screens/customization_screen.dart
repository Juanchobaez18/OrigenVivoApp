import 'package:flutter/material.dart';
import 'preview_screen.dart';

class CustomizationScreen extends StatefulWidget {
  final String productoSeleccionado;
  final String disenoSeleccionado;
  final String coleccion;

  const CustomizationScreen({
    super.key,
    required this.productoSeleccionado,
    required this.disenoSeleccionado,
    required this.coleccion,
  });

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  final TextEditingController _textController = TextEditingController();
  Color _selectedColor = const Color(0xFF0E3821);
  String _selectedFont = 'Inter';
  TextAlign _selectedAlignment = TextAlign.center;

  final List<Color> _availableColors = [
    const Color(0xFF0E3821), // Dark Green
    const Color(0xFF8B5E34), // Coffee Brown
    const Color(0xFFD32F2F), // Red
    const Color(0xFF1976D2), // Blue
    const Color(0xFFF57C00), // Orange
    const Color(0xFF388E3C), // Green
    const Color(0xFF000000), // Black
  ];

  final List<String> _availableFonts = [
    'Inter',
    'Playfair Display',
    'Pacifico',
    'Montserrat',
  ];

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
        title: const Text(
          'Personalización',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Playfair Display',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen de selección
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2D2C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3E3D3C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalles de tu base:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA26334),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Color(0xFFA26334), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Producto: ${widget.productoSeleccionado}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.color_lens_outlined, color: Color(0xFFA26334), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Diseño/Plantilla: ${widget.disenoSeleccionado} (${widget.coleccion})',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB7B7B6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Sección 1: Texto personalizado
            const Text(
              'Texto Personalizado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Agrega un nombre, fecha, dedicatoria o frase especial.',
              style: TextStyle(fontSize: 13, color: Color(0xFFB7B7B6)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej. Juan Pérez - 2026',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                fillColor: const Color(0xFF2E2D2C),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF3E3D3C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFA26334), width: 1.5),
                ),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
            const SizedBox(height: 28),

            // Sección 2: Color de letra
            const Text(
              'Color del Texto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 14),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Sección 3: Fuente / Tipografía
            const Text(
              'Tipografía',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableFonts.map((font) {
                final isSelected = font == _selectedFont;
                return ChoiceChip(
                  label: Text(
                    font,
                    style: TextStyle(
                      fontFamily: font == 'Inter' ? null : font,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFFB7B7B6),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFA26334),
                  backgroundColor: const Color(0xFF2E2D2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFF3E3D3C)),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFont = font;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Sección 4: Alineación del texto
            const Text(
              'Alineación del Texto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAlignButton(TextAlign.left, Icons.format_align_left),
                const SizedBox(width: 12),
                _buildAlignButton(TextAlign.center, Icons.format_align_center),
                const SizedBox(width: 12),
                _buildAlignButton(TextAlign.right, Icons.format_align_right),
              ],
            ),
            const SizedBox(height: 48),

            // Botón de continuar
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(
                      productoSeleccionado: widget.productoSeleccionado,
                      disenoSeleccionado: widget.disenoSeleccionado,
                      coleccion: widget.coleccion,
                      textoPersonalizado: _textController.text,
                      colorTexto: _selectedColor,
                      fuenteTexto: _selectedFont,
                      alineacionTexto: _selectedAlignment,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA26334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver Vista Previa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignButton(TextAlign alignment, IconData icon) {
    final isSelected = _selectedAlignment == alignment;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAlignment = alignment;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA26334) : const Color(0xFF2E2D2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFA26334) : const Color(0xFF3E3D3C),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : const Color(0xFFB7B7B6),
          ),
        ),
      ),
    );
  }
}
