import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';

class AddCarrierLaravelModal extends StatefulWidget {
  const AddCarrierLaravelModal({super.key});

  @override
  State<AddCarrierLaravelModal> createState() => _AddCarrierModalLaravelState();
}

class _AddCarrierModalLaravelState extends State<AddCarrierLaravelModal> {
  TextEditingController _usuario = TextEditingController();
  TextEditingController _correo = TextEditingController();
  TextEditingController _costo = TextEditingController();
  TextEditingController _telefono = TextEditingController();
  TextEditingController _telefono2 = TextEditingController();
  List<String> routes = [];
  List<String> selectedItems = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var routesList = [];
    setState(() {
      routes.clear();
    });

    routesList = await Connections().getActiveRoutes();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        routes.add('${routesList[i]}');
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
        width: 500,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close)),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _usuario,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: "Usuario",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _correo,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: "Correo",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _costo,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: "Costo",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AddRoute();
                          });
                      // await loadData();
                    },
                    child: Text(
                      "AGREGAR",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    )),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    isExpanded: true,
                    hint: Align(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        'RUTAS',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    items: routes.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        //disable default onTap to avoid closing menu when selecting an item
                        enabled: false,
                        child: StatefulBuilder(
                          builder: (context, menuSetState) {
                            final _isSelected = selectedItems.contains(item);
                            return InkWell(
                              onTap: () {
                                _isSelected
                                    ? selectedItems.remove(item)
                                    : selectedItems.add(item);
                                //This rebuilds the StatefulWidget to update the button's text
                                setState(() {});
                                //This rebuilds the dropdownMenu Widget to update the check mark
                                menuSetState(() {});
                              },
                              child: Container(
                                height: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    _isSelected
                                        ? const Icon(Icons.check_box_outlined)
                                        : const Icon(
                                            Icons.check_box_outline_blank),
                                    const SizedBox(width: 16),
                                    Text(
                                      item.toString().split('-')[0].toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                    //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
                    value: selectedItems.isEmpty ? null : selectedItems.last,
                    onChanged: (value) {},
                    selectedItemBuilder: (context) {
                      return routes.map(
                        (item) {
                          return Container(
                            alignment: AlignmentDirectional.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              selectedItems.join(', '),
                              style: const TextStyle(
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                          );
                        },
                      ).toList();
                    },
                  ),
                ),
                TextField(
                  controller: _telefono,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                      hintText: "Teléfono",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _telefono2,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                      hintText: "Teléfono 2",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 30,
                ),
                // !! aqui hace todo el proceso de creacion
                Align(
                  child: ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);
                        List listaFinal = selectedItems
                            .map((elemento) => elemento.split("-").last)
                            .toList();
                        //  ************** UNO *******************
                        // var responseCode =
                        //     await Connections().generateCodeAccount(
                        //   _correo.text,
                        // );

                        //  ************** YA ESTA CON LARAVEL ↓ *******************

                        var accesofRol = await Connections()
                            .getAccessofSpecificRol("TRANSPORTADOR");

                        // ! ************** REESTRUCTURACION LARAVEL ↓ *******************
                        Map<String, dynamic> roleParameters = {
                          "nombre_transportadora": _usuario.text,
                          "telefono1":  _telefono2.text,
                          "telefono2":  _telefono.text, 
                          "costo_transportadora": _costo.text,
                          "rutas": listaFinal
                        };

                        await Connections().createUser(
                            3,
                            _usuario.text,
                            _correo.text,
                            accesofRol,
                            3,
                            roleParameters);
                        //  ************** TRES *******************

                        // var responseCreateGeneral = await Connections()
                        //     .createTransporterGeneral(_usuario.text, listaFinal,
                        //         _costo.text, _telefono.text, _telefono2.text);

                        //     //  ************** CUATRO *******************

                        // var response = await Connections().createTransporter(
                        //     _usuario.text,
                        //     _correo.text,
                        //     responseCreateGeneral[1],
                        //     responseCode.toString(),
                        //     accesofRol);

                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "GUARDAR",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AddRoute extends StatefulWidget {
  const AddRoute({super.key});

  @override
  State<AddRoute> createState() => _AddRouteState();
}

class _AddRouteState extends State<AddRoute> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 500,
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView(
          children: [
            Align(
              // alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close)),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "Agregar Ruta",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Text(
            //   "Titulo",
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            SizedBox(
              height: 10,
            ),
            _modelTextField(
                text: "Título",
                controller: _controller,
                icon: Icons.text_fields_outlined),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    onPressed: () async {
                      Navigator.pop(context);
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AddCarrierLaravelModal();
                          });
                    },
                    child: Text(
                      "Cancelar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      var response =
                          await Connections().createRuta(_controller.text);
                      Navigator.pop(context);
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AddCarrierLaravelModal();
                          });
                    },
                    child: Text(
                      "Guardar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  _modelTextField({text, controller, icon}) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width * 0.5,
      // padding: EdgeInsets.only(top: 15.0),
      margin: EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // paginateData();
          // loadData();
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(icon),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _controller.clear();
                    });

                    setState(() {
                      // paginateData();
                      // loadData();
                    });
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }
}
