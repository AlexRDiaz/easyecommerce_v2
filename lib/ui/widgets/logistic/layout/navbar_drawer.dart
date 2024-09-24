import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/providers/operator/navigation_provider.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/providers/transport/navigation_provider.dart';
import 'package:frontend/ui/widgets/logistic/data/data.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

getNavbarDrawerLogistic(context) {
  return Material(
    elevation: 5,
    child: Container(
      color: Colors.white,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Container(
              //     margin: EdgeInsets.all(5),
              //     child: Image.asset(
              //       images.logoEasyEcommercce,
              //     )),
              // Divider(),
              ...List.generate(
                  optionsLogistic.length,
                  (index) => getOptionL(
                      optionsLogistic[index]['name'],
                      Column(
                        children: [
                          ListTile(
                            onTap: () {
                              if (index == optionsLogistic.length - 1) {
                                Navigators()
                                    .pushNamedAndRemoveUntil(context, "/login");
                              } else {
                                Provider.of<NavigationProviderLogistic>(context,
                                        listen: false)
                                    .changeIndex(
                                        index, optionsLogistic[index]['name']);
                                Navigator.pop(context);
                              }
                            },
                            leading: Icon(
                              optionsLogistic[index]['icon'],
                              color: Provider.of<NavigationProviderLogistic>(
                                        context,
                                      ).index ==
                                      index
                                  ? colors.colorSelectMenu
                                  : Colors.black,
                            ),
                            title: Text(optionsLogistic[index]['name'],
                                style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 14,
                                    color:
                                        Provider.of<NavigationProviderLogistic>(
                                                  context,
                                                ).index ==
                                                index
                                            ? ColorsSystem().colorSelected
                                            : ColorsSystem().colorLabels,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Divider()
                        ],
                      )))
            ],
          ),
        ),
      ),
    ),
  );
}

getOptionL(name, data) {
  switch (name) {
    // case "Soporte Remoto":
    // return data;
    case "Cambiar Contraseña":
      return data;
    case "Cerrar Sesión":
      return _logout();
    default:
      if (sharedPrefs!.getStringList("PERMISOS")!.isNotEmpty) {
        if (sharedPrefs!.getStringList("PERMISOS")![0].contains(name)) {
          return data;
        } else {
          return Container();
        }
      } else {
        return Container();
      }
  }
}

Widget _logout() {
  return Center(
    child: ElevatedButton(
      style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.red)),
      onPressed: () {
        logout();
      },
      child: const Text("Cerrar sesión"),
    ),
  );
}

void logout() {
  sharedPrefs?.remove("jwt");
  print("----------------------xxx-----");
  print(sharedPrefs!.getString("jwt"));
  // Redirige al usuario a la página de inicio de sesión
  Get.offAllNamed('/login');
}

getNavbarDrawerSellers(context) {
  return Material(
    elevation: 5,
    child: Container(
      color: Colors.white,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.all(5),
                  child: Image.asset(
                    images.logoEasyEcommercce,
                  )),
              Divider(),
              ...List.generate(
                  optionsSellers.length,
                  (index) => getOption(
                      optionsSellers[index]['name'],
                      Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Provider.of<NavigationProviderSellers>(context,
                                      listen: false)
                                  .changeIndex(
                                      index, optionsSellers[index]['name']);
                              Navigator.pop(context);
                              //}
                            },
                            leading: Icon(
                              optionsSellers[index]['icon'],
                              color: Provider.of<NavigationProviderSellers>(
                                        context,
                                      ).index ==
                                      index
                                  ? colors.colorSelectMenu
                                  : Colors.black,
                            ),
                            title: Text(
                              optionsSellers[index]['name'],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Provider.of<NavigationProviderSellers>(
                                            context,
                                          ).index ==
                                          index
                                      ? colors.colorSelectMenu
                                      : Colors.black),
                            ),
                          ),
                          Divider()
                        ],
                      )))
            ],
          ),
        ),
      ),
    ),
  );
}

getNavbarDrawerProviders(context) {
  return Material(
    elevation: 5,
    child: Container(
      color: Colors.white,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.all(5),
                  child: Image.asset(
                    images.logoEasyEcommercce,
                  )),
              Divider(),
              ...List.generate(
                  optionsProvider.length,
                  (index) => getOption(
                      optionsProvider[index]['name'],
                      Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Provider.of<NavigationProviderSellers>(context,
                                      listen: false)
                                  .changeIndex(
                                      index, optionsProvider[index]['name']);
                              Navigator.pop(context);
                            },
                            leading: Icon(
                              optionsProvider[index]['icon'],
                              color: Provider.of<NavigationProviderSellers>(
                                        context,
                                      ).index ==
                                      index
                                  ? colors.colorSelectMenu
                                  : Colors.black,
                            ),
                            title: Text(
                              optionsProvider[index]['name'],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Provider.of<NavigationProviderSellers>(
                                            context,
                                          ).index ==
                                          index
                                      ? colors.colorSelectMenu
                                      : Colors.black),
                            ),
                          ),
                          Divider()
                        ],
                      )))
            ],
          ),
        ),
      ),
    ),
  );
}

getOption(name, data) {
  switch (name) {
    // case "Mi Cuenta Vendedor":
    // return data;
    // case "Cambiar Contraseña":
    // return data;
    case "Cerrar Sesión":
      return _logout();
    default:
      if (sharedPrefs!.getStringList("PERMISOS")!.isNotEmpty) {
        if (sharedPrefs!.getStringList("PERMISOS")![0].contains(name)) {
          return data;
        } else {
          return Container();
        }
      } else {
        return Container();
      }
  }
}

// ! falta el getoption para  transport

getNavbarDrawerTransport(context) {
  return Material(
    elevation: 5,
    child: Container(
      color: Colors.white,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Container(
              //     margin: EdgeInsets.all(5),
              //     child: Image.asset(
              //       images.logoEasyEcommercce,
              //     )),
              // Divider(),
              ...List.generate(
                  optionsTransport.length,
                  (index) => getOption(
                      optionsTransport[index]['name'],
                      Column(
                        children: [
                          ListTile(
                            onTap: () {
                              if (index == optionsTransport.length - 1) {
                                Navigators()
                                    .pushNamedAndRemoveUntil(context, "/login");
                              } else {
                                Provider.of<NavigationProviderTransport>(
                                        context,
                                        listen: false)
                                    .changeIndex(
                                        index, optionsTransport[index]['name']);
                                Navigator.pop(context);
                              }
                            },
                            leading: Icon(
                              optionsTransport[index]['icon'],
                              color: Provider.of<NavigationProviderTransport>(
                                        context,
                                      ).index ==
                                      index
                                  ? colors.colorSelectMenu
                                  : Colors.black,
                            ),
                            title: Text(optionsLogistic[index]['name'],
                                style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 14,
                                    color: Provider.of<
                                                NavigationProviderTransport>(
                                              context,
                                            ).index ==
                                            index
                                        ? ColorsSystem().colorSelected
                                        : ColorsSystem().colorLabels,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Divider()
                        ],
                      )))
            ],
          ),
        ),
      ),
    ),
  );
}

getOptionO(name, data) {
  switch (name) {
    // case "Estado de Entregas":
    //   return data;
    // case "Actualizar Contraseña":
    // return data;
    case "Cerrar Sesión":
      return _logout();
    default:
      if (sharedPrefs!.getStringList("PERMISOS")!.isNotEmpty) {
        if (sharedPrefs!.getStringList("PERMISOS")![0].contains(name)) {
          return data;
        } else {
          return Container();
        }
      } else {
        return Container();
      }
  }
}

getNavbarDrawerOperator(context) {
  return Material(
    elevation: 5,
    child: Container(
      color: Colors.white,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Container(
              //     margin: EdgeInsets.all(5),
              //     child: Image.asset(
              //       images.logoEasyEcommercce,
              //     )),
              // Divider(),
              ...List.generate(
                  optionsOperator.length,
                  (index) => getOptionO(
                      optionsOperator[index]['name'],
                      Column(
                        children: [
                          ListTile(
                            onTap: () {
                              if (index == optionsOperator.length - 1) {
                                Navigators()
                                    .pushNamedAndRemoveUntil(context, "/login");
                              } else {
                                Provider.of<NavigationProviderOperator>(context,
                                        listen: false)
                                    .changeIndex(
                                        index, optionsOperator[index]['name']);
                                Navigator.pop(context);
                              }
                            },
                            leading: Icon(
                              optionsOperator[index]['icon'],
                              color: Provider.of<NavigationProviderOperator>(
                                        context,
                                      ).index ==
                                      index
                                  ? colors.colorSelectMenu
                                  : Colors.black,
                            ),
                            title: Text(
                              optionsOperator[index]['name'],
                              style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 14,
                                  color:
                                      Provider.of<NavigationProviderOperator>(
                                                context,
                                              ).index ==
                                              index
                                          ? ColorsSystem().colorSelected
                                          : ColorsSystem().colorLabels,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Divider()
                        ],
                      )))
            ],
          ),
        ),
      ),
    ),
  );
}
