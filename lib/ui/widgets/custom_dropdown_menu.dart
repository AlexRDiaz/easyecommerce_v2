import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatefulWidget {
  final List items;
  final String hintText;
  final Function(String) onValueChanged;

  const CustomDropdownMenu({
    Key? key,
    required this.items,
    required this.hintText,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  String _selectedValue = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.2,
        child: DropdownButton<String>(
          isExpanded: false,
          hint: Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              'Cuenta',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          itemHeight: 80,
          dropdownColor: Colors.transparent,
          items: widget.items.map((item) {
            final itemName = item["names"].toString().split(' ')[0].toString();
            final itemLastName =
                item["last_name"].toString().split(' ')[0].toString();
            final bank =
                item["bank_entity"].toString().split(' ')[0].toString();

            return DropdownMenuItem<String>(
                value: "Cta: " + item["account_number"],
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre: ${itemName} ${itemLastName}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(3),
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: Text(
                                'Banco: ${item["bank_entity"]}',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              'Tipo: ${item["account_type"]}',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
          }).toList(),
          value: _selectedValue.isNotEmpty ? _selectedValue : null,
          onChanged: (newValue) {
            setState(() {
              _selectedValue = newValue!; // Actualiza el valor seleccionado
            });
          },
          selectedItemBuilder: (context) {
            return widget.items.map((item) {
              return Container(
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _selectedValue,
                  style: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
