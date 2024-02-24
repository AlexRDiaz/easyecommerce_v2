import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/transport/add_operators_transport/controllers/controllers.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/create_sub_route_new.dart';

class AddOperatorNew extends StatefulWidget {
  const AddOperatorNew({super.key});

  @override
  State<AddOperatorNew> createState() => _AddOperatorNewState();
}

class _AddOperatorNewState extends State<AddOperatorNew> {
  List<String> subRoutesToSelect = [];
  String? selectedValueRoute;
  bool isLoading = false;

  AddOperatorsTransportControllers _controllers =
      AddOperatorsTransportControllers();

  final formKey = GlobalKey<FormState>();

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
          context, "Ha ocurrido un error al cargar las Subrutas");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWith > 600 ? screenWith * 0.4 : screenWith,
      height: screenHeight * 0.85,
      color: Colors.white,
      child: Form(
        key: formKey,
        child: CustomProgressModal(
          isLoading: isLoading,
          content: ListView(
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
                  const SizedBox(height: 10),
                  const Text(
                    "AGREGAR",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: () async {
                        showCreateSubRoute(context);
                      },
                      child: const Text(
                        "CREAR SUBRUTA",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(height: 10),
                  //por defecto va validado que ingrese data
                  TextFieldWithIcon(
                    controller: _controllers.userController,
                    labelText: 'Usuario',
                    icon: Icons.person_outline,
                  ),
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
                    controller: _controllers.mailController,
                    labelText: 'Correo',
                    icon: Icons.mail,
                  ),
                  const SizedBox(height: 10),
                  TextFieldWithIcon(
                    controller: _controllers.costOperatorController,
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
                    controller: _controllers.phoneController,
                    labelText: 'Número de Teléfono',
                    icon: Icons.phone_in_talk,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(200, 40)),
                      onPressed: selectedValueRoute != null
                          ? () async {
                              if (formKey.currentState!.validate()) {
                                // getLoadingModal(context, false);

                                if (!_controllers.mailController.text
                                    .contains('@')) {
                                  showSuccessModal(
                                      context,
                                      "Por favor, ingrese un correo electrónico válido.",
                                      Icons8.warning_1);
                                } else {
                                  // print(_controllers.mailController.text);
                                  getLoadingModal(context, false);

                                  var response = await Connections()
                                      .getPersonalInfoAccountByEmail(
                                          _controllers.mailController.text
                                              .toString());

                                  if (response == 2) {
                                    print(
                                        "No se pudo establecer conexión, inténtelo de nuevo");
                                  } else {
                                    if (response == 1) {
                                      // print(
                                      //     "Con búsqueda en la base de datos no encontró este correo. Puede crear un usuario");
                                      getLoadingModal(context, false);

                                      var accesofRol = await Connections()
                                          .getAccessofSpecificRol("OPERADOR");

                                      String phoneNumber =
                                          _controllers.phoneController.text;
                                      if (phoneNumber.startsWith("0")) {
                                        phoneNumber =
                                            "+593${phoneNumber.substring(1)}";
                                      }
                                      Map<String, dynamic> roleParameters = {
                                        "phone": phoneNumber,
                                        "operatorCost": _controllers
                                            .costOperatorController.text,
                                        "idCarrier": sharedPrefs!
                                            .getString("idTransportadora")
                                            .toString(),
                                        "idSubRoute":
                                            selectedValueRoute!.split('-')[1]
                                      };

                                      var responseCreate = await Connections()
                                          .createUser(
                                              4,
                                              _controllers.userController.text,
                                              _controllers.mailController.text,
                                              accesofRol,
                                              4,
                                              roleParameters);

                                      if (responseCreate != null) {
                                        Navigator.pop(context);
                                        // ignore: use_build_context_synchronously
                                        AwesomeDialog(
                                          width: 500,
                                          context: context,
                                          dialogType: DialogType.success,
                                          animType: AnimType.rightSlide,
                                          title: 'Completado',
                                          desc:
                                              'Se creo el operador con exito.',
                                          btnCancel: Container(),
                                          btnOkText: "Aceptar",
                                          btnOkColor: colors.colorGreen,
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
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
                                          desc: 'Revisa los Campos',
                                          btnCancel: Container(),
                                          btnOkText: "Aceptar",
                                          btnOkColor: colors.colorGreen,
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {},
                                        ).show();
                                      }

                                      //
                                    } else if (response != null) {
                                      Navigator.pop(context);

                                      // ignore: use_build_context_synchronously
                                      showSuccessModal(
                                          context,
                                          "Error, Este correo ya se encuentra registrado.",
                                          Icons8.warning_1);
                                    }
                                  }
                                }
                                //
                              }
                              //
                            }
                          : null,
                      child: const Text(
                        "Guardar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )
            ],
          ),
        ),
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
