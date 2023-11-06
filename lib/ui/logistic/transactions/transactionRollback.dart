import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';

class TransactionRollback extends StatefulWidget {
  const TransactionRollback({super.key});

  @override
  State<TransactionRollback> createState() => _TransactionRollbackState();
}

class _TransactionRollbackState extends State<TransactionRollback> {
  List<Map> listToRollback = [];
  TextEditingController idRollbackTransaction = TextEditingController();
  String responseTransactionRollback = "";
  bool enableBoxTransaction = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const Text("Ingrese el identificador de la transacción"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextField(
                controller: idRollbackTransaction,
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
            ElevatedButton(
                onPressed: getlistToRollback, child: Text("Consultar"))
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
                child: Center(child: Text(responseTransactionRollback))),
            listToRollback.isNotEmpty
                ? TextButton(
                    onPressed: () => rollbackTransactions(),
                    child: Text("Restaurar"))
                : Container()
          ],
        )
      ]),
    );
  }

  Future<void> rollbackTransactions() async {
    List<String> listaIds =
        listToRollback.map((elemento) => elemento["id"].toString()).toList();

    AwesomeDialog(
      width: 500,
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: "Advertencia",
      desc: 'Se reestauraran los valores de las transacciones',
      btnCancelText: "Cancelar",
      btnOkText: "Continuar",
      btnOkColor: Colors.green,
      btnCancelOnPress: () {
        Navigator.pop(context);
      },
      btnOkOnPress: () async {
        // Navigator.pop(context);

        var res = await Connections().rollbackTransaction(listaIds);
        if (res == 1 || res == 2) {
          // ignore: use_build_context_synchronously
          AwesomeDialog(
            width: 500,
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: "Ha ocurrido un error al restaurar los valores",
            //  desc: 'Vuelve a intentarlo',
            btnCancel: Container(),
            btnOkText: "Aceptar",
            btnOkColor: Colors.green,

            btnCancelOnPress: () {},
            btnOkOnPress: () {
              Navigator.pop(context);
            },
          ).show();
        } else {
          for (var transaction in listToRollback) {
            Connections().updatenueva(transaction["id_origen"], {
              "status": "PEDIDO PROGRAMADO",
              "estado_devolucion": "PENDIENTE"
            });
          }
          AwesomeDialog(
            width: 500,
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: "Valores restaurados",
            //  desc: 'Vuelve a intentarlo',
            btnCancel: Container(),
            btnOkText: "Aceptar",
            btnOkColor: Colors.green,

            btnCancelOnPress: () {},
            btnOkOnPress: () {
              Navigator.pop(context);
            },
          ).show();
        }
      },
    ).show();
  }

  void getlistToRollback() async {
    listToRollback = [];
    var listRollback =
        await Connections().getListToRollback(idRollbackTransaction.text);
    if (listRollback != 1 || listToRollback != 2) {
      setState(() {
        for (var element in listRollback) {
          listToRollback.add(element);
        }
        if (listToRollback.isEmpty) {
          setState(() {
            responseTransactionRollback =
                "No existe ninguna transaccion valida para este id";
            enableBoxTransaction = false;
          });
        } else {
          setState(() {
            enableBoxTransaction = true;
          });
        }
      });
    }
  }
}
