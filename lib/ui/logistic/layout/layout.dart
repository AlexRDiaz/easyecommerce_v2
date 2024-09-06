import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/login/login.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:frontend/config/exports.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/ui/logistic/account_status/account_status.dart';
import 'package:frontend/ui/logistic/account_status2/account_status2.dart';
import 'package:frontend/ui/logistic/add_carrier/add_carrier.dart';
import 'package:frontend/ui/logistic/add_carrier_laravel/add_carrier_laravel.dart';
import 'package:frontend/ui/logistic/add_logistic_user_laravel/add_logistic_user_laravel.dart';
import 'package:frontend/ui/logistic/add_logistics_user/add_logistics_user.dart';
import 'package:frontend/ui/logistic/add_operators_transport/add_operators_transport.dart';
import 'package:frontend/ui/logistic/add_provider/providers_view.dart';
import 'package:frontend/ui/logistic/add_sellers/add_sellers.dart';
import 'package:frontend/ui/logistic/add_sellers_laravel/add_seller_laravel.dart';
import 'package:frontend/ui/logistic/add_stock_to_vendors/add_stock_to_vendors.dart';
import 'package:frontend/ui/logistic/assign_routes/assign_routes.dart';
import 'package:frontend/ui/logistic/audit/audit_data.dart';
import 'package:frontend/ui/logistic/carriers_external/carriers_external_views.dart';
import 'package:frontend/ui/logistic/dashboard/dashboard.dart';
import 'package:frontend/ui/logistic/delivery_historial/delivery_historial.dart';
import 'package:frontend/ui/logistic/delivery_status/delivery_status.dart';
import 'package:frontend/ui/logistic/delivery_status_carrier_external/delivery_status.dart';
import 'package:frontend/ui/logistic/external_carrier_billing/proof_payment_new.dart';
import 'package:frontend/ui/logistic/guides_sent/guides_sent.dart';
import 'package:frontend/ui/logistic/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/logistic/income_and_expenses/income_and_expenses.dart';
import 'package:frontend/ui/logistic/logistic_balance/logistic_balance.dart';
import 'package:frontend/ui/logistic/logistics_products/logistics_products.dart';
import 'package:frontend/ui/logistic/novelties/novelties.dart';
import 'package:frontend/ui/logistic/print_guides/model_guide/model_guide.dart';
import 'package:frontend/ui/logistic/print_guides/print_guides.dart';
import 'package:frontend/ui/logistic/print_guides_laravel/print_guides_laravel.dart';
import 'package:frontend/ui/logistic/printed_guides/printedguides.dart';
import 'package:frontend/ui/logistic/profit_date/profit_date.dart';
import 'package:frontend/ui/logistic/proof_payment/proof_payment.dart';
import 'package:frontend/ui/logistic/proof_payment/proof_payment_new.dart';
import 'package:frontend/ui/logistic/remote_support/remote_support.dart';
import 'package:frontend/ui/logistic/return_in_warehouse/controllers/controllers.dart';
import 'package:frontend/ui/logistic/return_in_warehouse/returns_in_warehouse.dart';
import 'package:frontend/ui/logistic/returns/returns.dart';
import 'package:frontend/ui/logistic/role_configuration/role_configuration.dart';
import 'package:frontend/ui/logistic/shopping/shopping.dart';
import 'package:frontend/ui/logistic/shopping_status/shopping_status.dart';
import 'package:frontend/ui/logistic/stock/stock.dart';
import 'package:frontend/ui/logistic/stock_by_company/stock_by_company.dart';
import 'package:frontend/ui/logistic/transactions/transactions.dart';
import 'package:frontend/ui/logistic/transactions_global/transactions.dart';
import 'package:frontend/ui/logistic/transactions_providers/transactions_providers.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/transport_delivery_historial.dart';
import 'package:frontend/ui/logistic/transport_invoices/transport_invoices.dart';
import 'package:frontend/ui/logistic/update_password/update_password.dart';
import 'package:frontend/ui/logistic/vendor_invoices/vendor_invoices.dart';
import 'package:frontend/ui/logistic/vendor_withdrawal_request/vendor_withdrawal_request.dart';
import 'package:frontend/ui/logistic/vendor_withdrawal_request_laravel/vendor_withdrawal_request_laravel.dart';
import 'package:frontend/ui/logistic/withdrawal_assignment/withdrawal_assignment.dart';
import 'package:frontend/ui/test/test.dart';
import 'package:frontend/ui/welcome/welcome.dart';
import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  late NavigationProviderLogistic _navigationProvider;

  @override
  void didChangeDependencies() {
    _navigationProvider = Provider.of<NavigationProviderLogistic>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildOption("DashBoard", DashBoardLogistic()),
      _buildOption("Ingresos y Egresos", IncomeAndExpenses()),
      _buildOption("Agregar Vendedores", AddSellers()),
      _buildOption("Agregar Transportistas", AddCarrier()),
      _buildOption("Agregar Usuario Logística", AddLogisticsUserLaravel()),
      _buildOption("Proveedores", ProviderView()),
      _buildOption("Estado de Cuenta", AccountStatus()),
      _buildOption("Estado de Cuenta2", AccountStatus2()),
      _buildOption("Facturas Vendedores", VendorInvoices()),
      _buildOption("Comprobantes de Pago", ProofPayment()),
      _buildOption("Comprobantes de Pago2", ProofPayment2()),
      _buildOption(
          "Facturacion Transportadora Externa", ExternalCarrierBilling()),
      _buildOption("Estados de entrega transportadora externa",
          DeliveryStatusExternalCarrier()),
      _buildOption("Saldo Contable", ProfitDate()),
      _buildOption("Saldo Logística", LogisticBalance()),
      _buildOption(
          "Solicitud de Retiro Vendedores", VendorWithDrawalRequestLaravel()),
      _buildOption("Estado de Entregas", DeliveryStatus()),
      _buildOption(
          "Historial Pedidos Transportadora", TransportDeliveryHistorial()),
      _buildOption("Imprimir Guías", PrintGuidesLaravel()),
      _buildOption("Guías Impresas", PrintedGuides()),
      _buildOption("Guías Enviadas", TableOrdersGuidesSent()),
      _buildOption("Soporte Remoto", RemoteSupport()),
      _buildOption("Auditoria", Audit()),
      _buildOption("Devoluciones", Returns()),
      _buildOption("Transacciones", Transactions()),

      _buildOption("Transacciones Global", TransactionsGlobal()),
      _buildOption("Devolución en bodega", ReturnsInWarehouse()),
      _buildOption("Cambiar Contraseña", UpdatePassword()),
      _buildOption("Configuración de Roles", RoleConfiguration()),
      _buildOption("Novedades", NoveltiesL()),
      _buildOption(
          "Configuración General Transporte", AddOperatorsTransportLogistic()),
      _buildOption("Transportistas Externos", CarriersExternalView()),
      _buildOption("Saldo Proveedores", TransactionsProviders()),
      // _buildOption("Cerrar Sesión", Container() ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: ImageIcon(AssetImage(images.menuIcon), size: 35),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(images.logoEasyEcommercce, width: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _navigationProvider.nameWindow,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: getNavbarDrawerLogistic(context),
      ),
      body: SafeArea(child: pages[_navigationProvider.index]),
    );
  }

  Widget _buildOption(String name, Widget page) {
    final permissions = sharedPrefs?.getStringList("PERMISOS") ?? [];
    // ignore: unrelated_type_equality_checks
    if (permissions[0].contains(name) != "Cerrar Sesión") {
      return page;
    }

    return const Center(
        child: Text('No tiene permisos para acceder a esta página.'));
  }

  // Widget _logout() {
  //   return Center(
  //     child: ElevatedButton(
  //       onPressed: () {
  //         logout();
  //       },
  //       child: const Text("Cerrar sesión"),
  //     ),
  //   );
}


// void logout() {
//   sharedPrefs?.remove("jwt");
//   print("----------------------f-----");
//   print(sharedPrefs!.getString("jwt"));
//   // Asegúrate de que la redirección se realiza correctamente
//   Future.delayed(Duration(milliseconds: 100), () {
//     print("redireccion");
//     Get.offAllNamed('/login');
//   });

// }
