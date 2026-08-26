import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'preview_screen.dart';

enum ActiveElement { text, image }

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
  final TextEditingController _textController = TextEditingController(text: 'Mi Texto');
  final TextEditingController _observacionesController = TextEditingController();
  Color _selectedColor = const Color(0xFF0E3821);
  String _selectedFont = 'Inter';

  @override
  void dispose() {
    _textController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // --- COORDENADAS Y ESCALA DEL CANVAS ---
  ActiveElement _activeElement = ActiveElement.text;
  String? _customImageBase64;

  // Texto
  Offset _textOffset = const Offset(80, 120);
  double _textScale = 1.0;
  double _textRotation = 0.0; // en radianes

  // Imagen subida
  Offset _imageOffset = const Offset(80, 60);
  double _imageScale = 1.0;
  double _imageRotation = 0.0; // en radianes

  final List<Color> _availableColors = [
    const Color(0xFF0E3821), // Verde
    const Color(0xFF8B5E34), // Café
    const Color(0xFFD32F2F), // Rojo
    const Color(0xFF1976D2), // Azul
    const Color(0xFFF57C00), // Naranja
    const Color(0xFF388E3C), // Verde Claro
    const Color(0xFF000000), // Negro
    const Color(0xFFFFFFFF), // Blanco
  ];

  final List<String> _availableFonts = [
    'Inter',
    'Playfair Display',
    'Pacifico',
    'Montserrat',
  ];

  IconData _getProductIcon() {
    final String prod = widget.productoSeleccionado.toLowerCase();
    if (prod.contains('mug') || prod.contains('taza') || prod.contains('vaso')) {
      return Icons.local_cafe;
    }
    return Icons.checkroom;
  }

  Future<void> _subirImagenPropia() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _customImageBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
          _activeElement = ActiveElement.image;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Imagen cargada! Arrástrala en el lienzo para posicionarla.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar imagen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  ImageProvider? _obtenerImageProvider(String base64Str) {
    try {
      final base64String = base64Str.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } catch (_) {
      return null;
    }
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
        title: const Text(
          'Personalización Canvas 2D',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Playfair Display',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- LIENZO INTERACTIVO 2D ---
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2D2C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF3E3D3C), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // 1. Silueta de Prenda/Mug fija al fondo
                      Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            _getProductIcon(),
                            size: 180,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Indicador de selección activa
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA26334).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA26334), width: 0.5),
                          ),
                          child: Text(
                            'Editando: ${_activeElement == ActiveElement.text ? "Texto" : "Imagen"}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      // 2. Elemento: Imagen Subida (Draggable)
                      if (_customImageBase64 != null)
                        Positioned(
                          left: _imageOffset.dx,
                          top: _imageOffset.dy,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeElement = ActiveElement.image;
                              });
                            },
                            onPanUpdate: (details) {
                              setState(() {
                                _activeElement = ActiveElement.image;
                                _imageOffset = Offset(
                                  _imageOffset.dx + details.delta.dx,
                                  _imageOffset.dy + details.delta.dy,
                                );
                              });
                            },
                            child: Transform.rotate(
                              angle: _imageRotation,
                              child: Transform.scale(
                                scale: _imageScale,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _activeElement == ActiveElement.image
                                          ? const Color(0xFFA26334)
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image(
                                    image: _obtenerImageProvider(_customImageBase64!)!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // 3. Elemento: Texto (Draggable)
                      Positioned(
                        left: _textOffset.dx,
                        top: _textOffset.dy,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeElement = ActiveElement.text;
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _activeElement = ActiveElement.text;
                              _textOffset = Offset(
                                _textOffset.dx + details.delta.dx,
                                _textOffset.dy + details.delta.dy,
                              );
                            });
                          },
                          child: Transform.rotate(
                            angle: _textRotation,
                            child: Transform.scale(
                              scale: _textScale,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _activeElement == ActiveElement.text
                                        ? const Color(0xFFA26334)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _textController.text.isEmpty ? 'Escribe aquí' : _textController.text,
                                  style: TextStyle(
                                    color: _selectedColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: _selectedFont,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- BOTÓN DE SUBIDA ---
            OutlinedButton.icon(
              onPressed: _subirImagenPropia,
              icon: const Icon(Icons.upload, color: Color(0xFFA26334)),
              label: const Text('Subir Imagen Propia (.png / .jpg)', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFA26334)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // --- CONTROLES DE ESCALA Y ROTACIÓN ---
            const Text('Ajustes del elemento seleccionado', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Selector de elemento activo si hay una imagen
            if (_customImageBase64 != null) ...[
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Texto'),
                      selected: _activeElement == ActiveElement.text,
                      onSelected: (val) => setState(() => _activeElement = ActiveElement.text),
                      selectedColor: const Color(0xFFA26334),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Imagen'),
                      selected: _activeElement == ActiveElement.image,
                      onSelected: (val) => setState(() => _activeElement = ActiveElement.image),
                      selectedColor: const Color(0xFFA26334),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Slider de Tamaño
            Row(
              children: [
                const Text('Tamaño:  ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _activeElement == ActiveElement.text ? _textScale : _imageScale,
                    min: 0.5,
                    max: 2.5,
                    activeColor: const Color(0xFFA26334),
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      setState(() {
                        if (_activeElement == ActiveElement.text) {
                          _textScale = val;
                        } else {
                          _imageScale = val;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            // Slider de Rotación
            Row(
              children: [
                const Text('Rotación:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _activeElement == ActiveElement.text ? _textRotation : _imageRotation,
                    min: -3.1416, // -180 grados
                    max: 3.1416,  // 180 grados
                    activeColor: const Color(0xFFA26334),
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      setState(() {
                        if (_activeElement == ActiveElement.text) {
                          _textRotation = val;
                        } else {
                          _imageRotation = val;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 30),

            // --- SECCIÓN TEXTO ---
            const Text(
              'Texto Personalizado',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2E2D2C),
                hintText: 'Ingresa el texto a estampar',
                hintStyle: const TextStyle(color: Colors.white30),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF3E3D3C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFA26334)),
                ),
              ),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 20),

            const Text(
              'Observaciones adicionales para producción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _observacionesController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2E2D2C),
                hintText: 'Ej: Empacar para regalo, centrar el estampado, etc.',
                hintStyle: const TextStyle(color: Colors.white30),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF3E3D3C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFA26334)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Colores
            const Text('Color del Texto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final esSeleccionado = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: esSeleccionado ? const Color(0xFFA26334) : Colors.white24,
                          width: esSeleccionado ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Tipografía
            const Text('Tipografía del Texto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedFont,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2E2D2C),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF3E3D3C)),
                ),
              ),
              dropdownColor: const Color(0xFF2E2D2C),
              style: const TextStyle(color: Colors.white),
              items: _availableFonts.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) => setState(() => _selectedFont = v!),
            ),
            const SizedBox(height: 40),

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
                      observacionesCliente: _observacionesController.text,
                      colorTexto: _selectedColor,
                      fuenteTexto: _selectedFont,
                      alineacionTexto: TextAlign.center,
                      customImageBase64: _customImageBase64,
                      textX: _textOffset.dx,
                      textY: _textOffset.dy,
                      textScale: _textScale,
                      textRotation: _textRotation,
                      imageX: _imageOffset.dx,
                      imageY: _imageOffset.dy,
                      imageScale: _imageScale,
                      imageRotation: _imageRotation,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA26334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ver Vista Previa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}
