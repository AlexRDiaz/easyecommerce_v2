import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchMenu extends StatefulWidget {
  final Function(String) onItemSelected;

  const SearchMenu({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  _SearchMenuState createState() => _SearchMenuState();
}

class _SearchMenuState extends State<SearchMenu> {
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _timer;
  List<String> _filteredData = [];
  List<dynamic> data = [];
  String? _dropdownValue;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    String jsonData = await rootBundle.loadString('assets/taxonomy3.json');
    data = json.decode(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Buscar Categoría...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0), // Reduce la altura del TextField
                suffixIcon: _textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _textEditingController.clear();
                            _filteredData.clear();
                            _dropdownValue = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _timer?.cancel();
                _timer = Timer(const Duration(seconds: 2), () {
                  setState(() {
                    _filteredData = searchInJson(value);
                  });
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          width: 280, // Ancho fijo para el DropdownButton
          child: DropdownButton<String>(
            isExpanded: true,
            value: _dropdownValue,
            onChanged: (String? newValue) {
              setState(() {
                _dropdownValue = newValue;
              });
              widget.onItemSelected(newValue!);
            },
            items: _filteredData.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(" - ${value.split('-')[0]}"),
              );
            }).toList(),
            icon: Icon(Icons.arrow_drop_down,
                color: ColorsSystem().colorSelectMenu),
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ), // Personaliza la flecha aquí
          ),
        ),
      ],
    );
  }

  List<String> searchInJson(String searchValue) {
    List<String> items = [];
    for (var item in data) {
      var lastKey = item.keys.last;
      if (item[lastKey]
          .toString()
          .toLowerCase()
          .contains(searchValue.toLowerCase())) {
        String menuItemLabel = "${item[lastKey]}-${item['id']}";
        items.add(menuItemLabel);
      }
    }
    return items;
  }
}
