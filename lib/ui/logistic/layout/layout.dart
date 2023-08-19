import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/ui/logistic/account_status/account_status.dart';
import 'package:frontend/ui/logistic/add_carrier/add_carrier.dart';
import 'package:frontend/ui/logistic/add_logistics_user/add_logistics_user.dart';
import 'package:frontend/ui/logistic/add_sellers/add_sellers.dart';
import 'package:frontend/ui/logistic/add_stock_to_vendors/add_stock_to_vendors.dart';
import 'package:frontend/ui/logistic/assign_routes/assign_routes.dart';
import 'package:frontend/ui/logistic/dashboard/dashboard.dart';
import 'package:frontend/ui/logistic/delivery_historial/delivery_historial.dart';
import 'package:frontend/ui/logistic/delivery_status/delivery_status.dart';
import 'package:frontend/ui/logistic/guides_sent/guides_sent.dart';
import 'package:frontend/ui/logistic/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/logistic/income_and_expenses/income_and_expenses.dart';
import 'package:frontend/ui/logistic/logistic_balance/logistic_balance.dart';
import 'package:frontend/ui/logistic/logistics_products/logistics_products.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/logistic/print_guides/print_guides.dart';
import 'package:frontend/ui/logistic/printed_guides/printedguides.dart';
import 'package:frontend/ui/logistic/profit_date/profit_date.dart';
import 'package:frontend/ui/logistic/proof_payment/proof_payment.dart';
import 'package:frontend/ui/logistic/remote_support/remote_support.dart';
import 'package:frontend/ui/logistic/return_in_warehouse/controllers/controllers.dart';
import 'package:frontend/ui/logistic/return_in_warehouse/returns_in_warehouse.dart';
import 'package:frontend/ui/logistic/returns/returns.dart';
import 'package:frontend/ui/logistic/shopping/shopping.dart';
import 'package:frontend/ui/logistic/shopping_status/shopping_status.dart';
import 'package:frontend/ui/logistic/stock/stock.dart';
import 'package:frontend/ui/logistic/stock_by_company/stock_by_company.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/transport_delivery_historial.dart';
import 'package:frontend/ui/logistic/transport_invoices/transport_invoices.dart';
import 'package:frontend/ui/logistic/update_password/update_password.dart';
import 'package:frontend/ui/logistic/vendor_invoices/vendor_invoices.dart';
import 'package:frontend/ui/logistic/vendor_withdrawal_request/vendor_withdrawal_request.dart';
import 'package:frontend/ui/logistic/withdrawal_assignment/withdrawal_assignment.dart';
import 'package:frontend/ui/test/test.dart';
import 'package:frontend/ui/welcome/welcome.dart';
import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';
import 'package:provider/provider.dart';

import '../provider_invoices/provider_invoices.dart';
import '../sales_invoices/sales_invoices.dart';
import '../transport_invoices_cxc/cc_transport_invoices.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late NavigationProviderLogistic navigation;
  @override
  void didChangeDependencies() {
    navigation = Provider.of<NavigationProviderLogistic>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      getOption(
        "DashBoard",
        DashBoardLogistic(),
        // TestValues()
      ),
      getOption(
        "Ingresos y Egresos",
        IncomeAndExpenses(),
      ),
      getOption(
        "Agregar Vendedores",
        AddSellers(),
      ),
      getOption(
        "Agregar Transportistas",
        AddCarrier(),
      ),
      getOption(
        "Agregar Usuario Logística",
        AddLogisticsUser(),
      ),
      getOption(
        "Estado de Cuenta",
        AccountStatus(),
      ),
      getOption(
        "Facturas Vendedores",
        VendorInvoices(),
      ),
      getOption(
        "Comprobantes de Pago",
        ProofPayment(),
      ),
      getOption(
        "Saldo Contable",
        ProfitDate(),
      ),
      getOption(
        "Saldo Logística",
        LogisticBalance(),
      ),
      getOption(
        "Solicitud de Retiro Vendedores",
        VendorWithDrawalRequest(),
      ),
      getOption(
        "Estado de Entregas",
        DeliveryStatus(),
      ),
      getOption(
        "Historial Pedidos Transportadora",
        TransportDeliveryHistorial(),
      ),
      getOption(
        "Imprimir Guías",
        PrintGuides(),
      ),

      getOption(
        "Guías Impresas",
        PrintedGuides(),
      ),
      getOption("Guías Enviadas", TableOrdersGuidesSent()
          // GuidesSent(),
          ),
      getOption(
        "Soporte Remoto",
        RemoteSupport(),
      ),
      getOption(
        "Devoluciones",
        Returns(),
      ),
      getOption(
        "Devolución en bodega",
        ReturnsInWarehouse(),
      ),
      getOption(
        "Cambiar Contraseña",
        UpdatePassword(),
      ),
      // AddStockToVendors(),
      // WithdrawalAssignment(),
    ];
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.black),
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
              const SizedBox(
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
        child: getNavbarDrawerLogistic(context),
      ),
      body: SafeArea(child: pages[navigation.index]),
    );
  }

  getOption(name, data) {
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
}
