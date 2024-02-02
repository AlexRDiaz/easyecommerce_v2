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
// NotificationManager? notificationManager;
// NotificationManagerOperator? notificationManagerOperator; 

void main() async {
  await initializeDateFormatting('es');
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  setPathUrlStrategy();

  // notificationManager = NotificationManager();
  // notificationManagerOperator = NotificationManagerOperator();

  runApp(MultiProvider(
    providers: [
      // ChangeNotifierProvider(create: (_) => NotificationManager()),
      // ChangeNotifierProvider(create: (_) => NotificationManagerOperator()),
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
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

// class NotificationManager with ChangeNotifier {
//   List<Map<String, dynamic>> _notifications = [];
//   Timer? _timer;

//   List<Map<String, dynamic>> get notifications => _notifications;

//   NotificationManager() {
//     _loadNotifications();
//     _startAutoUpdate();
//   }

//   void _startAutoUpdate() {
//     _timer = Timer.periodic(Duration(minutes: 1), (timer) {
//       _loadNotifications();
//     });
//   }

//    Future<void> updateNotifications() async {
//         await _loadNotifications();
//     }

//   Future<void> _loadNotifications() async {
//     try {
//       var res = await Connections().getCountNotificationsWarehousesWithdrawals();
//       _notifications = res;
//       notifyListeners();
//     } catch (e) {
//       print("Error loading notifications: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }


// class NotificationManagerOperator with ChangeNotifier {
//   List<Map<String, dynamic>> _notifications = [];
//   Timer? _timer;

//   List<Map<String, dynamic>> get notifications => _notifications;

//   NotificationManagerOperator() {
//     _loadNotifications();
//     _startAutoUpdate();
//   }

//   void _startAutoUpdate() {
//     _timer = Timer.periodic(Duration(minutes: 1), (timer) {
//       _loadNotifications();
//     });
//   }

//    Future<void> updateNotifications() async {
//         await _loadNotifications();
//     }

//   Future<void> _loadNotifications() async {
//     try {
//       var res = await Connections().getOrdersCountByWarehouseByOrders();
//       _notifications = res;
//       notifyListeners();
//     } catch (e) {
//       print("Error loading notifications: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }


