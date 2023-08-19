import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';

class CreateSubRoutesModal extends StatefulWidget {
  final String idTransport;
  const CreateSubRoutesModal({super.key, required this.idTransport});

  @override
  State<CreateSubRoutesModal> createState() => _CreateSubRoutesModalState();
}

class _CreateSubRoutesModalState extends State<CreateSubRoutesModal> {
  List<String> routes = [];
  List<String> transports = [];
  String? selectedValueRoute;
  TextEditingController _text = TextEditingController();
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    var routesList = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    routesList = await Connections().getRoutesForTransporter();

    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        routes.add(
            '${routesList[i]['attributes']['Titulo']}-${routesList[i]['id']}');
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 400,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Ruta',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: routes
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split('-')[0],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedValueRoute,
                onChanged: (value) async {
                  setState(() {
                    selectedValueRoute = value as String;
                    transports.clear();
                  });
                },

                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {}
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _text,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  hintText: "Titulo",
                  hintStyle: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: selectedValueRoute == null
                    ? null
                    : () async {
                        var response = await Connections().createSubRoute(
                            selectedValueRoute.toString().split("-")[1],
                            _text.text.toString(),
                            widget.idTransport);
                        Navigator.pop(context);
                      },
                child: Text(
                  "ACEPTAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }
}
