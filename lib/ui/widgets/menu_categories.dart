import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

class MenuCategories extends StatefulWidget {
  @override
  _MenuCategoriesState createState() => _MenuCategoriesState();
}

class _MenuCategoriesState extends State<MenuCategories> {
  TextEditingController _textEditingController = TextEditingController();
  Timer? _timer;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _timer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    String jsonData = await rootBundle.loadString('assets/taxonomy.json');
    Map<String, dynamic> data = json.decode(jsonData);
    // Usa 'data' como objeto Dart
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
          hintText: 'Escribe aquí...',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _timer?.cancel();
          _timer = Timer(Duration(seconds: 2), () {
            _showPopupMenu(context);
          });
        },
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4.0,
          child: Column(
            children: [
              PopupMenuItem(
                child: Text('Opción 1'),
                onTap: () {
                  // Lógica cuando se selecciona la opción 1
                },
              ),
              PopupMenuItem(
                child: Text('Opción 2'),
                onTap: () {
                  // Lógica cuando se selecciona la opción 2
                },
              ),
              // Agregar más elementos del PopupMenu según sea necesario
            ],
          ),
        ),
      ),
    );
  }
}
