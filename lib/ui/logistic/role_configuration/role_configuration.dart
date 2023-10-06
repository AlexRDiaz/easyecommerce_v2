import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'dart:convert';
import 'package:frontend/helpers/responsive.dart';

class RoleConfiguration extends StatefulWidget {
  const RoleConfiguration({Key? key});

  @override
  State<RoleConfiguration> createState() => _RoleConfigurationState();
}

class _RoleConfigurationState extends State<RoleConfiguration> {
  final TextEditingController _textFieldController = TextEditingController();
  List<dynamic> rolesfront = [];
  List<FilterChipItem> filterChipItems = [];
  List<String> roles2 = [
    'LOGISTICA-1',
    'VENDEDOR-2',
    'TRANSPORTADOR-3',
    'OPERADOR-4'
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      rolesfront = await Connections().getRolesFront();
      setState(() {
        _textFieldController.clear();
      });
    } catch (e) {
      print("Error al cargar datos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return responsive(principal(), principalMovil(), context);
  }

  Widget principal() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 120),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            color: ColorsSystem().colorBlack,
            child: Row(
              children: [
                for (var role in roles2)
                  RoleContainer(
                    roleName: role.split('-')[0],
                    addButton: ElevatedButton(
                      onPressed: () {
                        _showAddViewDialog(context, role.split('-')[1]);
                      },
                      child: Icon(Icons.add, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildList(),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: rolesfront.length,
        itemBuilder: (context, index) {
          var role = rolesfront[index];
          var accesos = [...?(json.decode(role['accesos']) as List<dynamic>?)];

          return Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 232, 232),
                border: Border.all(color: ColorsSystem().colorBlack, width: 1)),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: accesos.length,
                    itemBuilder: (context, subIndex) {
                      return Row(
                        children: [
                          Flexible(
                            child: FilterChipItem(
                              label: Text(
                                accesos[subIndex]['view_name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              initialSelected: accesos[subIndex]['active'],
                              onSelected: (value) async {
                                setState(() {
                                  accesos[subIndex]['active'] = value;
                                  rolesfront[index]['accesos'] =
                                      json.encode(accesos);
                                  accesos[subIndex]['id_rol'] = role['id'];
                                });

                                await Connections()
                                    .postNewAccess(accesos[subIndex]);
                              },
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget principalMovil() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
      child: Column(
        children: [
          _buildListMovil(),
        ],
      ),
    );
  }

  Widget _buildListMovil() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView.builder(
        itemCount: rolesfront.length,
        itemBuilder: (context, index) {
          var role = rolesfront[index];
          var accesos = [...?(json.decode(role['accesos']) as List<dynamic>?)];
          return Container(
            decoration:
                BoxDecoration(color: const Color.fromARGB(255, 219, 217, 217)),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "ROL ${role['titulo']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorsSystem().colorSelectMenu),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showAddViewDialog(context, role['id']);
                      },
                      child: Icon(Icons.add, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsSystem().colorSelectMenu,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ), // Muestra el nombre del rol

                for (var acceso in accesos ?? [])
                  Column(
                    children: [
                      FilterChipItem(
                        label: Text(
                          acceso['view_name'],
                          style: TextStyle(color: Colors.white),
                        ),
                        initialSelected: acceso['active'],
                        onSelected: (value) async {
                          setState(() {
                            acceso['active'] = value;
                            rolesfront[index]['accesos'] = json.encode(accesos);
                            acceso['id_rol'] = role['id'];
                          });

                          await Connections().postNewAccess(acceso);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddViewDialog(BuildContext context, id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorsSystem().colorBlack,
          title: Text(
            "Agregar Nueva Vista",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Ingresa el nombre de la vista:",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: TextField(
                  controller: _textFieldController,
                  style:
                      TextStyle(color: Colors.black), // Text color of TextField
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  // Add your logic for handling text input
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add logic for accepting the new view
                      _handleAccept(id);
                    },
                    child: Text("Aceptar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Close the dialog on cancel
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancelar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAccept(id) async {
    // Print the value outside of the setState
    print(_textFieldController.text);

    FilterChipItem newFilterChipItem = FilterChipItem(
      label: Text(
        _textFieldController.text.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      initialSelected: false,
      onSelected: (value) async {
        // Aquí puedes agregar la lógica de selección si es necesario
      },
    );

    // Actualiza el estado solo si no existe ya
    if (!filterChipItems.contains(newFilterChipItem)) {
      setState(() {
        filterChipItems.add(newFilterChipItem);
      });
    }
    await Connections().editAccessofWindow({
      "active": false,
      "view_name": _textFieldController.text.toString(),
      "id_rol": id
    });
    Navigator.of(context).pop();
    setState(() {
      loadData();
    });
    // Add any other logic you need
  }
}

class RoleContainer extends StatelessWidget {
  final String roleName;
  final Widget addButton;

  RoleContainer({required this.roleName, required this.addButton});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Expanded(
      child: Column(
        children: [
          Text(
            roleName,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8.0),
          addButton,
        ],
      ),
    ));
  }
}

class FilterChipItem extends StatefulWidget {
  final Text label;
  final bool initialSelected;
  final Function(bool) onSelected;

  FilterChipItem(
      {required this.label,
      required this.initialSelected,
      required this.onSelected});

  @override
  _FilterChipItemState createState() => _FilterChipItemState();
}

class _FilterChipItemState extends State<FilterChipItem> {
  late bool isSelected;
  late Text label;

  @override
  void initState() {
    super.initState();
    isSelected = widget.initialSelected;
    label = widget.label;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FilterChip(
          label: label,
          selected: isSelected,
          onSelected: (value) {
            setState(() {
              isSelected = value;
              widget.onSelected(value);
              if (isSelected) {
                AwesomeDialog(
                  width: 500,
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.rightSlide,
                  title: 'Vista Activa',
                  desc: 'Actualización Completada',
                  btnCancel: Container(),
                  btnOkText: "Aceptar",
                  btnOkColor: Colors.green,
                  btnCancelOnPress: () {},
                  btnOkOnPress: () async {},
                ).show();
              } else {
                AwesomeDialog(
                  width: 500,
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.rightSlide,
                  title: 'Vista Inactiva',
                  desc: 'Actualización Completada',
                  btnCancel: Container(),
                  btnOkText: "Aceptar",
                  btnOkColor: Colors.green,
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {},
                ).show();
              }
            });
          },
          backgroundColor:
              isSelected ? Colors.greenAccent : ColorsSystem().colorBlack,
          selectedColor: Colors.green,
        ),
      ),
    );
  }
}
