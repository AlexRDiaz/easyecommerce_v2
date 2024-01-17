import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/middlewares/navigation_middlewares.dart';
import 'package:frontend/models/pedido_shopify_model.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/providers/operator/navigation_provider.dart';
import 'package:frontend/providers/provider/navigation_provider.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/providers/transport/navigation_provider.dart';
import 'package:frontend/routes/get_routes.dart';
import 'package:frontend/theme/theme.dart';
import 'package:frontend/ui/login/login.dart';
import 'package:frontend/ui/logistic/add_sellers/edit_sellers.dart';
import 'package:frontend/ui/logistic/layout/layout.dart';
import 'package:frontend/ui/operator/orders_operator/controllers/controllers.dart';
import 'package:frontend/ui/sellers/layout/layout.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/transport/layout/layout.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:frontend/connections/connections.dart';

SharedPreferences? sharedPrefs;
NotificationManager? notificationManager;
void main() async {
  await initializeDateFormatting('es');
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  setPathUrlStrategy();

  notificationManager = NotificationManager();

  runApp(MultiProvider(
    providers: [
      Provider<NotificationManager>.value(value: notificationManager!),
      ListenableProvider<NavigationProviderLogistic>(
        create: (_) => NavigationProviderLogistic(),
      ),
      ListenableProvider<NavigationProviderSellers>(
        create: (_) => NavigationProviderSellers(),
      ),
      ListenableProvider<NavigationProviderTransport>(
        create: (_) => NavigationProviderTransport(),
      ),
      ListenableProvider<NavigationProviderOperator>(
        create: (_) => NavigationProviderOperator(),
      ),
      ListenableProvider<NavigationProviderProvider>(
        create: (_) => NavigationProviderProvider(),
      ),
      ListenableProvider<OrderEntryControllers>(
        create: (_) => OrderEntryControllers(),
      ),
      ListenableProvider<FiltersOrdersProviders>(
        create: (_) => FiltersOrdersProviders(),
      ),
      ListenableProvider<OrderInfoOperatorControllers>(
        create: (_) => OrderInfoOperatorControllers(),
      ),
    ],
    child: GetMaterialApp(
      title: 'Easy Ecommerce',
      debugShowCheckedModeBanner: false,
      theme: getThemeApp(),
      scrollBehavior: MyCustomScrollBehavior(),

      // unknownRoute: GetPage(name: '/notfound', page: () => UnknownRoutePage()),
      initialRoute: '/login',
      getPages: getRoutes(),
      unknownRoute: GetPage(
          name: '/notfound',
          page: () => Scaffold(
                body: Center(
                  child: Text('Ruta no encontrada: ${Get.currentRoute}'),
                ),
              )),
    ),
  ));
  // Dispose of NotificationManager when the app is closed

  // // Llamado antes de que la aplicación se cierre
  // WidgetsBinding.instance?.addPostFrameCallback((_) {
  //   notificationManager.dispose();
  // });
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

// class NotificationManager {
//   StreamController<List<Map<String, dynamic>>>  _notificationsController =
//       StreamController<List<Map<String, dynamic>>>();

//   Stream<List<Map<String, dynamic>>> get notificationsStream =>
//       _notificationsController.stream;

//   NotificationManager(
//       [StreamController<List<Map<String, dynamic>>>? controller]) {
//     if (controller != null) {
//       _notificationsController.addStream(controller.stream);
//     } else {
//       _loadNotifications(); // Carga inicial de notificaciones
//       Timer.periodic(const Duration(minutes: 1), (Timer t) {
//         _loadNotifications(); // Actualización periódica
//       });
//     }
//   }

  class NotificationManager {
  // Usa StreamController.broadcast para permitir múltiples suscriptores
  StreamController<List<Map<String, dynamic>>> _notificationsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get notificationsStream =>
      _notificationsController.stream;

  NotificationManager(
      [StreamController<List<Map<String, dynamic>>>? controller]) {
    if (controller != null) {
      _notificationsController.addStream(controller.stream);
    } else {
      _loadNotifications(); // Carga inicial de notificaciones
      Timer.periodic(const Duration(minutes: 1), (Timer t) {
        _loadNotifications(); // Actualización periódica
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      var res = await Connections()
          .getCountNotificationsWarehousesWithdrawals(_notificationsController);
      // print("akmain> $res");
    } catch (e) {
      print("Error loading notifications: $e");
    }
  }

  void dispose() {
    _notificationsController.close();
  }
}
