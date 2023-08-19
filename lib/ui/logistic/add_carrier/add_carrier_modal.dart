import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';

class AddCarrierModal extends StatefulWidget {
  const AddCarrierModal({super.key});

  @override
  State<AddCarrierModal> createState() => _AddCarrierModalState();
}

class _AddCarrierModalState extends State<AddCarrierModal> {
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

    routesList = await Connections().getRoutes();
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
                    await  showDialog(
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: "Teléfono",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _telefono2,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: "Teléfono 2",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 30,
                ),
                Align(
                  child: ElevatedButton(
                      onPressed: () async {
                        getLoadingModal(context, false);
                        List listaFinal = selectedItems
                            .map((elemento) => elemento.split("-").last)
                            .toList();
                        var responseCode =
                            await Connections().generateCodeAccount(
                          _correo.text,
                        );
                        var responseCreateGeneral = await Connections()
                            .createTransporterGeneral(_usuario.text, listaFinal,
                                _costo.text, _telefono.text, _telefono2.text);
                        var response = await Connections().createTransporter(
                            _usuario.text,
                            _correo.text,
                            responseCreateGeneral[1],
                            responseCode.toString());
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
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
        height: MediaQuery.of(context).size.height,
        child: ListView(
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
            Text(
              "Titulo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _controller,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    onPressed: () async{
                      Navigator.pop(context);
                        await showDialog(
              context: context,
              builder: (context) {
                return AddCarrierModal();
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
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent),
                    onPressed: () async {
                      var response =
                          await Connections().createRoute(_controller.text);
                      Navigator.pop(context);
                        await showDialog(
              context: context,
              builder: (context) {
                return AddCarrierModal();
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
}
