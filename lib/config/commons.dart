// ignore: unused_import
import 'dart:io';

import 'package:frontend/ui/logistic/delivery_status/delivery_status.dart';
import 'package:frontend/ui/provider/add_provider/sub_providers_view.dart';
import 'package:frontend/ui/provider/guidesgroup/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/provider/guidesgroup/print_guides/print_guides.dart';
import 'package:frontend/ui/provider/guidesgroup/printed_guides/printedguides.dart';
import 'package:frontend/ui/provider/layout/welcome_provider_screen.dart';
import 'package:frontend/ui/provider/products/products_view.dart';
import 'package:frontend/ui/provider/transactions/transactions_view.dart';
import 'package:frontend/ui/provider/warehouses/warehouses.dart';
import 'package:frontend/ui/sellers/add_seller_user/add_seller_user.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/cash_withdrawals_sellers.dart';
import 'package:frontend/ui/sellers/catalog/catalog.dart';
import 'package:frontend/ui/sellers/dashboard/dashboard.dart';
import 'package:frontend/ui/sellers/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/sellers/my_integrations/my_integrations.dart';
import 'package:frontend/ui/sellers/my_wallet/my_wallet.dart';
import 'package:frontend/ui/sellers/order_entry/order_entry.dart';
import 'package:frontend/ui/sellers/print_guides/print_guides.dart';
import 'package:frontend/ui/sellers/printed_guides/printedguides.dart';
import 'package:frontend/ui/sellers/returns_seller/returns_seller.dart';
import 'package:frontend/ui/sellers/sales_report/sales_report.dart';
import 'package:frontend/ui/sellers/transport_stats/transport_stats.dart';
import 'package:frontend/ui/sellers/unwanted_orders_sellers/unwanted_orders_sellers.dart';
import 'package:frontend/ui/sellers/wallet_sellers/wallet_sellers.dart';

List<Map<String, dynamic>> pagesSeller = [
  {"page": "DashBoard", "view": DashBoardSellers(), "selected": false},
  {"page": "Reporte de Ventas", "view": SalesReport(), "selected": false},
  {
    "page": "Agregar Usuarios Vendedores",
    "view": AddSellerUser(),
    "selected": false
  },
  {"page": "Ingreso de Pedidos", "view": OrderEntry(), "selected": false},
  {
    "page": "Estado Entregas Pedidos",
    "view": DeliveryStatus(),
    "selected": false
  },
  {
    "page": "Pedidos No Deseados",
    "view": UnwantedOrdersSellers(),
    "selected": false
  },
  {"page": "Billetera", "view": WalletSellers(), "selected": false},
  {"page": "Mi Billetera", "view": MyWallet(), "selected": false},
  {"page": "Devoluciones", "view": ReturnsSeller(), "selected": false},
  {
    "page": "Retiros en Efectivo",
    "view": CashWithdrawalsSellers(),
    "selected": false
  },
  {
    "page": "Conoce a tu Transporte",
    "view": tansportStats(),
    "selected": false
  },
  {"page": "Catálogo de Productos", "view": Catalog(), "selected": false},
  {"page": "Imprimir Guías", "view": PrintGuidesSeller(), "selected": false},
  {"page": "Guías Impresas", "view": PrintedGuidesSeller(), "selected": false},
  {
    "page": "Guías Enviadas",
    "view": TableOrdersGuidesSentSeller(),
    "selected": false
  },
  {"page": "Mis integraciones", "view": MyIntegrations(), "selected": false},
];

List<Map<String, dynamic>> pagesProvider = [
  {"page": "Home", "view": WelcomeProviderScreen(), "selected": false},
  {"page": "Productos", "view": ProductsView(), "selected": false},
  {"page": "Bodegas", "view": WarehousesView(), "selected": false},
  {"page": "Sub Proveedores", "view": SubProviderView(), "selected": false},
  {
    "page": "Mis Transacciones",
    "view": const TransactionsView(),
    "selected": false
  },
  {
    "page": "Imprimir Guías",
    "view": const PrintGuidesProvider(),
    "selected": false
  },
  {
    "page": "Guías Impresas",
    "view": const PrintedGuidesProvider(),
    "selected": false
  },
  {
    "page": "Guías Enviadas",
    "view": const TableOrdersGuidesSentProvider(),
    "selected": false
  },
];
