import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';

class UpdateCarrierModal extends StatefulWidget {
  final String idP;
  final String idT;

  const UpdateCarrierModal({super.key, required this.idP, required this.idT});

  @override
  State<UpdateCarrierModal> createState() => _UpdateCarrierModalState();
}

class _UpdateCarrierModalState extends State<UpdateCarrierModal> {
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

    routesList = await Connections().getRoutes();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        routes.add(
            '${routesList[i]['attributes']['Titulo']}-${routesList[i]['id']}');
      });
    }
    var response = await Connections().getPersonalInfoAccountByID(widget.idP);
    var responseT =
        await Connections().getTransporterInfoAccountByID(widget.idT);

    _usuario.text = response['username'].toString();
    _correo.text = response['email'].toString();
    _costo.text =
        responseT['data']['attributes']['Costo_Transportadora'].toString();
    _telefono.text = responseT['data']['attributes']['Telefono1'].toString();
    _telefono2.text = responseT['data']['attributes']['Telefono2'].toString();
    if (responseT['data']['attributes']['rutas'] != null) {
      if (responseT['data']['attributes']['rutas']['data'].length != 0) {
        for (var i = 0;
            i < responseT['data']['attributes']['rutas']['data'].length;
            i++) {
          setState(() {
            selectedItems.add(
                "${responseT['data']['attributes']['rutas']['data'][i]['attributes']['Titulo']}-${responseT['data']['attributes']['rutas']['data'][i]['id']}");
          });
        }
      }
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

                        var responseCreateGeneral = await Connections()
                            .updateTransporterGeneral(
                                _usuario.text,
                                listaFinal,
                                _costo.text,
                                _telefono.text,
                                _telefono2.text,
                                widget.idT);
                        var response = await Connections().updateTransporter(
                            _usuario.text, _correo.text, widget.idP);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "ACTUALIZAR",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: () async {
                      getLoadingModal(context, false);
                      var response = await Connections()
                          .updatePasswordByIdGet("123456789", widget.idP);
                      Navigator.pop(context);
                      if (response) {
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.rightSlide,
                          title: 'Completado',
                          desc: 'Restablecimiento Completada',
                          btnCancel: Container(),
                          btnOkText: "Aceptar",
                          btnOkColor: colors.colorGreen,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {},
                        ).show();
                      } else {
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Error',
                          desc: 'Error',
                          btnCancel: Container(),
                          btnOkText: "Aceptar",
                          btnOkColor: colors.colorGreen,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {},
                        ).show();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: Text(
                      "Restablecer Contraseña",
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
