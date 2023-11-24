import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes_v2.dart';

class EditAutome extends StatefulWidget {
  final Map user;
  const EditAutome({super.key, required this.user});

  @override
  State<EditAutome> createState() => _EditAutomeState();
}

class _EditAutomeState extends State<EditAutome> {
  TextEditingController textEditingController = TextEditingController();

  bool blocked = false;
  List<String> routes = [];
  List<String> transports = [];
  String? selectedValueRoute;
  String? selectedValueTransport;

  @override
  void initState() {
    super.initState();
    loadData();
    blocked = widget.user["enable_autome"] == 1 ? true : false;
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var routesList = [];
    setState(() {
      transports = [];
    });

    routesList = await Connections().getRoutesLaravel();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        // routes.add('${routesList[i]['titulo']}-${routesList[i]['id']}');
        routes = routesList
            .where((route) => route['titulo'] != "[Vacio]")
            .map<String>((route) => '${route['titulo']}-${route['id']}')
            .toList();
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  getTransports() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var transportList = [];

    setState(() {
      transports = [];
    });

    transportList = await Connections().getTransportsByRouteLaravel(
        selectedValueRoute.toString().split("-")[1]);

    for (var i = 0; i < transportList.length; i++) {
      setState(() {
        transports
            .add('${transportList[i]['nombre']}-${transportList[i]['id']}');
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Row(
          children: [
            Text("Estado :"),
            FlutterSwitch(
              width: 120.0,
              height: 30.0,
              activeText: "Activar",
              inactiveText: "Desactivar",
              valueFontSize: 14.0,
              toggleSize: 25.0,
              value: blocked,
              borderRadius: 30.0,
              padding: 2.0,
              showOnOff: true,
              onToggle: (value) {
                setState(() {
                  blocked = value;
                });
              },
            ),
          ],
        ),
        const Text(
          'Seleccione las transportadora por defecto:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(
              'Ciudad',
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
                selectedValueTransport = null;
              });
              await getTransports();
            },

            //This to clear the search value when you close the menu
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                textEditingController.clear();
              }
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(
              'Transportadora',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.bold),
            ),
            items: transports
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item.split('-')[0],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ))
                .toList(),
            value: selectedValueTransport,
            onChanged: selectedValueRoute == null
                ? null
                : (value) {
                    setState(() {
                      selectedValueTransport = value as String;
                    });
                  },

            //This to clear the search value when you close the menu
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                //textEditingController.clear();
              }
            },
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        ElevatedButton(
          onPressed:
              selectedValueRoute == null || selectedValueTransport == null
                  ? null
                  : () async {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            backgroundColor: const Color(0xFF4688B1),
            elevation: 5,
            shadowColor: const Color.fromARGB(255, 97, 162, 203),
          ),
          child: const Text(
            "ACEPTAR",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ]),
    );
  }
}
