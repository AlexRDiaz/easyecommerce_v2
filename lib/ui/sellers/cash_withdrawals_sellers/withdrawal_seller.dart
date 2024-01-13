import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/sellers/pin_input_seller.dart';

class WithdrawalSeller extends StatefulWidget {
  const WithdrawalSeller({super.key});

  @override
  State<WithdrawalSeller> createState() => _WithdrawalSellerState();
}

class _WithdrawalSellerState extends State<WithdrawalSeller> {
  TextEditingController withdrawal = TextEditingController();
  bool isLoading = false;
  String responseWithdrawal = "";
  String code = "";
  int accountId = 0;
  //List accounts = [];
  bool enableBoxTransaction = false;
  List<String> selectedItems = [];
  String _selectedValue =
      ''; // Declara una variable para almacenar el valor seleccionado

  @override
  void initState() {
    // loadData();
    super.initState();
  }

  // loadData() async {
  //   var request = await Connections().getAccountData();

  //   setState(() {
  //     accounts = request;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              child: Text(
                "SOLICITUD DE RETIRO",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: withdrawal,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Ingrese cantidad a retirar',
                            hintText: 'Ingrese aquí',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  //***************activar cuando se configure la cuenta  de banco*************************/
                  // CustomDropdownMenu(
                  //   items: accounts,
                  //   hintText: "Cuenta",
                  //   onValueChanged: (value) {},
                  // ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: solicitarButton(context)),
        ],
      ),
    );
  }

  // List<String> getItems() {
  //   // List<Map<String, dynamic>> accounts = [
  //   //   {'names': 'Alex'},
  //   //   {'names': 'John'},
  //   //   {'names': 'Sarah'},
  //   //   // Otros elementos
  //   // ];
  //   List<String> arrayItems =
  //       accounts.map((account) => account['names'].toString()).toList();
  //   return arrayItems;
  // }

  void sendWithdrawal() async {
    setState(() {
      isLoading = true;
    });
    var resultSendWithdrawal =
        await Connections().sendWithdrawalSeller(withdrawal.text);
    if (resultSendWithdrawal != 1 || resultSendWithdrawal != 2) {
      setState(() {
        code = resultSendWithdrawal['code'].toString();
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
        desc: 'No se pudo solicitar el retiro',
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
                      child:
                          PinInputSeller(code: code, amount: withdrawal.text))
                ],
              ),
            ),
          );
        });
  }

  SizedBox solicitarButton(BuildContext context) {
    return SizedBox(
      // Ancho deseado para el botón
      child: ElevatedButton(
        onPressed: () => sendWithdrawal(),
        style: ElevatedButton.styleFrom(
          primary: const Color.fromRGBO(0, 200, 83, 1),
          onPrimary: Colors.white,
          padding:
              const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? SizedBox(
                    width: 20, // Ancho deseado para el indicador circular
                    height: 20, // Altura deseada para el indicador circular
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth:
                          4, // Ancho de la línea del indicador circular
                      // Color del indicador circular
                    ),
                  )
                : Container(),
            const SizedBox(width: 8),
            Text(
              isLoading ? "Solicitando" : 'Solicitar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
