import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/providers/pin_input.dart';

class Withdrawal extends StatefulWidget {
  const Withdrawal({super.key});

  @override
  State<Withdrawal> createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {
  List<Map> listToRollback = [];
  TextEditingController withdrawal = TextEditingController();

  String responseWithdrawal = "";
  String code = "";

  bool enableBoxTransaction = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const Text("Ingrese el monto a retirar"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextField(
                controller: withdrawal,
                decoration: InputDecoration(
                  fillColor: Colors.white, // Color del fondo del TextFormField
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // onChanged: (value) {
                //   idRollbackTransaction.text = value;
                // },
              ),
            ),
            ElevatedButton(onPressed: sendWithdrawal, child: Text("Solicitar"))
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // listToRollback.isNotEmpty
            //     ?
            Visibility(
              visible: enableBoxTransaction,
              child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width / 2,
                  child: ListView.builder(
                    itemCount: listToRollback.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey), // Borde
                            borderRadius:
                                BorderRadius.circular(10), // Bordes redondeados
                          ),
                          child: Row(
                            children: [
                              Text(listToRollback[index]["tipo"].toString()),
                              SizedBox(
                                width: 10,
                              ),
                              Text(listToRollback[index]["monto"].toString()),
                              SizedBox(
                                width: 10,
                              ),
                              Text(listToRollback[index]["comentario"]
                                  .toString()),
                              SizedBox(
                                width: 10,
                              ),
                              Text(listToRollback[index]["codigo"].toString()),
                            ],
                          ),
                        ),
                        onTap: () {
                          // Acción al tocar el elemento
                        },
                      );
                    },
                  )),
            ),
            Visibility(
                visible: !enableBoxTransaction,
                child: Center(child: Text(responseWithdrawal))),
            listToRollback.isNotEmpty
                ? TextButton(
                    onPressed: () => sendWithdrawal(), child: Text("Restaurar"))
                : Container()
          ],
        )
      ]),
    );
  }

  void sendWithdrawal() async {
    var resultSendWithdrawal =
        await Connections().sendWithdrawal(withdrawal.text);
    if (resultSendWithdrawal != 1 || resultSendWithdrawal != 2) {
      setState(() {
        code = resultSendWithdrawal['code'].toString();
      });
      codeInputDialog(context);
    } else {
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
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
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
                  Expanded(child: PinInput(code: code, amount: withdrawal.text))
                ],
              ),
            ),
          );
        });
  }
}
