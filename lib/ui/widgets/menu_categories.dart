import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

class MenuCategories extends StatefulWidget {
  @override
  _MenuCategoriesState createState() => _MenuCategoriesState();
}

enum SampleItem { itemOne, itemTwo, itemThree }

class _MenuCategoriesState extends State<MenuCategories> {
  TextEditingController _textEditingController = TextEditingController();
  Timer? _timer;
  OverlayEntry? _overlayEntry;
  SampleItem? selectedMenu;

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
      child: Center(
        child: PopupMenuButton<SampleItem>(
          initialValue: selectedMenu,
          // Callback that sets the selected popup menu item.
          onSelected: (SampleItem item) {
            setState(() {
              selectedMenu = item;
            });
          },
          child: TextField(),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
            const PopupMenuItem<SampleItem>(
              value: SampleItem.itemOne,
              child: Text('Item 1'),
            ),
            const PopupMenuItem<SampleItem>(
              value: SampleItem.itemTwo,
              child: Text('Item 2'),
            ),
            const PopupMenuItem<SampleItem>(
              value: SampleItem.itemThree,
              child: Text('Item 3'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    if (_overlayEntry != null) return;

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          child: Material(
            elevation: 4.0,
            child: Center(
              child: PopupMenuButton<SampleItem>(
                initialValue: selectedMenu,
                // Callback that sets the selected popup menu item.
                onSelected: (SampleItem item) {
                  setState(() {
                    selectedMenu = item;
                  });
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<SampleItem>>[
                  const PopupMenuItem<SampleItem>(
                    value: SampleItem.itemOne,
                    child: Text('Item 1'),
                  ),
                  const PopupMenuItem<SampleItem>(
                    value: SampleItem.itemTwo,
                    child: Text('Item 2'),
                  ),
                  const PopupMenuItem<SampleItem>(
                    value: SampleItem.itemThree,
                    child: Text('Item 3'),
                  ),
                ],
              ),
            ),
          )),
    );

    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _dismissPopupMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
