import 'package:flutter/material.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/providers/operator/navigation_provider.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/providers/transport/navigation_provider.dart';
import 'package:frontend/ui/widgets/logistic/data/data.dart';
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
              Container(
                width: double.infinity,
                height: 80,
                child: Row(
                  children: [
                    Image.asset(
                      images.logoEasyEcommercce,
                      width: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "EASY ECOMMER",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Divider(),
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
                            title: Text(
                              optionsLogistic[index]['name'],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Provider.of<NavigationProviderLogistic>(
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

getOptionL(name, data) {
  switch (name) {
    case "Soporte Remoto":
      return data;
    case "Cambiar Contraseña":
      return data;
    case "Cerrar Sesión":
      return data;
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
                width: double.infinity,
                height: 80,
                child: Row(
                  children: [
                    Image.asset(
                      images.logoEasyEcommercce,
                      width: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "EASY ECOMMER",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Divider(),
              ...List.generate(
                  optionsSellers.length,
                  (index) => getOption(
                      optionsSellers[index]['name'],
                      Column(
                        children: [
                          ListTile(
                            onTap: () {
                              if (index == optionsSellers.length - 1) {
                                Navigators()
                                    .pushNamedAndRemoveUntil(context, "/login");
                              } else {
                                Provider.of<NavigationProviderSellers>(context,
                                        listen: false)
                                    .changeIndex(
                                        index, optionsSellers[index]['name']);
                                Navigator.pop(context);
                              }
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

getOption(name, data) {
  switch (name) {
    case "Mi Cuenta Vendedor":
      return data;
    case "Cambiar Contraseña":
      return data;
    case "Cerrar Sesión":
      return data;
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
              Container(
                width: double.infinity,
                height: 80,
                child: Row(
                  children: [
                    Image.asset(
                      images.logoEasyEcommercce,
                      width: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "EASY ECOMMER",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Divider(),
              ...List.generate(
                  optionsTransport.length,
                  (index) => Column(
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
                            title: Text(
                              optionsTransport[index]['name'],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Provider.of<NavigationProviderTransport>(
                                                context,
                                              ).index ==
                                              index
                                          ? colors.colorSelectMenu
                                          : Colors.black),
                            ),
                          ),
                          Divider()
                        ],
                      ))
            ],
          ),
        ),
      ),
    ),
  );
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
              Container(
                width: double.infinity,
                height: 80,
                child: Row(
                  children: [
                    Image.asset(
                      images.logoEasyEcommercce,
                      width: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "EASY ECOMMER",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Divider(),
              ...List.generate(
                  optionsOperator.length,
                  (index) => Column(
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Provider.of<NavigationProviderOperator>(
                                                context,
                                              ).index ==
                                              index
                                          ? colors.colorSelectMenu
                                          : Colors.black),
                            ),
                          ),
                          Divider()
                        ],
                      ))
            ],
          ),
        ),
      ),
    ),
  );
}
