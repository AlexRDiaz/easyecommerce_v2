import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/vendor_withdrawal_request_laravel/withdrawal_details_laravel.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/forms/image_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:number_paginator/number_paginator.dart';

class AprovedSellerWithdrawals extends StatefulWidget {
  // int currentPage;
  // int pageSize;
  // int pageCount;
  // bool isLoading;
  // int total;

  final String model;
  final String sortFieldDefaultValue;
  final List populate;
  final List arrayFiltersAnd;
  final List arrayFiltersOr;
  final List arrayFiltersNot;

  const AprovedSellerWithdrawals({
    Key? key,
    // this.currentPage = 1,
    // this.pageSize = 5,
    // this.pageCount = 1,
    // this.isLoading = false,
    // this.total = 0,
    required this.model,
    required this.sortFieldDefaultValue,
    required this.populate,
    required this.arrayFiltersAnd,
    required this.arrayFiltersNot,
    required this.arrayFiltersOr,
  }) : super(key: key);

  @override
  State<AprovedSellerWithdrawals> createState() =>
      _AprovedSellerWithdrawalsState();
}

class _AprovedSellerWithdrawalsState extends State<AprovedSellerWithdrawals> {
  TextEditingController inputcontroller = TextEditingController();
  TextEditingController commentupdateController = TextEditingController();
  NumberPaginatorController paginatorController = NumberPaginatorController();
  List data = [];
  bool realizado = true;
  bool paginate = false;
  int currentPage = 1;
  int pageSize = 50;
  int pageCount = 0;

  bool isLoading = false;
  XFile? imageSelect = null;

  @override
  void dispose() {
    // Asegúrate de desechar el controlador cuando el widget sea descartado
    // myController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    setState(() {
      isLoading = true;
      currentPage = 1;
    });
    var response = await Connections().generalData(
        pageSize,
        currentPage,
        widget.populate,
        widget.arrayFiltersNot,
        widget.arrayFiltersAnd,
        widget.arrayFiltersOr,
        inputcontroller.text,
        widget.model,
        "",
        "",
        "",
        widget.sortFieldDefaultValue);

    setState(() {
      data = [];
      data = response['data'];
      paginatorController.navigateToPage(0);
      pageCount = response['last_page'];

      isLoading = false;
    });
  }

  paginateData() async {
    try {
      setState(() {
        isLoading = true;
      });

      var response = await Connections().generalData(
          pageSize,
          currentPage,
          widget.populate,
          widget.arrayFiltersNot,
          widget.arrayFiltersAnd,
          widget.arrayFiltersOr,
          inputcontroller.text,
          widget.model,
          "",
          "",
          "",
          widget.sortFieldDefaultValue);

      setState(() {
        data = [];
        data = response['data'];
      });

      // Future.delayed(const Duration(milliseconds: 500), () {
      // Navigator.pop(context);
      // });

      isLoading = false;
    } catch (e) {
      // Navigator.pop(context);

      // _showErrorSnackBar(context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    double adjustedAspectRatio = calculateAdjustedAspectRatio(context);
    return CustomProgressModal(
        isLoading: isLoading,
        content: AlertDialog(
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                child: responsive(webContainer(context, adjustedAspectRatio),
                    movilContainer(context, adjustedAspectRatio), context))));
  }

  double calculateAdjustedAspectRatio(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final screenSize = MediaQuery.of(context).size;

    // Calcular la relación entre el ancho y la altura de la pantalla
    final aspectRatio = screenSize.width / screenSize.height;

    print("${screenSize.width} - ${screenSize.height}");
    // Definir el aspecto base de las tarjetas (puede ajustarse según lo que necesites)
    double baseAspectRatio;

    // Definir el aspecto base según la resolución
    if (screenSize.width == 1440 && screenSize.height == 821) {
      baseAspectRatio = 0.5; // Aspecto base para 1920x1080
    } else if (screenSize.width == 1366 &&
        (screenSize.height >= 689 && screenSize.height <= 695)) {
      baseAspectRatio = 0.5; // Aspecto base para 1440x900
    } else {
      baseAspectRatio = 0.7; // Aspecto base por defecto
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

  getStringCheck() {
    if (realizado == true) {
      return "REALIZADO";
    }
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonSelectedBackgroundColor: Color.fromARGB(255, 71, 71, 71),
        // buttonUnselectedBackgroundColor: Color.fromARGB(255, 71, 71, 71),
        buttonSelectedForegroundColor: Colors.white,
        buttonUnselectedForegroundColor: Colors.black,
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      onPageChange: (index) async {
        paginate = true;
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await paginateData();
        }
      },
    );
  }

  Column webContainer(BuildContext context, double adjustedAspectRatio) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: _modelTextField(text: "Búsqueda", controller: inputcontroller),
        ),
      ),
      SizedBox(
        height: 10.0,
      ),
      Row(
        children: [
          Expanded(child: numberPaginator()),
        ],
      ),
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
              child: principal(data, adjustedAspectRatio)))
    ]);
  }

  Column movilContainer(BuildContext context, double adjustedAspectRatio) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: _modelTextField(text: "Búsqueda", controller: inputcontroller),
        ),
      ),
      SizedBox(
        height: 10.0,
      ),
      Row(
        children: [
          Expanded(child: numberPaginator()),
        ],
      ),
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
              child: movilprincipal(data, adjustedAspectRatio)))
    ]);
  }

  Widget principal(data, adjustedAspectRatio) {
    print(data.length);
    if (data.length == 0) {
      return const Center(
          child: Text("No se han generado Solicitudes de Retiro"));
    } else {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10.0, // Espacio vertical entre elementos
          crossAxisSpacing: 5.0, // Espacio horizontal entre elementos
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
                      padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            UIUtils.formatDate(
                                data[index]['updated_at'].toString()),
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.orange,
                            ),
                            onPressed: () {
                              // print('Hola');
                              commentupdateController.text =
                                  data[index]['comentario'].toString();
                              AwesomeDialog(
                                  body: Column(
                                    children: [
                                      Text("Actualizar información",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      // Text("Ingrese Comentario:"),
                                      Container(
                                        margin: EdgeInsets.all(15.0),
                                        child: TextField(
                                          controller:
                                              commentupdateController, // Asume que ya tienes este controlador
                                          // keyboardType:
                                          //     const TextInputType
                                          //         .numberWithOptions(
                                          //         decimal:
                                          //             true), // Permite números y punto decimal
                                          decoration: InputDecoration(
                                            labelText: "Comentario",
                                            labelStyle: const TextStyle(
                                                color: Colors.grey),
                                            prefixIcon: Icon(Icons.comment,
                                                color: ColorsSystem()
                                                    .colorSelectMenu),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: ColorsSystem()
                                                      .colorSelectMenu),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
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
                                            title: 'Actualizar Comprobante:',
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
                                    commentupdateController.clear();
                                  },
                                  btnOkOnPress: () async {
                                    // WithdrawalIntern
                                    if (imageSelect != null) {
                                      var response = await Connections()
                                          .postDoc(imageSelect!);

                                      if (commentupdateController.text == "") {
                                        // supervisorController.text =
                                        //     "Pago Realizado";
                                      }
                                      await Connections().WithdrawalIntern(
                                          data[index]['id'].toString(),
                                          response[1].toString(),
                                          commentupdateController.text);
                                      commentupdateController.clear();
                                      loadData();
                                    } else {
                                      await Connections().WithdrawalIntern(
                                          data[index]['id'].toString(),
                                          data[index]['comprobante'].toString(),
                                          commentupdateController.text);
                                      commentupdateController.clear();
                                      loadData();
                                    }
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
                                  // },
                                  ).show();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Padding(padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         UIUtils.formatDate(
                    //             data[index]['updated_at'].toString()),
                    //         style: TextStyle(
                    //           fontSize: 16.0,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),),

                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$ ',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: data[index]['rol_id'].toString() == "5"
                            ? Colors.deepPurple : Colors.blue,
                          ),
                        ),
                        Text(
                          data[index]['monto'].toString(),
                          style: TextStyle(
                            fontSize: 20.0,
                            color: data[index]['rol_id'].toString() == "5"
                            ? Colors.deepPurple : Colors.blue,
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
                              text:  data[index]['rol_id']
                                                          .toString() ==
                                                      "5"
                                                  ? "Proveedor ":'Tienda: ',
                              style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold), // Estilo para "Vendedor: "
                            ),
                            TextSpan(
                              text: data[index]['users_permissions_user'] !=
                                          null &&
                                      data[index]['users_permissions_user']
                                          .isNotEmpty
                                  ? data[index]['users_permissions_user'][0]
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text:  data[index]['rol_id']
                                                          .toString() ==
                                                      "5"
                                                  ? "Id Proveedor: ":'Id Vendedor: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: data[index]['users_permissions_user'] !=
                                          null &&
                                      data[index]['users_permissions_user']
                                          .isNotEmpty
                                  ? "${data[index]['users_permissions_user'][0]['id'].toString()}"
                                  : "",
                              style: TextStyle(fontStyle: FontStyle.italic),
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
                              fontSize: 14.0,
                              color: Colors
                                  .black), // Tamaño de fuente y color base
                          children: <TextSpan>[
                            TextSpan(
                              text:  data[index]['rol_id']
                                                          .toString() ==
                                                      "5"
                                                  ? "Proveedor: " :'Vendedor: ',
                              style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold), // Estilo para "Vendedor: "
                            ),
                            TextSpan(
                              text: data[index]['users_permissions_user'] !=
                                          null &&
                                      data[index]['users_permissions_user']
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
                              fontSize: 14.0,
                              color: Colors
                                  .black), // Tamaño de fuente y color base
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Email: ',
                              style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold), // Estilo para "Email: "
                            ),
                            TextSpan(
                              text: data[index]['users_permissions_user'] !=
                                          null &&
                                      data[index]['users_permissions_user']
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
                              fontSize: 14.0,
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
                              text: '${data[index]['estado'].toString()}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                        ),
                        onPressed: () async {
                          // Lógica para eliminar
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return WithdrawalDetailsLaravel(
                                  dataT: data[index],
                                );
                              });
                        },
                        child: Text('Ver Comprobante'),
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
      );
    }
  }

  Widget movilprincipal(data, adjustedAspectRatio) {
    print(data.length);
    if (data.length == 0) {
      return const Center(
          child: Text("No se han generado Solicitudes de Retiro"));
    } else {
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        UIUtils.formatDate(
                            data[index]['updated_at'].toString()),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          // print('Hola');
                          commentupdateController.text =
                              data[index]['comentario'].toString();
                          AwesomeDialog(
                              body: Column(
                                children: [
                                  Text("Actualizar información",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  // Text("Ingrese Comentario:"),
                                  Container(
                                    margin: EdgeInsets.all(15.0),
                                    child: TextField(
                                      controller:
                                          commentupdateController, // Asume que ya tienes este controlador
                                      // keyboardType:
                                      //     const TextInputType
                                      //         .numberWithOptions(
                                      //         decimal:
                                      //             true), // Permite números y punto decimal
                                      decoration: InputDecoration(
                                        labelText: "Comentario",
                                        labelStyle:
                                            const TextStyle(color: Colors.grey),
                                        prefixIcon: Icon(Icons.comment,
                                            color:
                                                ColorsSystem().colorSelectMenu),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ColorsSystem()
                                                  .colorSelectMenu),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
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
                                        title: 'Cargar Comprobante:',
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
                                commentupdateController.clear();
                              },
                              btnOkOnPress: () async {
                                // WithdrawalIntern
                                if (imageSelect != null) {
                                  var response =
                                      await Connections().postDoc(imageSelect!);

                                  if (commentupdateController.text == "") {
                                    // supervisorController.text =
                                    //     "Pago Realizado";
                                  }
                                  await Connections().WithdrawalIntern(
                                      data[index]['id'].toString(),
                                      response[1].toString(),
                                      commentupdateController.text);
                                  commentupdateController.clear();
                                  loadData();
                                } else {
                                  await Connections().WithdrawalIntern(
                                      data[index]['id'].toString(),
                                      data[index]['comprobante'].toString(),
                                      commentupdateController.text);
                                  commentupdateController.clear();
                                  loadData();
                                }
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
                              // },
                              ).show();
                        },
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.only(left: 8.0, right: 8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       IconButton(
                //         icon: Icon(
                //           Icons.sync,
                //           color: Colors.orange,
                //         ),
                //         onPressed: () {
                //           // print('Hola');
                //           AwesomeDialog(
                //             width: 500,
                //             context: context,
                //             dialogType: DialogType.warning,
                //             animType: AnimType.rightSlide,
                //             title:
                //                 'Está segur@ de cambiar a Estado RECHAZADO la Solicitud correspondiente al monto de \$ ${data[index]['monto'].toString()} y restaurar dicho valor?',
                //             desc: '',
                //             btnOkText: "Aceptar",
                //             btnCancelText: "Cancelar",
                //             btnOkColor: Colors.green,
                //             btnCancelOnPress: () {},
                //             btnOkOnPress: () async {
                //               var response = await Connections()
                //                   .WithdrawalDenied(
                //                       data[index]['users_permissions_user'][0]
                //                               ['id']
                //                           .toString(),
                //                       data[index]['id'].toString(),
                //                       data[index]['monto'].toString());
                //               print(response);
                //               await loadData();
                //             },
                //           ).show();
                //         },
                //       ),

                //     ],
                //   ),
                // ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$ ',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: data[index]['rol_id'].toString() == "5"
                            ? Colors.deepPurple
                            : Colors.blue,
                      ),
                    ),
                    Text(
                      data[index]['monto'].toString(),
                      style: TextStyle(
                        fontSize: 20.0,
                        color: data[index]['rol_id'].toString() == "5"
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
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text:  data[index]['rol_id']
                                                          .toString() ==
                                                      "5"
                                                  ? "Id Proveedor:" :'Id Vendedor: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: data[index]['users_permissions_user'] != null &&
                                  data[index]['users_permissions_user']
                                      .isNotEmpty
                              ? "${data[index]['users_permissions_user'][0]['id'].toString()}"
                              : "",
                          style: TextStyle(fontStyle: FontStyle.italic),
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
                          fontSize: 14.0,
                          color: Colors.black), // Tamaño de fuente y color base
                      children: <TextSpan>[
                        TextSpan(
                          text: data[index]['rol_id']
                                                          .toString() ==
                                                      "5"
                                                  ? "Proveedor: " : 'Vendedor: ',
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.bold), // Estilo para "Vendedor: "
                        ),
                        TextSpan(
                          text: data[index]['users_permissions_user'] != null &&
                                  data[index]['users_permissions_user']
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
                          fontSize: 14.0,
                          color: Colors.black), // Tamaño de fuente y color base
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Email: ',
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.bold), // Estilo para "Email: "
                        ),
                        TextSpan(
                          text: data[index]['users_permissions_user'] != null &&
                                  data[index]['users_permissions_user']
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
                          fontSize: 14.0,
                          color: Colors.black), // Tamaño de fuente y color base
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Estado Pago: ',
                          style: TextStyle(
                              fontWeight: FontWeight
                                  .bold), // Estilo para "Estado Pago: "
                        ),
                        TextSpan(
                          text: '${data[index]['estado'].toString()}',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                        ),
                        onPressed: () async {
                          // Lógica para eliminar
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return WithdrawalDetailsLaravel(
                                  dataT: data[index],
                                );
                              });
                        },
                        child: Text('Ver Comprobante'),
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
      );
    }
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
          // setState(() {});
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: inputcontroller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    setState(() {
                      inputcontroller.clear();
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
}
