import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/add_sellers/custom_filterchip_for_user.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route_new.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class EditOperatorNew extends StatefulWidget {
  final data;

  const EditOperatorNew({super.key, required this.data});

  @override
  State<EditOperatorNew> createState() => _EditOperatorNewState();
}

class _EditOperatorNewState extends State<EditOperatorNew> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  List<String> subRoutesToSelect = [];
  String? selectedValueRoute;
  List data = [];

  TextEditingController _userEditController = TextEditingController(text: "");
  TextEditingController _mailEditController = TextEditingController(text: "");
  TextEditingController _phoneEditController = TextEditingController(text: "");
  TextEditingController _costOperatorEditController =
      TextEditingController(text: "");
  TextEditingController _password = TextEditingController(text: "");

  List<dynamic> accessTemp = [];
  Map<String, dynamic> accessGeneralofRol = {};
  bool blocked = false;
  String idUser = "";
  String idOperador = "";

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      var routesList = [];
      setState(() {
        subRoutesToSelect = [];
      });
      routesList = await Connections().getSubroutesByTransportadoraId(
          sharedPrefs!.getString("idTransportadora").toString());
      for (var i = 0; i < routesList.length; i++) {
        setState(() {
          subRoutesToSelect.add('${routesList[i]}');
        });
      }

      accessGeneralofRol = await Connections().getAccessofRolById(4);

      data = [widget.data];
      // print(data);
      idUser = data[0]['id'].toString();
      idOperador = data[0]['operadores'][0]["id"].toString();

      blocked = data[0]['blocked'];
      _userEditController.text = data[0]['username'].toString();
      _mailEditController.text = data[0]['email'].toString();
      _phoneEditController.text =
          data[0]['operadores'][0]["telefono"].toString();
      _costOperatorEditController.text =
          data[0]['operadores'][0]["costo_operador"].toString();

      setState(() {
        selectedValueRoute =
            '${data[0]['operadores'][0]['sub_rutas'][0]['titulo']}-${data[0]['operadores'][0]['sub_rutas'][0]['id']}';
      });
      accessTemp = json.decode(data[0]['permisos']);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print("error!!!:  $e");

      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Container(
        width: screenWith > 600 ? screenWith * 0.4 : screenWith,
        height: screenHeight * 0.95,
        color: Colors.white,
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close))
                    ],
                  ),
                  const Text(
                    "Información",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    blocked != true ? 'Desbloqueado' : 'Bloqueado',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: ColorsSystem().mainBlue),
                  ),
                  const SizedBox(height: 10),
                  TextFieldWithIcon(
                    controller: _userEditController,
                    labelText: 'Usuario',
                    icon: Icons.person_outline,
                  ),
                  TextButton(
                    onPressed: () async {
                      showCreateSubRoute(context);
                      loadData();

                      setState(() {});
                    },
                    child: const Text(
                      "CREAR SUBRUTA",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Sub Ruta',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold),
                      ),
                      items: subRoutesToSelect
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.split('-')[0],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                      value: selectedValueRoute,
                      onChanged: (value) async {
                        setState(() {
                          selectedValueRoute = value as String;
                        });
                        // print(selectedValueRoute);
                      },

                      //This to clear the search value when you close the menu
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {}
                      },
                    ),
                  ),
                  TextFieldWithIcon(
                    controller: _mailEditController,
                    labelText: 'Correo',
                    icon: Icons.mail,
                  ),
                  const SizedBox(height: 10),
                  TextFieldWithIcon(
                    controller: _costOperatorEditController,
                    labelText: 'Costo Operador',
                    icon: Icons.monetization_on,
                    inputType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}$')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFieldWithIcon(
                    controller: _phoneEditController,
                    labelText: 'Número de Teléfono',
                    icon: Icons.phone_in_talk,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    ],
                  ),
                  //
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colors.colorGreen,
                        minimumSize: Size(200, 40)),
                    onPressed: selectedValueRoute != null
                        ? () async {
                            if (formKey.currentState!.validate()) {
                              if (!_mailEditController.text.contains('@')) {
                                showSuccessModal(
                                    context,
                                    "Por favor, ingrese un correo electrónico válido.",
                                    Icons8.warning_1);
                              } else {
                                //
                                getLoadingModal(context, false);

                                String phoneNumber = _phoneEditController.text;
                                if (phoneNumber.startsWith("0")) {
                                  phoneNumber =
                                      "+593${phoneNumber.substring(1)}";
                                }

                                var resUpt = await Connections()
                                    .updateOperatorGeneralLaravel(
                                        idUser,
                                        idOperador,
                                        selectedValueRoute!.split('-')[1],
                                        _userEditController.text,
                                        _mailEditController.text,
                                        _costOperatorEditController.text,
                                        phoneNumber);

                                if (resUpt == 0) {
                                  Navigator.pop(context);
                                  // ignore: use_build_context_synchronously
                                  AwesomeDialog(
                                    width: 500,
                                    context: context,
                                    dialogType: DialogType.success,
                                    animType: AnimType.rightSlide,
                                    title: 'Completado',
                                    desc: 'Actualización Completada',
                                    btnCancel: Container(),
                                    btnOkText: "Aceptar",
                                    btnOkColor: colors.colorGreen,
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {},
                                  ).show();
                                } else {
                                  Navigator.pop(context);
                                  // ignore: use_build_context_synchronously
                                  AwesomeDialog(
                                    width: 500,
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.rightSlide,
                                    title: 'Error',
                                    desc: 'Revise los Campos',
                                    btnCancel: Container(),
                                    btnOkText: "Aceptar",
                                    btnOkColor: colors.colorGreen,
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              }
                              //
                            }
                            //
                          }
                        : null,
                    child: const Text(
                      "Actualizar Datos",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFieldWithIcon(
                    controller: _password,
                    labelText: 'Contraseña',
                    icon: Icons.password,
                    applyValidator: false,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (_password.text == "") {
                        showSuccessModal(
                            context,
                            "Por favor, ingrese una contraseña.",
                            Icons8.warning_blink);
                      } else {
                        getLoadingModal(context, false);

                        var response = await Connections()
                            .updatePassWordbyIdLaravel(idUser, _password.text);

                        Navigator.pop(context);

                        if (response != null) {
                          // ignore: use_build_context_synchronously
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.rightSlide,
                            title: 'Completado',
                            desc: 'Actualización Completada',
                            btnCancel: Container(),
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
                            desc: 'Intentelo de nuevo',
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colors.colorGreen),
                    child: const Text(
                      "Actualizar Contraseña",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Accesos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  accessContainer(),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Future<dynamic> showCreateSubRoute(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: CreateSubRouteNew(
                idCarrier:
                    sharedPrefs!.getString("idTransportadora").toString(),
              ),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }
}
