import 'package:flutter/material.dart';

typedef SelectedChipsCallback = void Function(List<String> selectedChips);

class SimpleFilterChips extends StatefulWidget {
  final List<dynamic> chipLabels;
  final SelectedChipsCallback onSelectionChanged;

  SimpleFilterChips(
      {required this.chipLabels, required this.onSelectionChanged});

  @override
  _SimpleFilterChipsState createState() => _SimpleFilterChipsState();
}

class _SimpleFilterChipsState extends State<SimpleFilterChips> {
  late List<Map<String, dynamic>> chipList;

  @override
  void initState() {
    super.initState();
    _prepareChipList();
  }

  void _prepareChipList() {
    chipList = widget.chipLabels.map((label) {
      return {
        'label': label,
        'active': false,
      };
    }).toList();
    print("aqui> $chipList");
  }

  void _onChipTapped(int index) {
    setState(() {
      chipList[index]['active'] = !chipList[index]['active']!;

      // Aquí, después de cambiar el estado del chip,
      // vamos a notificar a la clase padre sobre los chips que están activos.
      List<String> selectedChips = chipList
          .where((chip) => chip['active'] as bool)
          .map((chip) => chip['label'] as String)
          .toList();

      widget.onSelectionChanged(selectedChips); // <-- Añadir esta línea
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chipList.length,
      itemBuilder: (context, index) {
        var chip = chipList[index];
        return Container(
          padding: EdgeInsets.all(5.0),
          child: FilterChip(
            backgroundColor: Color.fromARGB(255, 110, 106, 106),
            selectedColor: Colors.green,
            label: Text(
              chip['label'],
              style: const TextStyle(color: Colors.white),
            ),
            selected: chip['active']!,
            onSelected: (bool selected) {
              _onChipTapped(index);
            },
          ),
        );
      },
    );
  }
}
