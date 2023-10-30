import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:frontend/connections/connections.dart';

typedef SelectedChipsCallback = void Function(List<String> selectedChips);

class CustomFilterChips extends StatefulWidget {
  final List<dynamic> accessTemp;
  final Map<String, dynamic> accessGeneralofRol;
  final Function loadData;
  final String idUser;
  final SelectedChipsCallback? onSelectionChanged;

  CustomFilterChips({
    required this.accessTemp,
    required this.accessGeneralofRol,
    required this.loadData,
    required this.idUser,
    this.onSelectionChanged,
  }) : assert(accessTemp != null && accessGeneralofRol != null);

  @override
  _CustomFilterChips createState() => _CustomFilterChips();
}

class _CustomFilterChips extends State<CustomFilterChips> {
  List<Map<String, dynamic>> chipList = [];

  @override
  void initState() {
    super.initState();
    // if (widget.accessTemp.isEmpty || widget.accessGeneralofRol.isEmpty) {
    //   // Puedes mostrar un mensaje de error o manejar esta situación de otra manera.
    //   return;
    // }
    _prepareChipList();
  }

  @override
  void didUpdateWidget(CustomFilterChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accessTemp != widget.accessTemp ||
        oldWidget.accessGeneralofRol != widget.accessGeneralofRol) {
      _prepareChipList();
    }
  }

  void _prepareChipList() {
    for (var viewName in widget.accessTemp) {
      chipList.add({
        'view_name': viewName,
        'active': true,
      });
    }

    List<Map<String, dynamic>> generalViews;
    if (widget.accessGeneralofRol['accesos'] != null) {
      generalViews = List<Map<String, dynamic>>.from(
          jsonDecode(widget.accessGeneralofRol['accesos']));
    } else {
      generalViews = [];
    }

    for (var view in generalViews) {
      String viewName = view['view_name'] as String;

      if (!chipList.any((chip) => chip['view_name'] == viewName)) {
        chipList.add({
          'view_name': viewName,
          'active': false,
        });
      }
    }
  }

  Future<void> _onChipTapped(String viewName, bool activeStatus) async {
    await _managePermission(widget.idUser, viewName, activeStatus);

    setState(() {
      int chipIndex =
          chipList.indexWhere((item) => item['view_name'] == viewName);
      if (chipIndex != -1) {
        chipList[chipIndex]['active'] = !activeStatus; // Cambiamos el estado
      }
    });
    // Obtiene los nombres de vista activos y llama al callback
    // Obtiene los nombres de vista activos y llama al callback si no es nulo
    List<String> selectedViews = chipList
        .where((chip) => chip['active'] as bool)
        .map((chip) => chip['view_name'] as String)
        .toList();

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(selectedViews);
    }
  }

  Future<void> _managePermission(
      String userId, String viewName, bool activeStatus) async {
    try {
      // Si el chip está activo, significa que el usuario está quitando el permiso, así que lo enviamos a la API para que lo maneje.
      // Si el chip no está activo, significa que el usuario está agregando el permiso, así que también lo enviamos a la API.
      await Connections().managePermission(userId, viewName);
    } catch (error) {
      print('Error managing permission: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (chipList.isEmpty) {
      return Center(child: Text('No hay datos disponibles.'));
    }
    return ListView.builder(
      itemCount: chipList.length,
      itemBuilder: (context, index) {
        var chip = chipList[index];
        return Container(
          key: ValueKey(chip['view_name']), // Añadir una clave única
          padding: EdgeInsets.all(5.0),
          child: FilterChip(
            backgroundColor: Color.fromARGB(255, 110, 106, 106),
            selectedColor: Colors.green,
            label: Text(
              chip['view_name'] ?? 'Default',
              style: const TextStyle(color: Colors.white),
            ),
            selected: chip['active'],
            onSelected: (bool selected) {
              _onChipTapped(chip['view_name'] ?? 'Default', chip['active']);
            },
          ),
        );
      },
    );
  }
}
