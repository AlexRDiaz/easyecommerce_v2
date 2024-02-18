import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/add_sellers/custom_filterchip_for_user.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';

class UpdateCarrierModalLaravel extends StatefulWidget {
  // final String idP;
  // final String idT;
  final dataT;

  const UpdateCarrierModalLaravel(
      // {super.key, required this.idT, required this.idP});
      {super.key,
      required this.dataT});

  @override
  State<UpdateCarrierModalLaravel> createState() =>
      _UpdateCarrierModalLaravelState();
}

class _UpdateCarrierModalLaravelState extends State<UpdateCarrierModalLaravel> {
  // idT: dataL[index]['id'].toString(),
  // idP: dataL[index][
  //             'transportadoras_users_permissions_user_links']
  //         [0]['up_user']['id']
  //     .toString(),
  TextEditingController _usuario = TextEditingController();
  TextEditingController _correo = TextEditingController();
  TextEditingController _costo = TextEditingController();
  TextEditingController _telefono = TextEditingController();
  TextEditingController _telefono2 = TextEditingController();
  List<String> routes = [];
  List<String> selectedItems = [];

  List<dynamic> accessTemp = [];
  Map<String, dynamic> accessGeneralofRol = {};
  String idUser = "";
  bool isLoading = false;

  String model = "Transportadora";

  var sortFieldDefaultValue = "";
  List<String> populate = [
    "rutas",
    "transportadoras_users_permissions_user_links.up_user"
  ];
  List arrayFiltersAnd = [];
  List dataL = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getLoadingModal(context, false);
    // });
    // print(widget.dataT);
    setState(() {
      isLoading = true;
    });

    var routesList = [];

    routesList = await Connections().getActiveRoutes();
    for (var i = 0; i < routesList.length; i++) {
      setState(() {
        routes.add('${routesList[i]}');
      });
    }

    // idT: dataL[index]['id'].toString(),
    // idP: dataL[index][
    //             'transportadoras_users_permissions_user_links']
    //         [0]['up_user']['id']
    //     .toString(),

    // print(widget.dataT['id'].toString());

    // arrayFiltersAnd.add({"equals/id": widget.dataT[]['id'].toString()});

    // var newResponse = await Connections()
    //     .generalDataSpecific(populate, arrayFiltersAnd, model);

    // print(newResponse);
    setState(() {
      dataL = [widget.dataT];
    });

    // print(dataL);
    // var response = await Connections().getPersonalInfoAccountByID(widget.idP);
    // var responseT =
    //     await Connections().getTransporterInfoAccountByID(widget.idT);

    idUser = dataL[0]['transportadoras_users_permissions_user_links'][0]
            ['up_user']['id']
        .toString();

    // print(idUser);

    _usuario.text = dataL[0]['transportadoras_users_permissions_user_links'][0]
            ['up_user']['username']
        .toString();
    _correo.text = dataL[0]['transportadoras_users_permissions_user_links'][0]
            ['up_user']['email']
        .toString();
    _costo.text = dataL[0]['costo_transportadora'].toString();
    _telefono.text = dataL[0]['telefono_1'].toString();
    _telefono2.text = dataL[0]['telefono_2'].toString();
    accessTemp = json.decode(dataL[0]
            ['transportadoras_users_permissions_user_links'][0]['up_user']
        ['permisos']);

    accessGeneralofRol = await Connections().getAccessofRolById(3);

    if (dataL[0]['rutas'] != null) {
      if (dataL[0]['rutas'][0].length != 0) {
        // print(dataL[0]['rutas'].length);
        for (var i = 0; i < dataL[0]['rutas'].length; i++) {
          // setState(() {
          selectedItems.add(
              "${dataL[0]['rutas'][i]['titulo'].toString()}-${dataL[0]['rutas'][i]['id'].toString()}");
          // print(selectedItems);
          // });
        }
      }
    }

    // Future.delayed(Duration(milliseconds: 500), () {
    //   // Navigator.pop(context);
    // });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
        isLoading: isLoading,
        content: AlertDialog(
          content: SizedBox(
            width: 500,
            height: MediaQuery.of(context).size.height,
            child: ListView(
              children: [
                responsive(webContainer(context), Container(), context),
              ],
            ),
          ),
        ));
  }
  // @override
  // Widget build(BuildContext context) {
  //   return AlertDialog(
  //     content: Container(
  //       width: 500,
  //       height: MediaQuery.of(context).size.height,
  //       child: ListView(
  //         children: [
  //           webContainer(context)
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Column webContainer(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Asegura que los hijos de la Row se distribuyan al inicio y al final
          children: [
            Text(
              "Actualización de Transportista",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(), // Inserta un Spacer aquí
            Align(
              alignment: Alignment
                  .centerRight, // Corrige el alineamiento aquí si es necesario, aunque puede no ser necesario con el uso de Spacer
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        TextField(
          controller: _usuario,
          // style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Usuario",
            hintStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(15.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(15.0),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _correo,
          // style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Correo",
            hintStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(Icons.email, color: Colors.orange),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(15.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(15.0),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _costo,
          // style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Costo",
            hintStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(Icons.attach_money, color: Colors.green),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(15.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(15.0),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        customDropdown(context),
        SizedBox(
          height: 20,
        ),
        TextField(
          controller: _telefono,
          // style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Teléfono",
            hintStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(Icons.phone_android, color: Colors.blueAccent),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(15.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(15.0),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: _telefono2,
          // style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Teléfono 2",
            hintStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(Icons.phone_in_talk, color: Colors.teal),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300]!),
              borderRadius: BorderRadius.circular(15.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(15.0),
            ),
            fillColor: Colors.blue[50],
            filled: true,
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          "Accesos",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        accessContainer(),
        SizedBox(
          height: 20,
        ),
        //       Align(
        //         child: ElevatedButton(
        // onPressed: () async {
        //   // getLoadingModal(context, false);
        //   List listaFinal = selectedItems
        //       .map((elemento) => elemento.split("-").last)
        //       .toList();

        //   var respf = await Connections().updateTransport(
        //       idUser,
        //       _usuario.text,
        //       _correo.text,
        //       _costo.text,
        //       _telefono.text,
        //       _telefono2.text,
        //       listaFinal);

        //   Navigator.pop(context);
        // },
        // child: Text(
        //   "ACTUALIZAR",
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // )),
        //       ),
        Align(
          alignment:
              Alignment.center, // Asegúrate de que el botón esté centrado
          child: Container(
            // width: MediaQuery.of(context).size.width * 0.5,
            width: 450,
            child: ButtonTheme(
              minWidth: double
                  .infinity, // Esto hace que el botón tenga el ancho máximo posible dentro del contenedor
              child: ElevatedButton(
                onPressed: () async {
                  // Tu lógica de actualización
                  List listaFinal = selectedItems
                      .map((elemento) => elemento.split("-").last)
                      .toList();

                  var respf = await Connections().updateTransport(
                      idUser,
                      _usuario.text,
                      _correo.text,
                      _costo.text,
                      _telefono.text,
                      _telefono2.text,
                      listaFinal);

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Alinea esto con tus TextField para consistencia
                  ),
                  // padding: EdgeInsets.symmetric(
                  // vertical:
                  // 15.0), // Ajusta el padding vertical para que coincida con la altura de tus TextField si es necesario
                ),
                child: Text(
                  "ACTUALIZAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),

        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 450,
            child: ElevatedButton(
                onPressed: () async {
                  // getLoadingModal(context, false);

                  // ! falta el reseteo
                  var response = await Connections().updatePassWordbyIdLaravel(idUser,"123456789");
                  // ! *********************

                  // ignore: use_build_context_synchronously
                  // Navigator.pop(context);
                  if (response["message"] == "Actualización de contraseña exitosa") {
                    // ignore: use_build_context_synchronously
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Completado',
                      desc: 'Restablecimiento Completada',
                      btnOkText: "Aceptar",
                      btnOkColor: colors.colorGreen,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                  } else {
                    // ignore: use_build_context_synchronously
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Error',
                      desc: 'Error',
                      btnOkText: "Aceptar",
                      btnOkColor: colors.colorGreen,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Alinea esto con tus TextField para consistencia
                  ),
                ),
                child: Text(
                  "Restablecer Contraseña",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          ),
        ),
      ],
    );
  }

  // Column movilContainer(BuildContext context) {
  //   return Column(
  //     children: [
  //       Align(
  //         alignment: Alignment.centerRight,
  //         child: GestureDetector(
  //             onTap: () {
  //               Navigator.pop(context);
  //             },
  //             child: Icon(Icons.close)),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       TextField(
  //         controller: _usuario,
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //         decoration: InputDecoration(
  //             hintText: "Usuario",
  //             hintStyle: TextStyle(fontWeight: FontWeight.bold)),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       TextField(
  //         controller: _correo,
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //         decoration: InputDecoration(
  //             hintText: "Correo",
  //             hintStyle: TextStyle(fontWeight: FontWeight.bold)),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       TextField(
  //         controller: _costo,
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //         decoration: InputDecoration(
  //             hintText: "Costo",
  //             hintStyle: TextStyle(fontWeight: FontWeight.bold)),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       customDropdown(context),
  //       TextField(
  //         controller: _telefono,
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //         decoration: InputDecoration(
  //             hintText: "Teléfono",
  //             hintStyle: TextStyle(fontWeight: FontWeight.bold)),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       TextField(
  //         controller: _telefono2,
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //         decoration: InputDecoration(
  //             hintText: "Teléfono 2",
  //             hintStyle: TextStyle(fontWeight: FontWeight.bold)),
  //       ),
  //       SizedBox(
  //         height: 30,
  //       ),
  //       Text(
  //         "Accesos",
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //       ),
  //       accessContainer(),
  //       SizedBox(
  //         height: 20,
  //       ),
  //       Align(
  //         child: ElevatedButton(
  //             onPressed: () async {
  //               // getLoadingModal(context, false);
  //               List listaFinal = selectedItems
  //                   .map((elemento) => elemento.split("-").last)
  //                   .toList();

  //               // print("> ${widget.idP}");

  //               var respf = await Connections().updateTransport(
  //                  idUser,
  //                   _usuario.text,
  //                   _correo.text,
  //                   _costo.text,
  //                   _telefono.text,
  //                   _telefono2.text,
  //                   listaFinal);

  //               print(respf);
  //               // var responseCreateGeneral = await Connections()
  //               //     .updateTransporterGeneral(
  //               //         _usuario.text,
  //               //         listaFinal,
  //               //         _costo.text,
  //               //         _telefono.text,
  //               //         _telefono2.text,
  //               //         widget.idT
  //               // );
  //               // var response = await Connections().updateTransporter(
  //               //     _usuario.text, _correo.text, widget.idP);
  //               // Navigator.pop(context);
  //               Navigator.pop(context);
  //             },
  //             child: Text(
  //               "ACTUALIZAR",
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             )),
  //       ),
  //       SizedBox(
  //         height: 30,
  //       ),
  //       ElevatedButton(
  //           onPressed: () async {
  //             // getLoadingModal(context, false);
  //             // ! falta *************************
  //             // var response = await Connections().updatePasswordByIdGet("123456789", widget.idP);
  //             // ! ***********************************

  //             // ignore: use_build_context_synchronously
  //             // Navigator.pop(context);
  //             // if (response) {
  //             //   // ignore: use_build_context_synchronously
  //             //   AwesomeDialog(
  //             //     width: 500,
  //             //     context: context,
  //             //     dialogType: DialogType.success,
  //             //     animType: AnimType.rightSlide,
  //             //     title: 'Completado',
  //             //     desc: 'Restablecimiento Completada',
  //             //     btnCancel: Container(),
  //             //     btnOkText: "Aceptar",
  //             //     btnOkColor: colors.colorGreen,
  //             //     btnCancelOnPress: () {},
  //             //     btnOkOnPress: () {},
  //             //   ).show();
  //             // } else {
  //             //   // ignore: use_build_context_synchronously
  //             //   AwesomeDialog(
  //             //     width: 500,
  //             //     context: context,
  //             //     dialogType: DialogType.error,
  //             //     animType: AnimType.rightSlide,
  //             //     title: 'Error',
  //             //     desc: 'Error',
  //             //     btnCancel: Container(),
  //             //     btnOkText: "Aceptar",
  //             //     btnOkColor: colors.colorGreen,
  //             //     btnCancelOnPress: () {},
  //             //     btnOkOnPress: () {},
  //             //   ).show();
  //             // }
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
  //           child: Text(
  //             "Restablecer Contraseña",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           )),
  //     ],
  //   );
  // }

  Container accessContainer() {
    return Container(
      margin: EdgeInsets.all(20.0),
      height: 500,
      width: 500,
      decoration: BoxDecoration(
          border:
              Border.all(width: 1.0, color: Color.fromARGB(255, 119, 118, 118)),
          borderRadius: BorderRadius.circular(10.0)),
      child: Builder(
        builder: (context) {
          return CustomFilterChips(
            accessTemp: accessTemp,
            accessGeneralofRol: accessGeneralofRol,
            loadData: loadData,
            idUser: idUser.toString(),
          );
        },
      ),
    );
  }

  DropdownButtonHideUnderline customDropdown(BuildContext context) {
    return DropdownButtonHideUnderline(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _isSelected
                            ? const Icon(Icons.check_box_outlined)
                            : const Icon(Icons.check_box_outline_blank),
                        const SizedBox(width: 16),
                        Text(
                          item.toString().split('-')[0].toString(),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
    );
  }
}
