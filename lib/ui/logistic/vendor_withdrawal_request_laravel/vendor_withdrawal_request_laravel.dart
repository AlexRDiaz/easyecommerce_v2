import 'dart:html';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/income_and_expenses/controllers/controllers.dart';
import 'package:frontend/ui/logistic/vendor_withdrawal_request_laravel/controllers/controllers.dart';
import 'package:frontend/ui/logistic/vendor_withdrawal_request_laravel/intern_aproved_seller_withdrawals.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/forms/image_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

// import 'controllers/controllers.dart';

class VendorWithDrawalRequestLaravel extends StatefulWidget {
  const VendorWithDrawalRequestLaravel({super.key});

  @override
  State<VendorWithDrawalRequestLaravel> createState() =>
      _VendorWithDrawalRequestLaravelState();
}

class _VendorWithDrawalRequestLaravelState
    extends State<VendorWithDrawalRequestLaravel> {
  final VendorWithDrawalRequestLaravelControllers _controllers =
      VendorWithDrawalRequestLaravelControllers();
  TextEditingController supervisorController = TextEditingController();
  List optionsCheckBox = [];
  // int counterChecks = 0;
  List data = [];
  List dataAccountOrder = [];
  String id = "";
  bool aprobado = false;
  bool realizado = false;
  bool realizadopro = false;
  bool rechazado = false;
  bool sort = false;
  int currentPage = 1;
  int pageSize = 150;
  int pageCount = 1;
  bool isFirst = true;
  bool isLoading = false;
  int total = 0;
  XFile? imageSelect = null;

  String model = "";

  var sortFieldDefaultValue = "";
  List populate = [];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [];
  List arrayFiltersNot = [];

  @override
  void didChangeDependencies() {
    // loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    setState(() {
      isLoading = true;
    });
    var response = await Connections().generalData(
        pageSize,
        pageCount,
        populate,
        arrayFiltersNot,
        arrayFiltersAnd,
        arrayFiltersOr,
        [],
        [],
        _controllers.searchController.text,
        model,
        "",
        "",
        "",
        sortFieldDefaultValue);
    print("ak> $response");
    setState(() {
      data = [];
      data = response['data'];
      // dataAccountOrder = [];
      // dataAccountOrder = dataAccountWithdrawal;
      isLoading = false;
    });
  }

  double calculateAdjustedAspectRatio(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final screenSize = MediaQuery.of(context).size;

    // Calcular la relación entre el ancho y la altura de la pantalla
    final aspectRatio = screenSize.width / screenSize.height;

    // print("${screenSize.width} - ${screenSize.height}");
    // Definir el aspecto base de las tarjetas (puede ajustarse según lo que necesites)
    double baseAspectRatio;

    // Definir el aspecto base según la resolución
    if (screenSize.width == 1440 && screenSize.height == 821) {
      if (getStringCheck() == "APROBADO" || getStringCheck() == "RECHAZADO") {
        baseAspectRatio = 0.5; // Aspecto base para 1920x1080
      } else {
        baseAspectRatio = 0.7; // Aspecto base para 1920x1080
      }
    } else if (screenSize.width == 1366 &&
        (screenSize.height >= 689 && screenSize.height <= 695)) {
      if (getStringCheck() == "APROBADO") {
        baseAspectRatio = 0.45; // Aspecto base para 1440x900
      } else if (getStringCheck() == "RECHAZADO") {
        baseAspectRatio = 0.5; // Aspecto base para 1440x900
      } else {
        baseAspectRatio = 0.7; // Aspecto base para 1920x1080
      }
    } else {
      if (getStringCheck() == "APROBADO" || getStringCheck() == "RECHAZADO") {
        baseAspectRatio = 0.7; // Aspecto base por defecto
      } else {
        baseAspectRatio = 0.7; // Aspecto base para 1920x1080
      }
    }

    // Ajustar el aspecto de las tarjetas según la relación entre el ancho y la altura de la pantalla
    double adjustedAspectRatio = baseAspectRatio;

    // Por ejemplo, podrías agregar condiciones para ajustar el aspecto en función de la relación
    if (aspectRatio < 1.0) {
      // Si la pantalla es más alta que ancha (por ejemplo, en dispositivos verticales)
      adjustedAspectRatio = baseAspectRatio * (1 / aspectRatio);
    } else {
      // Si la pantalla es más ancha que alta
      adjustedAspectRatio = baseAspectRatio * aspectRatio;
    }

    return adjustedAspectRatio;
  }

  void updateOrAddEstadoFilter(List<dynamic> arrayFiltersAnd) {
    Map<String, dynamic> filterToAdd = {"/estado": getStringCheck()};
    bool estadoExists = false;

    // Verificar si la propiedad "/estado" ya existe en arrayFiltersAnd
    for (var filter in arrayFiltersAnd) {
      if (filter.containsKey("/estado")) {
        // La propiedad "/estado" ya existe, reemplazar su valor
        filter["/estado"] = getStringCheck();
        estadoExists = true;
        break;
      }
    }

    // Si la propiedad "/estado" no existe, añadir una nueva entrada
    if (!estadoExists) {
      arrayFiltersAnd.add(filterToAdd);
    }
  }

  @override
  Widget build(BuildContext context) {
    double adjustedAspectRatio = calculateAdjustedAspectRatio(context);

    return CustomProgressModal(
        isLoading: isLoading,
        content: Scaffold(
          body: SizedBox(
              child: responsive(webContainer(context, adjustedAspectRatio),
                  movilContainer(context, adjustedAspectRatio), context)),
        ));
  }

  Column webContainer(BuildContext context, double adjustedAspectRatio) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: _modelTextField(
                text: "Búsqueda", controller: _controllers.searchController),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Wrap(
          children: [
            Container(
              width: 200,
              child: Row(
                children: [
                  Checkbox(
                      value: aprobado,
                      onChanged: (value) async {
                        setState(() {
                          aprobado = true;
                          realizado = false;
                          realizadopro = false;

                          rechazado = false;
                        });
                        model = "OrdenesRetiro";

                        sortFieldDefaultValue = "id:DESC";
                        populate = [
                          'users_permissions_user.vendedores',
                        ];
                        arrayFiltersAnd = [
                          // {"/estado": "APROBADO"}
                        ];
                        arrayFiltersOr = [
                          "monto",
                          "users_permissions_user.user_id",
                          "users_permissions_user.username",
                          "users_permissions_user.email",
                          "users_permissions_user.vendedores.nombre_comercial"
                        ];
                        arrayFiltersNot = [];
                        updateOrAddEstadoFilter(arrayFiltersAnd);
                        await loadData();
                      }),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.checklist_rtl_sharp,
                    color: Colors.blue,
                  ),
                  Text("Aprobados")
                ],
              ),
            ),
            Container(
              width: 250,
              child: Row(
                children: [
                  Checkbox(
                      value: realizado,
                      onChanged: (value) async {
                        setState(() {
                          aprobado = false;
                          realizado = true;
                          realizadopro = false;
                          rechazado = false;
                        });
                        model = "Vendedore";
                        sortFieldDefaultValue = "id:ASC";
                        populate = [
                          'up_users',
                        ];
                        arrayFiltersAnd = [];
                        arrayFiltersOr = [
                          "nombre_comercial",
                          "up_users.user_id",
                          "up_users.username"
                        ];
                        arrayFiltersNot = [
                          {"id_master": ""}
                        ];
                        await loadData();
                      }),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  Text("Realizados Vendedores")
                ],
              ),
            ),
            Container(
              width: 250,
              child: Row(
                children: [
                  Checkbox(
                      value: realizadopro,
                      onChanged: (value) async {
                        setState(() {
                          aprobado = false;
                          realizado = false;
                          realizadopro = true;
                          rechazado = false;
                        });
                        model = "Provider";
                        sortFieldDefaultValue = "id:ASC";
                        populate = [
                          'user',
                        ];
                        arrayFiltersAnd = [];
                        arrayFiltersOr = ["user.username", "user.id", "name"];
                        arrayFiltersNot = [];
                        await loadData();
                      }),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  Text("Realizados Proveedores")
                ],
              ),
            ),
            Container(
              width: 200,
              child: Row(
                children: [
                  Checkbox(
                      value: rechazado,
                      onChanged: (value) async {
                        setState(() {
                          aprobado = false;
                          rechazado = true;
                          realizado = false;
                          realizadopro = false;
                        });
                        model = "OrdenesRetiro";

                        sortFieldDefaultValue = "id:DESC";
                        populate = [
                          'users_permissions_user.vendedores',
                        ];
                        arrayFiltersAnd = [
                          // {"/estado": "APROBADO"}
                        ];
                        arrayFiltersOr = [
                          "monto",
                          "users_permissions_user.user_id",
                          "users_permissions_user.username",
                          "users_permissions_user.email",
                          "users_permissions_user.vendedores.nombre_comercial"
                        ];
                        arrayFiltersNot = [];
                        updateOrAddEstadoFilter(arrayFiltersAnd);
                        await loadData();
                      }),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.close_outlined,
                    color: Colors.red,
                  ),
                  Text("Rechazados")
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Expanded(
            child: Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[300]),
                child: getStringCheck() == "APROBADO"
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing:
                              10.0, // Espacio vertical entre elementos
                          crossAxisSpacing:
                              10.0, // Espacio horizontal entre elementos
                          childAspectRatio:
                              adjustedAspectRatio, // Relación entre ancho y altura de cada tarjeta
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            UIUtils.formatDate(data[index]
                                                    ['created_at']
                                                .toString()),
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          //     IconButton(
                                          IconButton(
                                            icon: Icon(
                                              Icons.sync,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () {
                                              AwesomeDialog(
                                                width: 500,
                                                context: context,
                                                dialogType: DialogType.warning,
                                                animType: AnimType.rightSlide,
                                                title:
                                                    'Está segur@ de cambiar a Estado RECHAZADO la Solicitud correspondiente al monto de \$ ${data[index]['monto'].toString()} y restaurar dicho valor?',
                                                desc: '',
                                                btnOkText: "Aceptar",
                                                btnCancelText: "Cancelar",
                                                btnOkColor: Colors.green,
                                                btnCancelOnPress: () {},
                                                btnOkOnPress: () async {
                                                  var response = await Connections()
                                                      .WithdrawalDenied(
                                                          data[index]['users_permissions_user']
                                                                  [0]['id']
                                                              .toString(),
                                                          data[index]['id']
                                                              .toString(),
                                                          data[index]['monto']
                                                              .toString(),
                                                          data[index]['rol_id']
                                                              .toString());
                                                  await loadData();
                                                },
                                              ).show();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 15.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '\$ ',
                                          style: TextStyle(
                                            fontSize: 25.0,
                                            color: data[index]['rol_id']
                                                        .toString() ==
                                                    "5"
                                                ? Colors.deepPurple
                                                : Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          data[index]['monto'].toString(),
                                          style: TextStyle(
                                            fontSize: 25.0,
                                            color: data[index]['rol_id']
                                                        .toString() ==
                                                    "5"
                                                ? Colors.deepPurple
                                                : Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors
                                                  .black), // Tamaño de fuente y color base
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: data[index]['rol_id']
                                                          .toString() ==
                                                      "5"
                                                  ? 'Proveedor'
                                                  : 'Tienda: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight
                                                      .bold), // Estilo para "Vendedor: "
                                            ),
                                            TextSpan(
                                              text: data[index][
                                                              'users_permissions_user'] !=
                                                          null &&
                                                      data[index][
                                                              'users_permissions_user']
                                                          .isNotEmpty
                                                  ? data[index]['users_permissions_user']
                                                                      [0][
                                                                  'vendedores'] !=
                                                              null &&
                                                          data[index]['users_permissions_user']
                                                                      [0]
                                                                  ['vendedores']
                                                              .isNotEmpty
                                                      ? '${data[index]['users_permissions_user'][0]['vendedores'][0]['nombre_comercial'].toString()}'
                                                      : ""
                                                  : "",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: data[index]['rol_id']
                                                          .toString() ==
                                                      "5"
                                                  ? 'Id Proveedor: '
                                                  : 'Id Vendedor: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text: data[index][
                                                              'users_permissions_user'] !=
                                                          null &&
                                                      data[index][
                                                              'users_permissions_user']
                                                          .isNotEmpty
                                                  ? "${data[index]['users_permissions_user'][0]['id'].toString()}"
                                                  : "",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors
                                                  .black), // Tamaño de fuente y color base
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: data[index]['rol_id']
                                                          .toString() ==
                                                      "5"
                                                  ? 'Proveedor: '
                                                  : 'Vendedor: ',

                                              style: TextStyle(
                                                  fontWeight: FontWeight
                                                      .bold), // Estilo para "Vendedor: "
                                            ),
                                            TextSpan(
                                              text: data[index][
                                                              'users_permissions_user'] !=
                                                          null &&
                                                      data[index][
                                                              'users_permissions_user']
                                                          .isNotEmpty
                                                  ? '${data[index]['users_permissions_user'][0]['username'].toString()}'
                                                  : "",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors
                                                  .black), // Tamaño de fuente y color base
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: 'Email: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight
                                                      .bold), // Estilo para "Email: "
                                            ),
                                            TextSpan(
                                              text: data[index][
                                                              'users_permissions_user'] !=
                                                          null &&
                                                      data[index][
                                                              'users_permissions_user']
                                                          .isNotEmpty
                                                  ? '${data[index]['users_permissions_user'][0]['email'].toString()}'
                                                  : "",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors
                                                  .black), // Tamaño de fuente y color base
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: 'Estado Pago: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight
                                                      .bold), // Estilo para "Estado Pago: "
                                            ),
                                            TextSpan(
                                              text:
                                                  '${data[index]['estado'].toString()}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.green),
                                        ),
                                        onPressed: () async {
                                          // Lógica para eliminar
                                          var dataAccountWithdrawal =
                                              await Connections()
                                                  .getAccountDatainWithdrawal(
                                                      data[index]["id"]);
                                          // ignore: use_build_context_synchronously
                                          AwesomeDialog(
                                            body: Column(
                                              children: [
                                                const Text("Realizar Pago",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                account(dataAccountWithdrawal),
                                                Container(
                                                  margin: const EdgeInsets.all(
                                                      15.0),
                                                  child: TextField(
                                                    controller:
                                                        supervisorController, // Asume que ya tienes este controlador
                                                    decoration: InputDecoration(
                                                      labelText: "Comentario",
                                                      labelStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                      prefixIcon: Icon(
                                                          Icons.comment,
                                                          color: ColorsSystem()
                                                              .colorSelectMenu),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: ColorsSystem()
                                                                .colorSelectMenu),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.blue),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.all(15.0),
                                                  child: ImageRow(
                                                      title:
                                                          'Cargar Comprobante:',
                                                      onSelect: (XFile image) {
                                                        setState(() {
                                                          imageSelect = image;
                                                        });
                                                      }),
                                                ),
                                              ],
                                            ),
                                            width: 500,
                                            context: context,
                                            dialogType: DialogType.info,
                                            animType: AnimType.rightSlide,
                                            btnOkText: "Aceptar",
                                            btnCancelText: "Cancelar",
                                            btnOkColor: Colors
                                                .green, // Asegúrate de que colors.colorGreen sea válido, aquí lo puse directamente como Colors.green
                                            btnCancelOnPress: () {
                                              supervisorController.clear();
                                            },
                                            btnOkOnPress: () async {
                                              if (imageSelect != null) {
                                                var response =
                                                    await Connections()
                                                        .postDoc(imageSelect!);

                                                if (supervisorController.text ==
                                                    "") {
                                                  supervisorController.text =
                                                      "Pago Realizado";
                                                }
                                                var finalresp =
                                                    await Connections()
                                                        .debitWithdrawal(
                                                            data[index]['id']
                                                                .toString(),
                                                            response[1]
                                                                .toString(),
                                                            supervisorController
                                                                .text,
                                                            data[index]
                                                                    ['rol_id']
                                                                .toString());
                                                supervisorController.clear();
                                                loadData();
                                              } else {
                                                _showErrorSnackBar(context,
                                                    "Campo del comprobante vacío, subir foto del comprobante.");
                                              }
                                              // String supervisorName =
                                              //     supervisorController.text;
                                              // if(supervisorName != "" ){
                                              // await Connections().updateRefererCost(
                                              //     dataL[index]['vendedor_id'].toString(),
                                              //     supervisorName);
                                              // loadData();
                                              // }else{
                                              //   _showErrorSnackBar(context, "Costo Referido Vacío, Ingrese un Valor.");
                                              // }
                                            },
                                          ).show();
                                          // } else {
                                          //   AwesomeDialog(
                                          //     body: Column(
                                          //       children: [
                                          //         Text("Realizar Pago",
                                          //             style: TextStyle(
                                          //                 fontSize: 18,
                                          //                 fontWeight:
                                          //                     FontWeight.bold)),
                                          //         Container(
                                          //           margin:
                                          //               EdgeInsets.all(15.0),
                                          //           child: TextField(
                                          //             controller:
                                          //                 supervisorController, // Asume que ya tienes este controlador
                                          //             // keyboardType:
                                          //             //     const TextInputType
                                          //             //         .numberWithOptions(
                                          //             //         decimal:
                                          //             //             true), // Permite números y punto decimal
                                          //             decoration:
                                          //                 InputDecoration(
                                          //               labelText: "Comentario",
                                          //               labelStyle:
                                          //                   const TextStyle(
                                          //                       color: Colors
                                          //                           .grey),
                                          //               prefixIcon: Icon(
                                          //                   Icons.comment,
                                          //                   color: ColorsSystem()
                                          //                       .colorSelectMenu),
                                          //               enabledBorder:
                                          //                   OutlineInputBorder(
                                          //                 borderSide: BorderSide(
                                          //                     color: ColorsSystem()
                                          //                         .colorSelectMenu),
                                          //                 borderRadius:
                                          //                     BorderRadius
                                          //                         .circular(
                                          //                             15.0),
                                          //               ),
                                          //               focusedBorder:
                                          //                   OutlineInputBorder(
                                          //                 borderSide:
                                          //                     BorderSide(
                                          //                         color: Colors
                                          //                             .blue),
                                          //                 borderRadius:
                                          //                     BorderRadius
                                          //                         .circular(
                                          //                             15.0),
                                          //               ),
                                          //               // Si deseas agregar un sufijo al campo de texto, puedes descomentar la siguiente línea
                                          //               // suffixIcon: Icon(Icons.check_circle, color: Colors.green),
                                          //             ),
                                          //           ),
                                          //         ),
                                          //         Container(
                                          //           margin:
                                          //               EdgeInsets.all(15.0),
                                          //           child: ImageRow(
                                          //               title:
                                          //                   'Cargar Comprobante:',
                                          //               onSelect:
                                          //                   (XFile image) {
                                          //                 setState(() {
                                          //                   imageSelect = image;
                                          //                 });
                                          //               }),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //     width: 500,
                                          //     context: context,
                                          //     dialogType: DialogType.info,
                                          //     animType: AnimType.rightSlide,
                                          //     btnOkText: "Aceptar",
                                          //     btnCancelText: "Cancelar",
                                          //     btnOkColor: Colors
                                          //         .green, // Asegúrate de que colors.colorGreen sea válido, aquí lo puse directamente como Colors.green
                                          //     btnCancelOnPress: () {
                                          //       supervisorController.clear();
                                          //     },
                                          //     btnOkOnPress: () async {
                                          //       if (imageSelect != null) {
                                          //         var response =
                                          //             await Connections()
                                          //                 .postDoc(
                                          //                     imageSelect!);

                                          //         if (supervisorController
                                          //                 .text ==
                                          //             "") {
                                          //           supervisorController.text =
                                          //               "Pago Realizado";
                                          //         }
                                          //         var finalresp =
                                          //             await Connections()
                                          //                 .debitWithdrawal(
                                          //                     data[index]['id']
                                          //                         .toString(),
                                          //                     response[1]
                                          //                         .toString(),
                                          //                     supervisorController
                                          //                         .text,
                                          //                     data[index]
                                          //                             ['rol_id']
                                          //                         .toString());
                                          //         // print(finalresp);
                                          //         supervisorController.clear();
                                          //         loadData();
                                          //       } else {
                                          //         _showErrorSnackBar(context,
                                          //             "Campo del comprobante vacío, subir foto del comprobante.");
                                          //       }
                                          //       // String supervisorName =
                                          //       //     supervisorController.text;
                                          //       // if(supervisorName != "" ){
                                          //       // await Connections().updateRefererCost(
                                          //       //     dataL[index]['vendedor_id'].toString(),
                                          //       //     supervisorName);
                                          //       // loadData();
                                          //       // }else{
                                          //       //   _showErrorSnackBar(context, "Costo Referido Vacío, Ingrese un Valor.");
                                          //       // }
                                          //     },
                                          //   ).show();
                                          // }
                                        },
                                        child: Text('Realizar Pago'),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                )
                              ],
                            ),
                          );
                        },
                      )
                    : getStringCheck() == "REALIZADO"
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing:
                                  20.0, // Espacio vertical entre elementos
                              crossAxisSpacing:
                                  20.0, // Espacio horizontal entre elementos
                              childAspectRatio:
                                  // adjustedAspectRatio, // Relación entre ancho y altura de cada tarjeta
                                  6, // Relación entre ancho y altura de cada tarjeta
                            ),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 3.0,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.document_scanner_rounded,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AprovedSellerWithdrawals(
                                                    model: "OrdenesRetiro",
                                                    sortFieldDefaultValue:
                                                        "id:DESC",
                                                    populate: [
                                                      'users_permissions_user.vendedores'
                                                    ],
                                                    arrayFiltersAnd: [
                                                      {"/estado": "REALIZADO"},
                                                      {
                                                        "equals/users_permissions_user.user_id":
                                                            data[index]['up_users']
                                                                    [0]['id']
                                                                .toString()
                                                      }
                                                    ],
                                                    arrayFiltersNot: [],
                                                    arrayFiltersOr: [
                                                      "monto",
                                                      "users_permissions_user.user_id",
                                                      "users_permissions_user.username",
                                                      "users_permissions_user.email",
                                                      "users_permissions_user.vendedores.nombre_comercial"
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              data[index]['up_users'] != null
                                                  ? "${data[index]['up_users'][0]['id'].toString()} | ${data[index]['up_users'][0]['username'].toString()} | ${data[index]['nombre_comercial'].toString()}"
                                                  : "",
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.blue,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : getStringCheck() == "REALIZADO PROVEEDOR"
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing:
                                      20.0, // Espacio vertical entre elementos
                                  crossAxisSpacing:
                                      20.0, // Espacio horizontal entre elementos
                                  childAspectRatio:
                                      // adjustedAspectRatio, // Relación entre ancho y altura de cada tarjeta
                                      6, // Relación entre ancho y altura de cada tarjeta
                                ),
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    elevation: 3.0,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons
                                                      .document_scanner_rounded,
                                                  color: Colors.orange,
                                                ),
                                                onPressed: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AprovedSellerWithdrawals(
                                                        model: "OrdenesRetiro",
                                                        sortFieldDefaultValue:
                                                            "id:DESC",
                                                        populate: [
                                                          'users_permissions_user.vendedores'
                                                        ],
                                                        arrayFiltersAnd: [
                                                          {
                                                            "/estado":
                                                                "REALIZADO"
                                                          },
                                                          {
                                                            "equals/users_permissions_user.user_id":
                                                                data[index]['user']
                                                                        ['id']
                                                                    .toString()
                                                          }
                                                        ],
                                                        arrayFiltersNot: [],
                                                        arrayFiltersOr: [
                                                          "monto",
                                                          "users_permissions_user.user_id",
                                                          "users_permissions_user.username",
                                                          "users_permissions_user.email",
                                                          "users_permissions_user.vendedores.nombre_comercial"
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              Expanded(
                                                child: Text(
                                                  data[index]['user'] != null
                                                      ? "${data[index]['user_id'].toString()} | ${data[index]['user']['username'].toString()} | ${data[index]['name'].toString()}"
                                                      : "",
                                                  style: const TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.blue,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  mainAxisSpacing:
                                      10.0, // Espacio vertical entre elementos
                                  crossAxisSpacing:
                                      10.0, // Espacio horizontal entre elementos
                                  childAspectRatio:
                                      adjustedAspectRatio, // Relación entre ancho y altura de cada tarjeta
                                ),
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    elevation: 3.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 8.0, right: 8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    UIUtils.formatDate(
                                                        data[index]
                                                                ['created_at']
                                                            .toString()),
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  // IconButton(
                                                  //   icon: Icon(
                                                  //     Icons.edit,
                                                  //     color: Colors.orange,
                                                  //   ),
                                                  //   onPressed: () {
                                                  //     print('Hola');
                                                  //     // AwesomeDialog(
                                                  //     //   width: 500,
                                                  //     //   context: context,
                                                  //     //   dialogType: DialogType.warning,
                                                  //     //   animType: AnimType.rightSlide,
                                                  //     //   title:
                                                  //     //       'Está segur@ de cambiar a Estado RECHAZADO la Solicitud correspondiente al monto de \$ ${data[index]['monto'].toString()} y restaurar dicho valor?',
                                                  //     //   desc: '',
                                                  //     //   btnOkText: "Aceptar",
                                                  //     //   btnCancelText: "Cancelar",
                                                  //     //   btnOkColor: colors.colorGreen,
                                                  //     //   btnCancelOnPress: () {},
                                                  //     //   btnOkOnPress: () async {
                                                  //     //     var response =
                                                  //     //         await Connections()
                                                  //     //             .WithdrawalDenied(
                                                  //     //               data[index]['users_permissions_user'][0]['id'].toString(),
                                                  //     //                 data[index]['id']
                                                  //     //                     .toString(),
                                                  //     //                 data[index]
                                                  //     //                         ['monto']
                                                  //     //                     .toString());
                                                  //     //     print(response);
                                                  //     //     await loadData();
                                                  //     //   },
                                                  //     // ).show();
                                                  //   },
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 25.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '\$ ',
                                                  style: TextStyle(
                                                    fontSize: 25.0,
                                                    color: data[index]['rol_id']
                                                                .toString() ==
                                                            "5"
                                                        ? Colors.deepPurple
                                                        : Colors.blue,
                                                  ),
                                                ),
                                                Text(
                                                  data[index]['monto']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 25.0,
                                                    color: data[index]['rol_id']
                                                                .toString() ==
                                                            "5"
                                                        ? Colors.deepPurple
                                                        : Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.0),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors
                                                          .black), // Tamaño de fuente y color base
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: data[index]
                                                                      ['rol_id']
                                                                  .toString() ==
                                                              "5"
                                                          ? "Proveedor"
                                                          : 'Tienda: ',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold), // Estilo para "Vendedor: "
                                                    ),
                                                    TextSpan(
                                                      text: data[index]['users_permissions_user'] !=
                                                                  null &&
                                                              data[index][
                                                                      'users_permissions_user']
                                                                  .isNotEmpty
                                                          ? data[index]['users_permissions_user']
                                                                              [0]
                                                                          [
                                                                          'vendedores'] !=
                                                                      null &&
                                                                  data[index]['users_permissions_user']
                                                                              [0]
                                                                          ['vendedores']
                                                                      .isNotEmpty
                                                              ? '${data[index]['users_permissions_user'][0]['vendedores'][0]['nombre_comercial'].toString()}'
                                                              : ""
                                                          : "",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: data[index]
                                                                      ['rol_id']
                                                                  .toString() ==
                                                              "5"
                                                          ? "Id Proveedor: "
                                                          : 'Id Vendedor: ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    TextSpan(
                                                      text: data[index][
                                                                      'users_permissions_user'] !=
                                                                  null &&
                                                              data[index][
                                                                      'users_permissions_user']
                                                                  .isNotEmpty
                                                          ? "${data[index]['users_permissions_user'][0]['id'].toString()}"
                                                          : "",
                                                      style: TextStyle(
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors
                                                          .black), // Tamaño de fuente y color base
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: data[index]
                                                                      ['rol_id']
                                                                  .toString() ==
                                                              "5"
                                                          ? "Proveedor: "
                                                          : 'Vendedor: ',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold), // Estilo para "Vendedor: "
                                                    ),
                                                    TextSpan(
                                                      text: data[index][
                                                                      'users_permissions_user'] !=
                                                                  null &&
                                                              data[index][
                                                                      'users_permissions_user']
                                                                  .isNotEmpty
                                                          ? '${data[index]['users_permissions_user'][0]['username'].toString()}'
                                                          : "",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors
                                                          .black), // Tamaño de fuente y color base
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: 'Email: ',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold), // Estilo para "Email: "
                                                    ),
                                                    TextSpan(
                                                      text: data[index][
                                                                      'users_permissions_user'] !=
                                                                  null &&
                                                              data[index][
                                                                      'users_permissions_user']
                                                                  .isNotEmpty
                                                          ? '${data[index]['users_permissions_user'][0]['email'].toString()}'
                                                          : "",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors
                                                          .black), // Tamaño de fuente y color base
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: 'Estado Pago: ',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold), // Estilo para "Estado Pago: "
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${data[index]['estado'].toString()}',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                        // Padding(
                                        //   padding: const EdgeInsets.only(
                                        //       left: 8.0, right: 8.0),
                                        //   child: Center(
                                        //     child: Container(
                                        //       width: double.infinity,
                                        //       child: ElevatedButton(
                                        //         style: ButtonStyle(
                                        //           backgroundColor:
                                        //               MaterialStatePropertyAll(
                                        //                   Colors.grey),
                                        //         ),
                                        //         onPressed: () {
                                        //           // Lógica para eliminar
                                        //         },
                                        //         child: Text('Ver Comprobante'),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        // SizedBox(
                                        //   height: 10.0,
                                        // )
                                      ],
                                    ),
                                  );
                                },
                              ))),
      ],
    );
  }

  Container account(data) {
    if (data["message"] == "Empty") {
      return Container();
    } else {
      return Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: data["data"]["bank_entity"] == "Pichincha"
              ? Colors.amber
              : Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data != [] ? data["data"]["bank_entity"] : "",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              data != [] ? 'Dni: ${data["data"]["dni"]}' : "",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              data != []
                  ? 'Propietario: ${data["data"]["names"]} ${data["data"]["last_name"]}'
                  : "",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              data != []
                  ? 'Número de cuenta: ${data["data"]["account_number"]}'
                  : "",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              data != []
                  ? 'Tipo de cuenta: ${data["data"]["account_type"]}'
                  : "",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
  }

  Column movilContainer(BuildContext context, double adjustedAspectRatio) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: _modelTextField(
                text: "Búsqueda", controller: _controllers.searchController),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Wrap(
          children: [
            Container(
              width: 150,
              child: Row(
                children: [
                  Checkbox(
                      value: aprobado,
                      onChanged: (value) async {
                        setState(() {
                          aprobado = true;
                          realizado = false;
                          realizadopro = false;
                          rechazado = false;
                        });
                        model = "OrdenesRetiro";

                        sortFieldDefaultValue = "id:DESC";
                        populate = [
                          'users_permissions_user.vendedores',
                        ];
                        arrayFiltersAnd = [
                          // {"/estado": "APROBADO"}
                        ];
                        arrayFiltersOr = [
                          "monto",
                          "users_permissions_user.user_id",
                          "users_permissions_user.username",
                          "users_permissions_user.email",
                          "users_permissions_user.vendedores.nombre_comercial"
                        ];
                        arrayFiltersNot = [];
                        updateOrAddEstadoFilter(arrayFiltersAnd);
                        await loadData();
                      }),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.checklist_rtl_sharp,
                    color: Colors.blue,
                  ),
                  Text("Aprobados")
                ],
              ),
            ),
            Container(
              width: 250,
              child: Row(
                children: [
                  Checkbox(
                      value: realizado,
                      onChanged: (value) async {
                        setState(() {
                          aprobado = false;
                          realizado = true;
                          realizadopro = false;
                          rechazado = false;
                        });
                        model = "Vendedore";
                        sortFieldDefaultValue = "id:ASC";
                        populate = [
                          'up_users',
                        ];
                        arrayFiltersAnd = [];
                        arrayFiltersOr = [
                          "nombre_comercial",
                          "up_users.user_id",
                          "up_users.username"
                        ];
                        arrayFiltersNot = [
                          {"id_master": ""}
                        ];
                        await loadData();
                      }),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  Text("Realizados Vendedores")
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.0,
        ),
        Wrap(children: [
          Container(
            width: 250,
            child: Row(
              children: [
                Checkbox(
                    value: realizadopro,
                    onChanged: (value) async {
                      setState(() {
                        aprobado = false;
                        realizado = false;
                        realizadopro = true;
                        rechazado = false;
                      });
                      model = "Provider";
                      sortFieldDefaultValue = "id:ASC";
                      populate = [
                        'user',
                      ];
                      arrayFiltersAnd = [];
                      arrayFiltersOr = [
                        "user.username",
                        "user.user_id",
                        "name"
                      ];
                      arrayFiltersNot = [];
                      await loadData();
                    }),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                Text("Realizados Proveedores")
              ],
            ),
          ),
          Container(
            width: 150,
            child: Row(
              children: [
                Checkbox(
                    value: rechazado,
                    onChanged: (value) async {
                      setState(() {
                        aprobado = false;
                        rechazado = true;
                        realizado = false;
                        realizadopro = false;
                      });
                      model = "OrdenesRetiro";

                      sortFieldDefaultValue = "id:DESC";
                      populate = [
                        'users_permissions_user.vendedores',
                      ];
                      arrayFiltersAnd = [
                        // {"/estado": "APROBADO"}
                      ];
                      arrayFiltersOr = [
                        "monto",
                        "users_permissions_user.user_id",
                        "users_permissions_user.username",
                        "users_permissions_user.email",
                        "users_permissions_user.vendedores.nombre_comercial"
                      ];
                      arrayFiltersNot = [];
                      updateOrAddEstadoFilter(arrayFiltersAnd);
                      await loadData();
                    }),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.close_outlined,
                  color: Colors.red,
                ),
                Text("Rechazados")
              ],
            ),
          )
        ]),
        SizedBox(
          height: 15.0,
        ),
        Expanded(
            child: Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[300]),
                child: getStringCheck() == "APROBADO"
                    ? ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        UIUtils.formatDate(data[index]
                                                ['created_at']
                                            .toString()),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.sync,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () {
                                          AwesomeDialog(
                                            width: 500,
                                            context: context,
                                            dialogType: DialogType.warning,
                                            animType: AnimType.rightSlide,
                                            title:
                                                'Está segur@ de cambiar a Estado RECHAZADO la Solicitud correspondiente al monto de \$ ${data[index]['monto'].toString()} y restaurar dicho valor?',
                                            desc: '',
                                            btnOkText: "Aceptar",
                                            btnCancelText: "Cancelar",
                                            btnOkColor: Colors.green,
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () async {
                                              var response = await Connections()
                                                  .WithdrawalDenied(
                                                      data[index]['users_permissions_user']
                                                              [0]['id']
                                                          .toString(),
                                                      data[index]['id']
                                                          .toString(),
                                                      data[index]['monto']
                                                          .toString(),
                                                      data[index]['rol_id']
                                                          .toString());
                                              await loadData();
                                            },
                                          ).show();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '\$ ',
                                      style: TextStyle(
                                        fontSize: 25.0,
                                        color:
                                            data[index]["rol_id"].toString() ==
                                                    "5"
                                                ? Colors.deepPurple
                                                : Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      data[index]['monto'].toString(),
                                      style: TextStyle(
                                        fontSize: 25.0,
                                        color:
                                            data[index]["rol_id"].toString() ==
                                                    "5"
                                                ? Colors.deepPurple
                                                : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors
                                              .black), // Tamaño de fuente y color base
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: data[index]["rol_id"]
                                                      .toString() ==
                                                  "5"
                                              ? "Proveedor "
                                              : 'Tienda: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight
                                                  .bold), // Estilo para "Vendedor: "
                                        ),
                                        TextSpan(
                                          text: data[index][
                                                          'users_permissions_user'] !=
                                                      null &&
                                                  data[index][
                                                          'users_permissions_user']
                                                      .isNotEmpty
                                              ? data[index]['users_permissions_user']
                                                                  [0]
                                                              ['vendedores'] !=
                                                          null &&
                                                      data[index]['users_permissions_user']
                                                              [0]['vendedores']
                                                          .isNotEmpty
                                                  ? '${data[index]['users_permissions_user'][0]['vendedores'][0]['nombre_comercial'].toString()}'
                                                  : ""
                                              : "",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: data[index]["rol_id"]
                                                      .toString() ==
                                                  "5"
                                              ? "Id Proveedor: "
                                              : 'Id Vendedor: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: data[index][
                                                          'users_permissions_user'] !=
                                                      null &&
                                                  data[index][
                                                          'users_permissions_user']
                                                      .isNotEmpty
                                              ? "${data[index]['users_permissions_user'][0]['id'].toString()}"
                                              : "",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors
                                              .black), // Tamaño de fuente y color base
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: data[index]["rol_id"]
                                                      .toString() ==
                                                  "5"
                                              ? "Proveedor: "
                                              : 'Vendedor: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight
                                                  .bold), // Estilo para "Vendedor: "
                                        ),
                                        TextSpan(
                                          text: data[index][
                                                          'users_permissions_user'] !=
                                                      null &&
                                                  data[index][
                                                          'users_permissions_user']
                                                      .isNotEmpty
                                              ? '${data[index]['users_permissions_user'][0]['username'].toString()}'
                                              : "",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors
                                              .black), // Tamaño de fuente y color base
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Email: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight
                                                  .bold), // Estilo para "Email: "
                                        ),
                                        TextSpan(
                                          text: data[index][
                                                          'users_permissions_user'] !=
                                                      null &&
                                                  data[index][
                                                          'users_permissions_user']
                                                      .isNotEmpty
                                              ? '${data[index]['users_permissions_user'][0]['email'].toString()}'
                                              : "",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors
                                              .black), // Tamaño de fuente y color base
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Estado Pago: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight
                                                  .bold), // Estilo para "Estado Pago: "
                                        ),
                                        TextSpan(
                                          text:
                                              '${data[index]['estado'].toString()}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.green),
                                        ),
                                        onPressed: () async {
                                          var dataAccountWithdrawal =
                                              await Connections()
                                                  .getAccountDatainWithdrawal(
                                                      data[index]["id"]);
                                          // Lógica para eliminar
                                          AwesomeDialog(
                                            body: Column(
                                              children: [
                                                Text("Realizar Pago",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                // Text("Ingrese Comentario:"),
                                                account(dataAccountWithdrawal),
                                                Container(
                                                  margin: EdgeInsets.all(15.0),
                                                  child: TextField(
                                                    controller:
                                                        supervisorController, // Asume que ya tienes este controlador
                                                    // keyboardType:
                                                    //     const TextInputType
                                                    //         .numberWithOptions(
                                                    //         decimal:
                                                    //             true), // Permite números y punto decimal
                                                    decoration: InputDecoration(
                                                      labelText: "Comentario",
                                                      labelStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                      prefixIcon: Icon(
                                                          Icons.comment,
                                                          color: ColorsSystem()
                                                              .colorSelectMenu),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: ColorsSystem()
                                                                .colorSelectMenu),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.blue),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      // Si deseas agregar un sufijo al campo de texto, puedes descomentar la siguiente línea
                                                      // suffixIcon: Icon(Icons.check_circle, color: Colors.green),
                                                    ),
                                                  ),
                                                ),
                                                // Text(""),
                                                Container(
                                                  margin: EdgeInsets.all(15.0),
                                                  child: ImageRow(
                                                      title:
                                                          'Cargar Comprobante:',
                                                      onSelect: (XFile image) {
                                                        setState(() {
                                                          imageSelect = image;
                                                        });
                                                      }),
                                                ),
                                              ],
                                            ),
                                            width: 500,
                                            context: context,
                                            dialogType: DialogType.info,
                                            animType: AnimType.rightSlide,
                                            btnOkText: "Aceptar",
                                            btnCancelText: "Cancelar",
                                            btnOkColor: Colors
                                                .green, // Asegúrate de que colors.colorGreen sea válido, aquí lo puse directamente como Colors.green
                                            btnCancelOnPress: () {
                                              supervisorController.clear();
                                            },
                                            btnOkOnPress: () async {
                                              if (imageSelect != null) {
                                                var response =
                                                    await Connections()
                                                        .postDoc(imageSelect!);

                                                if (supervisorController.text ==
                                                    "") {
                                                  supervisorController.text =
                                                      "Pago Realizado";
                                                }
                                                var finalresp = await Connections()
                                                    .WithdrawalDone(
                                                        data[index]['id']
                                                            .toString(),
                                                        response[1].toString(),
                                                        supervisorController
                                                            .text);
                                                supervisorController.clear();
                                                loadData();
                                              }
                                              // String supervisorName =
                                              //     supervisorController.text;
                                              // if(supervisorName != "" ){
                                              // await Connections().updateRefererCost(
                                              //     dataL[index]['vendedor_id'].toString(),
                                              //     supervisorName);
                                              // loadData();
                                              // }else{
                                              //   _showErrorSnackBar(context, "Costo Referido Vacío, Ingrese un Valor.");
                                              // }
                                            },
                                          ).show();
                                        },
                                        child: Text('Realizar Pago'),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                )
                              ],
                            ),
                          );
                        },
                      )
                    : getStringCheck() == "REALIZADO"
                        ? ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 3.0,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.document_scanner_rounded,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AprovedSellerWithdrawals(
                                                    model: "OrdenesRetiro",
                                                    sortFieldDefaultValue:
                                                        "id:DESC",
                                                    populate: [
                                                      'users_permissions_user.vendedores'
                                                    ],
                                                    arrayFiltersAnd: [
                                                      {"/estado": "REALIZADO"},
                                                      {
                                                        "equals/users_permissions_user.user_id":
                                                            data[index]['up_users']
                                                                    [0]['id']
                                                                .toString()
                                                      }
                                                    ],
                                                    arrayFiltersNot: [],
                                                    arrayFiltersOr: [
                                                      "monto",
                                                      "users_permissions_user.user_id",
                                                      "users_permissions_user.username",
                                                      "users_permissions_user.email",
                                                      "users_permissions_user.vendedores.nombre_comercial"
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              data[index]['up_users'] != null
                                                  ? "${data[index]['up_users'][0]['id'].toString()} | ${data[index]['up_users'][0]['username'].toString()} | ${data[index]['nombre_comercial'].toString()}"
                                                  : "",
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.blue,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : getStringCheck() == "REALIZADO PROVEEDOR"
                            ? ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    elevation: 3.0,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons
                                                      .document_scanner_rounded,
                                                  color: Colors.orange,
                                                ),
                                                onPressed: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AprovedSellerWithdrawals(
                                                        model: "OrdenesRetiro",
                                                        sortFieldDefaultValue:
                                                            "id:DESC",
                                                        populate: [
                                                          'users_permissions_user.vendedores'
                                                        ],
                                                        arrayFiltersAnd: [
                                                          {
                                                            "/estado":
                                                                "REALIZADO"
                                                          },
                                                          {
                                                            "equals/users_permissions_user.user_id":
                                                                data[index][
                                                                        'user_id']
                                                                    .toString()
                                                          }
                                                        ],
                                                        arrayFiltersNot: [],
                                                        arrayFiltersOr: [
                                                          "monto",
                                                          "users_permissions_user.user_id",
                                                          "users_permissions_user.username",
                                                          "users_permissions_user.email",
                                                          "users_permissions_user.vendedores.nombre_comercial"
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              Expanded(
                                                child: Text(
                                                  data[index]['user'] != null
                                                      ? "${data[index]['user_id'].toString()} | ${data[index]['user']['username'].toString()} | ${data[index]['name'].toString()}"
                                                      : "",
                                                  style: const TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.blue,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    elevation: 3.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.0, right: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                UIUtils.formatDate(data[index]
                                                        ['created_at']
                                                    .toString()),
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 15.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '\$ ',
                                              style: TextStyle(
                                                fontSize: 25.0,
                                                color: data[index]["rol_id"]
                                                            .toString() ==
                                                        "5"
                                                    ? Colors.deepPurple
                                                    : Colors.blue,
                                              ),
                                            ),
                                            Text(
                                              data[index]['monto'].toString(),
                                              style: TextStyle(
                                                fontSize: 25.0,
                                                color: data[index]["rol_id"]
                                                            .toString() ==
                                                        "5"
                                                    ? Colors.deepPurple
                                                    : Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors
                                                      .black), // Tamaño de fuente y color base
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: data[index]["rol_id"]
                                                              .toString() ==
                                                          "5"
                                                      ? "Proveedor "
                                                      : 'Tienda: ',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold), // Estilo para "Vendedor: "
                                                ),
                                                TextSpan(
                                                  text: data[index][
                                                                  'users_permissions_user'] !=
                                                              null &&
                                                          data[index][
                                                                  'users_permissions_user']
                                                              .isNotEmpty
                                                      ? data[index]['users_permissions_user']
                                                                          [0][
                                                                      'vendedores'] !=
                                                                  null &&
                                                              data[index]['users_permissions_user']
                                                                          [0]
                                                                      ['vendedores']
                                                                  .isNotEmpty
                                                          ? '${data[index]['users_permissions_user'][0]['vendedores'][0]['nombre_comercial'].toString()}'
                                                          : ""
                                                      : "",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: data[index]["rol_id"]
                                                              .toString() ==
                                                          "5"
                                                      ? "Id Proveedor: "
                                                      : 'Id Vendedor: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text: data[index][
                                                                  'users_permissions_user'] !=
                                                              null &&
                                                          data[index][
                                                                  'users_permissions_user']
                                                              .isNotEmpty
                                                      ? "${data[index]['users_permissions_user'][0]['id'].toString()}"
                                                      : "",
                                                  style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors
                                                      .black), // Tamaño de fuente y color base
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: data[index]["rol_id"]
                                                              .toString() ==
                                                          "5"
                                                      ? "Proveedor: "
                                                      : 'Vendedor: ',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold), // Estilo para "Vendedor: "
                                                ),
                                                TextSpan(
                                                  text: data[index][
                                                                  'users_permissions_user'] !=
                                                              null &&
                                                          data[index][
                                                                  'users_permissions_user']
                                                              .isNotEmpty
                                                      ? '${data[index]['users_permissions_user'][0]['username'].toString()}'
                                                      : "",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors
                                                      .black), // Tamaño de fuente y color base
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: 'Email: ',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold), // Estilo para "Email: "
                                                ),
                                                TextSpan(
                                                  text: data[index][
                                                                  'users_permissions_user'] !=
                                                              null &&
                                                          data[index][
                                                                  'users_permissions_user']
                                                              .isNotEmpty
                                                      ? '${data[index]['users_permissions_user'][0]['email'].toString()}'
                                                      : "",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors
                                                      .black), // Tamaño de fuente y color base
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: 'Estado Pago: ',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold), // Estilo para "Estado Pago: "
                                                ),
                                                TextSpan(
                                                  text:
                                                      '${data[index]['estado'].toString()}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ))),
      ],
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (v) async {
          await loadData();
          setState(() {});
        },
        onChanged: (value) {
          setState(() {});
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                    await loadData();
                  },
                  child: const Icon(Icons.close),
                )
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  getStringCheck() {
    if (aprobado == true) {
      return "APROBADO";
    }
    if (realizado == true) {
      return "REALIZADO";
    }
    if (realizadopro == true) {
      return "REALIZADO PROVEEDOR";
    }
    if (rechazado == true) {
      return "RECHAZADO";
    }
  }

  sortFunc(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes'][name]
          .toString()
          .compareTo(a['attributes'][name].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes'][name]
          .toString()
          .compareTo(b['attributes'][name].toString()));
    }
  }

  void _showErrorSnackBar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: TextStyle(color: Color.fromRGBO(7, 0, 0, 1)),
        ),
        backgroundColor: Color.fromARGB(255, 253, 101, 90),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
