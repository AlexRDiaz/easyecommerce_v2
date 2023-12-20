import 'package:flutter/material.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/main.dart';

class LayoutMenu extends StatefulWidget {
  final List permissions;
  final String label;
  final String title;
  final Icon icon;
  const LayoutMenu(
      {super.key,
      required this.permissions,
      required this.label,
      required this.title,
      required this.icon});

  @override
  State<LayoutMenu> createState() => _LayoutMenuState();
}

class _LayoutMenuState extends State<LayoutMenu> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return widget.permissions[0].contains(widget.title)
        ? Container(
            color: isSelected ? Colors.blue : Colors.black,
            padding: EdgeInsets.only(left: 20),
            child: ListTile(
              title: Row(
                children: [
                  widget.icon,
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      widget.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        // Cambiar el color cuando está seleccionado
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                // var selectedView = pagesSeller
                //     .firstWhere((element) => element['page'] == widget.title);
                // var selectedIndex = pagesSeller
                //     .indexWhere((element) => element['page'] == widget.title);
                // sharedPrefs!.setString("index", selectedIndex.toString());

                setState(() {
                  // currentView = selectedView;
                  isSelected = true; // Cambiar el estado al seleccionar
                });
              },
            ),
          )
        : Container();
  }
}
