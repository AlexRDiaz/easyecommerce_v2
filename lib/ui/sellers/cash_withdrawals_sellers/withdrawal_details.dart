import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/loading.dart';

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
    var response = await Connections().getWalletValueLaravel();
    var tempWallet2 = double.parse(response.toString());
    saldo = tempWallet2.toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context, "/layout/sellers");
            },
            child: Icon(Icons.arrow_back_ios, color: Colors.black)),
        centerTitle: true,
        title: Text(
          "Solicitar retiro",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "Saldo disponible: $saldo",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "Usar . (punto) para los valores con decimales, si el valor no contiene decimales no usar . (punto)",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                // InputRow(
                //     controller: _controllers.montoController,
                //     title: 'Monto a Retirar'),
                Container(
                  width: 500,
                  margin: EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _controllers
                        .montoController, // Asume que ya tienes este controlador
                    // keyboardType: TextInputType
                    //     .number, // Muestra el teclado numérico
                    // inputFormatters: [
                    //   FilteringTextInputFormatter
                    //       .digitsOnly
                    // ],
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true), // Permite números y punto decimal
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(
                          r'^\d*\.?\d*')), // Expresión regular para números con o sin decimales
                    ],
                    decoration: InputDecoration(
                      labelText: "Monto a Retirar",
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.attach_money,
                          color: ColorsSystem().colorSelectMenu),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: ColorsSystem().colorSelectMenu),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      // Si deseas agregar un sufijo al campo de texto, puedes descomentar la siguiente línea
                      // suffixIcon: Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: 500,
                    child: ElevatedButton(
                      child: Text(
                        "Guardar",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () async {
                        getLoadingModal(context, false);
                        if (double.parse(saldo) >=
                            double.parse(_controllers.montoController.text)) {
                          var response = await Connections().withdrawalPost(
                              _controllers.montoController.text);

                          if (response) {
                            Navigator.pop(context);

                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Completado',
                              desc: '',
                              btnCancel: Container(),
                              btnOkText: "Aceptar",
                              btnOkColor: colors.colorGreen,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {
                                Navigators().pushNamedAndRemoveUntil(
                                    context, "/layout/sellers");
                              },
                            ).show();
                          } else {
                            Navigator.pop(context);
                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'Vuelve a intentarlo',
                              btnCancel: Container(),
                              btnOkText: "Aceptar",
                              btnOkColor: colors.colorGreen,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {},
                            ).show();
                          }
                        } else {
                          Navigator.pop(context);
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: 'Error',
                            desc:
                                'No tienes saldo suficiente para realizar esta transaccion',
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                        }
                      },
                    )),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
