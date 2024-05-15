import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/provider/profile/payment_information.dart';
import 'package:frontend/ui/provider/profile/payment_information_update.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isLoading = false;
  TextEditingController nameProviderController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController usuarioController = TextEditingController();
  List accounts = [];
  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    var request = await Connections().getAccountData();

    setState(() {
      accounts = request;
    });

    nameProviderController.text =
        sharedPrefs!.getString("NameProvider").toString();
    correoController.text = sharedPrefs!.getString("email").toString();
    usuarioController.text = sharedPrefs!.getString("username").toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.all(22),
        child: isLoading == true
            ? Container()
            : Container(
                color: Colors.grey[200],
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/layout/provider');
                          },
                          icon: Icon(Icons.home), // Icono de Home
                          iconSize: 30, // Tamaño del icono
                        ),
                        InputRow(
                            controller: nameProviderController,
                            title: 'Nombre Comercial'),
                        SizedBox(
                          height: 30,
                        ),
                        //_identifier(),
                        SizedBox(
                          height: 30,
                        ),
                        //  _referenced(),
                        SizedBox(
                          height: 30,
                        ),
                        InputRow(controller: correoController, title: 'Correo'),
                        SizedBox(
                          height: 30,
                        ),
                        InputRow(
                            controller: usuarioController, title: 'Usuario'),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () => paymentInformationDialog(context),
                          child: Text(
                            " Configurar Datos Bancarios",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          width: 500,
                          height: 400,
                          color: Colors.grey,
                          child: ListView.builder(
                            itemCount: accounts.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  title: Text(
                                    '${accounts[index]['names']} ${accounts[index]['last_name']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    accounts[index]['bank_entity'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward),
                                        onPressed: () {
                                          editAccounts(context, index);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          // Lógica para eliminar el elemento de la lista
                                          setState(() {
                                            accounts.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<dynamic> paymentInformationDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(0.0), // Establece el radio del borde a 0
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.8,
            child: PaymentInformation(),
          ),
        );
      },
    ).then((value) {
      // Aquí puedes realizar cualquier acción que necesites después de cerrar el diálogo
      // Por ejemplo, actualizar algún estado
      // setState(() {
      //   //_futureProviderData = _loadProviders(); // Actualiza el Future
      // });
    });
  }

  Future<dynamic> editAccounts(BuildContext context, index) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(0.0), // Establece el radio del borde a 0
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.8,
            child: PaymentInformationUpdate(
                currentAccount: accounts, index: index),
          ),
        );
      },
    ).then((value) {
      // Aquí puedes realizar cualquier acción que necesites después de cerrar el diálogo
      // Por ejemplo, actualizar algún estado
      // setState(() {
      //   //_futureProviderData = _loadProviders(); // Actualiza el Future
      // });
    });
  }
}
