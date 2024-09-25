import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/cash_withdrawals_sellers.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/sellers/pin_input_seller.dart';

import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';

class SellerWithdrawalDetails extends StatefulWidget {
  const SellerWithdrawalDetails({
    super.key,
  });

  @override
  State<SellerWithdrawalDetails> createState() =>
      _SellerWithdrawalDetailsState();
}

class _SellerWithdrawalDetailsState extends State<SellerWithdrawalDetails> {
  late CashWithdrawalsSellersControllers _controllers =
      CashWithdrawalsSellersControllers();

  String saldo = "";
  bool isLoading = false;
  String code = "";

  // Color initialContainer = Color(0xFFB6D8FF);
  // Color interContainer = Color(0xFFE8DFF8);
  // Color colorlabels = Color(0xFF2E2F39);
  // Color colorsection = Color.fromARGB(255, 243, 243, 245);
  // Color colorselected = Color(0xFF008BF1);
  // Color colorstore = Color(0xFF002163);

  @override
  void initState() {
    // getSaldo();
    getSaldoVersion1();
    super.initState();
  }

  getSaldo() async {
    saldo = await Connections().getSaldo();
    setState(() {});
  }

  getSaldoVersion1() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await Connections().getWalletValueLaravel();
      var tempWallet2 = double.parse(response.toString());
      saldo = tempWallet2.toStringAsFixed(2);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Solicitud de retiro",
              style: TextStylesSystem().ralewayStyle(
                  20, FontWeight.bold, ColorsSystem().colorLabels)),
          iconTheme: IconThemeData(
            color: ColorsSystem()
                .colorLabels, // Cambia esto por el color que desees
          ),
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            // margin: EdgeInsets.all(22),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Stack(children: [
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: ColorsSystem().colorInitialContainer,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: ColorsSystem().colorSection,
                    ),
                  ),
                ],
              ),
              responsive(
                  webPositioned(context), phonePositioned(context), context)
            ])),
      ),
    );
  }

  Positioned webPositioned(BuildContext context) {
    // Usar el tamaño de la pantalla disponible
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: mediaHeight *
          0.05, // Usar un 10% del alto de la pantalla como separación superior
      left: mediaWidth * 0.05, // Separación lateral del 5%
      right: mediaWidth * 0.05, // Separación lateral del 5%
      height: mediaHeight *
          0.7, // Ajustar a un 70% de la pantalla para el contenedor
      child: Container(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              width: mediaWidth * 0.41, // 41% del ancho de la pantalla
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "\$ $saldo",
                            style: TextStyle(
                              fontSize: 28,
                              color: ColorsSystem().colorSelected,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Saldo Actual",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Usar . (punto) para los valores con decimales, si el valor no contiene decimales no usar . (punto)",
                    style: TextStylesSystem()
                        .ralewayStyle(16, FontWeight.w500, Colors.red),
                    softWrap: true,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: mediaWidth *
                        0.5, // Adaptar el campo de texto al 50% del ancho de la pantalla
                    margin: EdgeInsets.all(15.0),
                    child: TextField(
                      controller: _controllers.montoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        labelText: "Monto a Retirar",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: ColorsSystem().colorSelectMenu,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorsSystem().colorSelectMenu),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: mediaWidth *
                        0.5, // Botón con el 50% del ancho de la pantalla
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsSystem().colorSelected,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          "Guardar",
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () async {
                          // getLoadingModal(context, false);
                          if (double.parse(saldo) >=
                              double.parse(_controllers.montoController.text
                                  .toString())) {
                            sendWithdrawal();
                          }
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned phonePositioned(BuildContext context) {
    return Positioned(
        top: MediaQuery.of(context).size.height * 0.04,
        left: 8,
        right: 8,
        height: MediaQuery.of(context)
            .size
            .height, // Altura de un cuarto de la pantalla
        child: Column(children: [
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              width: MediaQuery.of(context).size.width * 0.65,
              child: Row(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Para alinear todo a la izquierda
                          children: [
                            Text(
                              "\$ $saldo",
                              style: TextStyle(
                                fontSize: 18,
                                color: ColorsSystem().colorSelected,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Saldo Actual",
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.5, // Para que ocupe todo el ancho disponible
                      // padding: EdgeInsets.all(15.0),
                      child: Text(
                        "Usar . (punto) para los valores con decimales, si el valor no contiene decimales no usar . (punto)",
                        style: TextStylesSystem()
                            .ralewayStyle(12, FontWeight.w500, Colors.red),
                        softWrap:
                            true, // Permite que el texto se ajuste en múltiples líneas
                        maxLines: 5, // Opcional: Limitar el número de líneas
                        overflow: TextOverflow
                            .ellipsis, // Muestra "..." si el texto es muy largo
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 180, // Ajusta el ancho
                      // margin: EdgeInsets.all(15.0),
                      child: TextField(
                        controller: _controllers.montoController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: InputDecoration(
                          labelText: "Monto a Retirar",
                          labelStyle:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: Icon(Icons.attach_money,
                              color: ColorsSystem().colorSelectMenu),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorsSystem().colorSelectMenu),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10), // Ajusta la altura aquí
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 180,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsSystem().colorSelected,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        child: Text(
                          "Guardar",
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 12,
                            color: Colors.white, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () async {
                          // getLoadingModal(context, false);
                          if (double.parse(saldo) >=
                              double.parse(_controllers.montoController.text
                                  .toString())) {
                            sendWithdrawal();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                )
              ]))
        ]));
  }

  void   sendWithdrawal() async {
    setState(() {
      isLoading = true;
    });
    var resultSendWithdrawal = await Connections()
        .sendWithdrawalSeller(_controllers.montoController.text);
    if (resultSendWithdrawal["res"] == 0) {
      setState(() {
        code = resultSendWithdrawal['response'].toString();
        isLoading = false;
      });
      codeInputDialog(context);
    } else {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: resultSendWithdrawal['response'],
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.redAccent,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<dynamic> codeInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height / 2.5,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close),
                    ),
                  ),
                  Expanded(
                      child: PinInputSeller(
                          code: code,
                          amount: _controllers.montoController.text))
                ],
              ),
            ),
          );
        });
  }
}
