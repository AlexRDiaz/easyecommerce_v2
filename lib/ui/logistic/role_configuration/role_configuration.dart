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
      padding: const EdgeInsets.only(left: 40, right: 40, top: 100),
      child: Column(
        children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  loadData();
                },
                child: const Row(
                  children: [
                    Text(
                      "Actualizar Vistas",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(
                      Icons.replay_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            )
          ]),
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
                      // Icon(Icons.add, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const CircleBorder(),
                      ),
                      child: const Tooltip(
                        message: "Agregar Nueva Vista",
                        child: Icon(Icons.add, color: Colors.white),
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
                              label:
                                  "${accesos[subIndex]['view_name']}-${role['id']}",
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
      padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
      child: Column(
        children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  loadData();
                },
                child: const Row(
                  children: [
                    Text(
                      "Actualizar Vistas",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(
                      Icons.replay_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            )
          ]),
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
                const BoxDecoration(color: Color.fromARGB(255, 219, 217, 217)),
            padding: const EdgeInsets.all(10),
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
                        label: "${acceso['view_name']}-${role['id']}",
                        initialSelected: acceso['active'],
                        onSelected: (value) async {
                          setState(() {
                            acceso['active'] = value;
                            rolesfront[index]['accesos'] = json.encode(accesos);
                            acceso['id_rol'] = role['id'];
                          });
                          print(role['id']);
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
          title: const Text(
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
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextField(
                  controller: _textFieldController,
                  style: const TextStyle(
                      color: Colors.black), // Text color of TextField
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _handleAccept(id);
                    },
                    child: Text("Aceptar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
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
    AwesomeDialog(
      width: 500,
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: 'Nueva Vista ',
      desc: 'Está Seguro de agregar La Vista ${_textFieldController.text}?',
      btnOkText: "Agregar",
      btnOkColor: Colors.green,
      btnCancelText: "Cancelar",
      btnCancelColor: Colors.redAccent,
      btnOkOnPress: () async {
        FilterChipItem newFilterChipItem = FilterChipItem(
          label: _textFieldController.text.split("-")[0],
          initialSelected: false,
          onSelected: (value) async {
          },
        );

         await Connections().editAccessofWindow({
          "active": false,
          "view_name": _textFieldController.text.split("-")[0],
          "id_rol": id
        });
        
        
        if (!filterChipItems.contains(newFilterChipItem)) {
          setState(() {
            filterChipItems.add(newFilterChipItem);
          });
        }
        setState(() {
          loadData();
        });

        Navigator.of(context).pop();
      },
      btnCancelOnPress: () {
        Navigator.of(context).pop();
      },
    ).show();
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
  final String label;
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
  late String label;

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
          label: Text(
            label.split('-')[0],
            // label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          selected: isSelected,
          onSelected: (value) {
            isSelected = value;
            _showAddViewDialogStatusChipChangeSomeButtons(
                context, label, isSelected);
          },
          backgroundColor:
              isSelected ? Colors.greenAccent : ColorsSystem().colorBlack,
          selectedColor: Colors.green,
        ),
      ),
    );
  }

  void _showAddViewDialogStatusChipChangeSomeButtons(
      BuildContext context, viewName, isSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: ColorsSystem().colorBlack,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 10),
                      child: Icon(Icons.desktop_windows_outlined,
                          color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        viewName.split("-")[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onSelected(isSelected);
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.shuffle),
                      label: Text("Cambiar Estado"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.rightSlide,
                          title: 'Eliminar Vista',
                          desc:
                              'Está Seguro de Eliminar La Vista "${viewName.split("-")[0]}" ?',
                          btnOkText: "Aceptar",
                          btnOkColor: Colors.green,
                          btnCancelText: "Cancelar",
                          btnCancelColor: Colors.redAccent,
                          btnOkOnPress: () async {
                            // agregar la funcion para la eliminacion y la actualizacion de la lista en la parte del front desaparezca
                            // el chip que se elimina
                            await Connections().deleteAccessofWindow({
                              "view_name": viewName.split("-")[0],
                              "id_rol": viewName.split("-")[1]
                            });
                            Navigator.of(context).pop();
                          },
                          btnCancelOnPress: () {
                            Navigator.of(context).pop();
                          },
                        ).show();
                      },
                      icon: Icon(Icons.delete),
                      label: Text("Eliminar Vista"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }
}
