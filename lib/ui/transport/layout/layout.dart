import 'package:flutter/material.dart';

import 'package:frontend/config/exports.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/providers/transport/navigation_provider.dart';
import 'package:frontend/ui/transport/add_operators_transport/add_operators_transport.dart';
import 'package:frontend/ui/transport/create_sub_routes_transport/create_sub_routes_transport.dart';
import 'package:frontend/ui/transport/delivery_status_transport/delivery_status_transport.dart';
import 'package:frontend/ui/transport/my_orders_prv/my_orders_prv.dart';
import 'package:frontend/ui/transport/my_transporter_account/my_transporter_account.dart';
import 'package:frontend/ui/transport/orders_history_transport/orders_history_transport.dart';
import 'package:frontend/ui/transport/payment_vouchers_transport/payment_vouchers_transport.dart';
import 'package:frontend/ui/transport/returns_transport/returns_transport.dart';
import 'package:frontend/ui/transport/transportation_billing/transportation_billing.dart';
import 'package:frontend/ui/transport/update_password_transport/update_password_transport.dart';

import 'package:frontend/ui/welcome/welcome.dart';
import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';
import 'package:provider/provider.dart';

class LayoutTransportPage extends StatefulWidget {
  const LayoutTransportPage({super.key});

  @override
  State<LayoutTransportPage> createState() => _LayoutTransportPageState();
}

class _LayoutTransportPageState extends State<LayoutTransportPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late NavigationProviderTransport navigation;
  @override
  void didChangeDependencies() {
    navigation = Provider.of<NavigationProviderTransport>(context);
    super.didChangeDependencies();
  }

  List pages = [
    WelcomeScreen(),
    MyOrdersPRVTransport(),
    DeliveryStatusTransport(),
    AddOperatorsTransport(),
    MyTransporterAccount(),
    PaymentVouchersTransport(),
    TransportationBilling(),
    ReturnsTransport(),
    UpdatePasswordTransport()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        //iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            _key.currentState!.openDrawer();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageIcon(
                AssetImage(images.menuIcon),
                size: 35,
              ),
            ],
          ),
        ),
        title: Container(
          width: double.infinity,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                images.logoEasyEcommercce,
                width: 30,
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: Text(
                  navigation.nameWindow,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: getNavbarDrawerTransport(context),
      ),
      body: SafeArea(child: pages[navigation.index]),
    );
  }
}
