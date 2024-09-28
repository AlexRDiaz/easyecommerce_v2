import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/operator/navigation_provider.dart';
import 'package:frontend/ui/operator/my_operator_account/my_operator_account.dart';
import 'package:frontend/ui/operator/orders_operator/orders_operator.dart';
import 'package:frontend/ui/operator/orders_scan/order_scan.dart';
import 'package:frontend/ui/operator/received_values.dart/received_values.dart';
import 'package:frontend/ui/operator/resolved_novelties/resolved_novelties.dart';
import 'package:frontend/ui/operator/returns/returns.dart';
import 'package:frontend/ui/operator/state_orders/state_orders.dart';
import 'package:frontend/ui/operator/update_password_operator/update_password_operator.dart';
import 'package:frontend/ui/operator/withdrawals/withdrawals.dart';
import 'package:frontend/ui/provider/transactions/withdrawal.dart';

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
    OrderScan(),
    OrdersOperator(),
    StateOrdersOperator(),
    WithdrawalsOperator(),
    ReceivedValues(),
    ReturnsOperator(),
    ResolvedNovelties(idRolInvokeClass: 4),
    UpdatePasswordOperator(),
    Container(),
  ];
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        //iconTheme: IconThemeData(color: Colors.black),
        leadingWidth: width * 0.55,
        // actions: getActions,

        leading: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                _key.currentState!.openDrawer();
              },
              child: Center(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                  child:
                      Image.asset(images.logoEasyEcommercce, fit: BoxFit.fill),
                ),
              ),
            ),
            Text(
              navigation.nameWindow,
              textAlign: TextAlign.center, // Asegurarse de que esté centrado
              style: TextStylesSystem()
                .ralewayStyle(18, FontWeight.w700, ColorsSystem().colorLabels) ,
              
            )
          ],
        ),
        // title: Container(
        //   width: double.infinity,
        //   height: 80,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       Image.asset(
        //         images.logoEasyEcommercce,
        //         width: 30,
        //       ),
        //       SizedBox(
        //         width: 10,
        //       ),
        //       Flexible(
        //         child: Text(
        //           navigation.nameWindow,
        //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: getNavbarDrawerOperator(context),
      ),
      body: SafeArea(child: pages[navigation.index]),
    );
  }

  List<Widget> get getActions {
    return [
      Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: ColorsSystem().colorStore,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 5), // Espacio entre el ícono y el texto
          Text(
            sharedPrefs!.getString("username").toString(),
            style: 
            TextStylesSystem()
                .ralewayStyle(16, FontWeight.w600, ColorsSystem().colorStore),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(width: 40), // Espacio entre el ícono y el texto
        ],
      ),
    ];
  }
}
