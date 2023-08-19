import 'package:flutter/material.dart';

import 'package:frontend/config/exports.dart';
import 'package:frontend/providers/operator/navigation_provider.dart';
import 'package:frontend/ui/operator/my_operator_account/my_operator_account.dart';
import 'package:frontend/ui/operator/orders_operator/orders_operator.dart';
import 'package:frontend/ui/operator/received_values.dart/received_values.dart';
import 'package:frontend/ui/operator/returns/returns.dart';
import 'package:frontend/ui/operator/state_orders/state_orders.dart';
import 'package:frontend/ui/operator/update_password_operator/update_password_operator.dart';

import 'package:frontend/ui/welcome/welcome.dart';
import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';
import 'package:provider/provider.dart';

class LayoutOperatorPage extends StatefulWidget {
  const LayoutOperatorPage({super.key});

  @override
  State<LayoutOperatorPage> createState() => _LayoutOperatorPageState();
}

class _LayoutOperatorPageState extends State<LayoutOperatorPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late NavigationProviderOperator navigation;
  @override
  void didChangeDependencies() {
    navigation = Provider.of<NavigationProviderOperator>(context);
    super.didChangeDependencies();
  }

  List pages = [
    WelcomeScreen(),
    MyOperatorAccount(),
    OrdersOperator(),
    StateOrdersOperator(),
    ReceivedValues(),
    ReturnsOperator(),
    UpdatePasswordOperator(),
    Container(),
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
        child: getNavbarDrawerOperator(context),
      ),
      body: SafeArea(child: pages[navigation.index]),
    );
  }
}
