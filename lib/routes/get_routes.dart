import 'package:flutter/material.dart';
import 'package:frontend/middlewares/navigation_middlewares.dart';
import 'package:frontend/ui/login/login.dart';
import 'package:frontend/ui/logistic/add_logistics_user/edit_logistic_user.dart';
import 'package:frontend/ui/logistic/add_sellers/edit_sellers.dart';
import 'package:frontend/ui/logistic/delivery_historial/history_by_date.dart';
import 'package:frontend/ui/logistic/delivery_status/delivery_status_info.dart';
import 'package:frontend/ui/logistic/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/logistic/income_and_expenses/income_expense_details.dart';
import 'package:frontend/ui/logistic/layout/layout.dart';
import 'package:frontend/ui/logistic/printed_guides/printedguides_info.dart';
import 'package:frontend/ui/logistic/transport_invoices/invoices_by_date.dart';
import 'package:frontend/ui/logistic/vendor_invoices/invoices_by_vendor.dart';
import 'package:frontend/ui/operator/layout/layout.dart';
import 'package:frontend/ui/operator/orders_operator/info_orders_operator.dart';
import 'package:frontend/ui/operator/received_values.dart/info_received_orders.dart';
import 'package:frontend/ui/operator/state_orders/info_state_orders.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/withdrawal_info.dart';
import 'package:frontend/ui/sellers/delivery_status/info_delivery.dart';
import 'package:frontend/ui/sellers/layout/layout.dart';
import 'package:frontend/ui/sellers/order_entry/order_info.dart';
import 'package:frontend/ui/transport/add_operators_transport/edit_operator_transport.dart';
import 'package:frontend/ui/transport/layout/layout.dart';
import 'package:frontend/ui/transport/my_orders_prv/prv_info.dart';
import 'package:frontend/ui/transport/payment_vouchers_transport/info_payment_voucher.dart';
import 'package:frontend/ui/transport/transportation_billing/info_transportation_billing.dart';
import 'package:get/route_manager.dart';

import '../ui/logistic/account_status/account_status_details.dart';
import '../ui/logistic/add_carrier/carrier_details.dart';
import '../ui/logistic/add_stock_to_vendors/add_stock_details.dart';
import '../ui/logistic/delivery_historial/delivery_details.dart';
import '../ui/logistic/proof_payment/payments_by_transport.dart';
import '../ui/logistic/returns/return_details.dart';
import '../ui/logistic/transport_delivery_historial/transport_delivery_details.dart';
import '../ui/logistic/transport_delivery_historial/transport_history_by_transport.dart';
import '../ui/logistic/transport_invoices/invoice_detail.dart';
import '../ui/logistic/transport_invoices/invoices_by_transport.dart';
import '../ui/logistic/transport_invoices_cxc/cc_invoice_detail.dart';
import '../ui/logistic/transport_invoices_cxc/cc_invoices_by_date.dart';
import '../ui/logistic/transport_invoices_cxc/cc_invoices_by_transport.dart';
import '../ui/logistic/vendor_invoices/invoice_details.dart';
import '../ui/logistic/vendor_invoices/invoices_by_date.dart';
import '../ui/logistic/vendor_withdrawal_request/withdrawal_details.dart';
import '../ui/sellers/add_seller_user/seller_details.dart';
import '../ui/sellers/cash_withdrawals_sellers/withdrawal_details.dart';
import '../ui/sellers/order_history_sellers/order_details.dart';
import '../ui/sellers/returns_seller/return_details.dart';
import '../ui/sellers/sales_report/new_record.dart';
import '../ui/transport/delivery_status_transport/delivery_details.dart';
import '../ui/transport/orders_history_transport/order_details.dart';
import '../ui/transport/payment_vouchers_transport/payments_by_transport.dart';
import '../ui/transport/payment_vouchers_transport/voucher_details.dart';
import '../ui/transport/returns_transport/return_details.dart';

getRoutes() {
  return [
    GetPage(name: '/login', page: () => LoginPage()),
    //LOGISTIC
    /// Start Add stock to vendor
    GetPage(
      name: '/layout/logistic/add-stock-to-vendor/new',
      page: () => const AddStockVendorDetail(
        isNew: true,
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/add-stock-to-vendor/details',
      page: () => const AddStockVendorDetail(
        isNew: false,
      ),
      middlewares: [AuthMiddleware()],
    ),

    /// End Add stock to vendor
    /// Start Add Carrier
    GetPage(
      name: '/layout/logistic/carrier/new',
      page: () => const CarrierDetails(
        isNew: true,
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/carrier/details',
      page: () => const CarrierDetails(
        isNew: false,
      ),
      middlewares: [AuthMiddleware()],
    ),
    // GetPage(
    //   name: '/layout/logistic/print/info',
    //   page: () => const PrintedGuideInfo(),
    //   middlewares: [AuthMiddleware()],
    // ),

    /// End Add Carrier
    /// income - expenses
    GetPage(
      name: '/layout/logistic/income-expense/details',
      page: () => const IncomeExpenseDetailsView(
        isNew: false,
      ),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/income-expense/new',
      page: () => const IncomeExpenseDetailsView(
        isNew: true,
      ),
      middlewares: [AuthMiddleware()],
    ),

    /// start invoices by vendor
    GetPage(
      name: '/layout/logistic/vendor-invoices-by-vendor',
      page: () => const VendorInvoicesByVendor(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/vendor-invoices-by-vendor/by-date',
      page: () => const VendorInvoicesByDate(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/vendor-invoices-by-vendor/by-date/details',
      page: () => const InvoiceByVendorsDetail(),
      middlewares: [AuthMiddleware()],
    ),

    /// end invoices by vendor

    /// start invoices by transport
    GetPage(
      name: '/layout/logistic/transport-invoices-by-date',
      page: () => const TransportInvoicesByDate(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/transport-invoices-by-date/by-transport',
      page: () => const TransportInvoicesByTransport(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/transport-invoices-by-date/by-transport/details',
      page: () => const TransportInvoiceDetail(),
      middlewares: [AuthMiddleware()],
    ),

    /// end invoices by transport

    /// start invoices by transport cc
    GetPage(
      name: '/layout/logistic/cc-transport-invoices-by-date',
      page: () => const CCTransportInvoicesByDate(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/cc-transport-invoices-by-date/by-transport',
      page: () => const CCTransportInvoicesByTransport(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name:
          '/layout/logistic/cc-transport-invoices-by-date/by-transport/details',
      page: () => const CCTransportInvoiceDetail(),
      middlewares: [AuthMiddleware()],
    ),

    /// end invoices by transport cc

    /// start proof payments
    GetPage(
      name: '/layout/logistic/proof-payments-by-transport',
      page: () => const ProofPaymentsByTransport(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/withdrawal/details',
      page: () => const WithdrawalDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// end proof payments

    /// start delivery history
    GetPage(
      name: '/layout/logistic/delivery-history-by-date',
      page: () => const DeliveryHistoryByDate(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/logistic/delivery-history-by-date/details',
      page: () => const DeliveryHistoryDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// end delivery history

    /// start delivery history transport
    GetPage(
      name: '/layout/logistic/transport-delivery-history-by-transport',
      page: () => const TransportDeliveryHistoryByTransport(),
      middlewares: [AuthMiddleware()],
    ),
    // GetPage(
    //   name: '/layout/logistic/transport-delivery-history/details',
    //   page: () => const TransportDeliveryHistoryDetails(),
    //   middlewares: [AuthMiddleware()],
    // ),

    /// end delivery history transport

    /// start returns
    GetPage(
      name: '/layout/logistic/returns/details',
      page: () => const ReturnDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// end returns

    /// start account status
    GetPage(
      name: '/layout/logistic/status-account/details',
      page: () => const AccountStatusDetail(),
      middlewares: [AuthMiddleware()],
    ),

    /// end account status

    GetPage(
        name: '/layout/logistic',
        page: () => LayoutPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/layout/logistic/sellers/info',
        page: () => EditSellers(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/layout/logistic/logistic-user/info',
        page: () => EditLogisticUser(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/layout/logistic/logistic-date/table',
        page: () => TableOrdersGuidesSent(),
        middlewares: [AuthMiddleware()]),
    // GetPage(
    //     name: '/layout/logistic/delivery-status/info',
    //     page: () => DeliveryStatusInfo(),
    //     middlewares: [AuthMiddleware()]),

    //SELLERS
    /// Start Add Sellers
    GetPage(
      name: '/layout/sellers/seller/details',
      page: () => const AddSellerDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// End Add Sellers
    /// Start Add Report
    GetPage(
      name: '/layout/sellers/sales-report/new',
      page: () => const NewSalesReport(),
      middlewares: [AuthMiddleware()],
    ),

    /// End Add Reort
    /// Start order history
    GetPage(
      name: '/layout/sellers/order-history/details',
      page: () => const OrderHistoryDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// End order history

    /// Start sellers returns
    GetPage(
      name: '/layout/sellers/return/details',
      page: () => const SellerReturnDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// End sellers returns

    /// Start sellers returns
    GetPage(
      name: '/layout/sellers/cash-withdrawal/info',
      page: () => const SellerWithdrawalInfo(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/sellers/cash-withdrawal/new',
      page: () => const SellerWithdrawalDetails(),
      middlewares: [AuthMiddleware()],
    ),

    // GetPage(
    //   name: '/layout/sellers/delivery-status/info',
    //   page: () => const DeliveryStatusSellerInfo(),
    //   middlewares: [AuthMiddleware()],
    // ),

    /// End sellers returns
    GetPage(
        name: '/layout/sellers',
        page: () => LayoutSellersPage(),
        middlewares: [AuthMiddleware()]),
    // GetPage(
    //     name: '/layout/sellers/order/info',
    //     page: () => OrderInfo(),
    //     middlewares: [AuthMiddleware()]),

    //TRANSPORT
    GetPage(
        name: '/layout/transport',
        page: () => LayoutTransportPage(),
        middlewares: [AuthMiddleware()]),
    // GetPage(
    //     name: '/layout/transport/prv/info',
    //     page: () => MyOrdersPRVInfo(),
    //     middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/layout/transport/operator/info',
        page: () => EditOperatorTransport(),
        middlewares: [AuthMiddleware()]),

    // GetPage(
    //     name: '/layout/transport/billing/info',
    //     page: () => InfoTransportationBilling(),
    //     middlewares: [AuthMiddleware()]),

    // GetPage(
    //     name: '/layout/transport/vouchers/info',
    //     page: () => InfoPaymentVoucher(),
    //     middlewares: [AuthMiddleware()]),

    /// Start delivery status
    // GetPage(
    //   name: '/layout/transport/delivery-status/details',
    //   page: () => const TransportProDeliveryHistoryDetails(),
    //   middlewares: [AuthMiddleware()],
    // ),

    /// End delivery status
    /// Start order history
    GetPage(
      name: '/layout/transport/order-history/details',
      page: () => const OrderProDeliveryHistoryDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// End delivery status
    /// Start payment vouchers
    GetPage(
      name: '/layout/transport/payment-vouchers/by-transport',
      page: () => const PaymentVoucherByTransport(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/layout/transport/payment-vouchers/by-transport/details',
      page: () => const TransportVoucherDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// End delivery status
    /// Start rturns
    GetPage(
      name: '/layout/transport/returns/details',
      page: () => const TransportReturnDetails(),
      middlewares: [AuthMiddleware()],
    ),

    /// End returns

    //OPERATOR

    GetPage(
        name: '/layout/operator',
        page: () => LayoutOperatorPage(),
        middlewares: [AuthMiddleware()]),
    // GetPage(
    //     name: '/layout/operator/order',
    //     page: () => InfoOrdersOperator(),
    //     middlewares: [AuthMiddleware()]),
    // GetPage(
    //     name: '/layout/operator/state/order',
    //     page: () => InfoStateOrdersOperator(),
    //     middlewares: [AuthMiddleware()]),
    // GetPage(
    //     name: '/layout/operator/received/order',
    //     page: () => InfoReceivedValuesOperator(),
    //     middlewares: [AuthMiddleware()]),
  ];
}
