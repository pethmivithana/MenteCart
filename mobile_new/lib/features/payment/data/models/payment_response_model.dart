import 'package:equatable/equatable.dart';
import '../../../bookings/data/models/booking_model.dart';

class PaymentDetailsModel extends Equatable {
  final String merchantId;
  final String orderId;
  final String items;
  final String amount;
  final String currency;
  final String returnUrl;
  final String notifyUrl;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String merchantKey;

  const PaymentDetailsModel({
    required this.merchantId,
    required this.orderId,
    required this.items,
    required this.amount,
    required this.currency,
    required this.returnUrl,
    required this.notifyUrl,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.merchantKey,
  });

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsModel(
      merchantId: json['merchant_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      items: json['items'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      currency: json['currency'] as String? ?? 'LKR',
      returnUrl: json['return_url'] as String? ?? '',
      notifyUrl: json['notify_url'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerEmail: json['customer_email'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      merchantKey: json['merchant_key'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'merchant_id': merchantId,
    'order_id': orderId,
    'items': items,
    'amount': amount,
    'currency': currency,
    'return_url': returnUrl,
    'notify_url': notifyUrl,
    'customer_name': customerName,
    'customer_email': customerEmail,
    'customer_phone': customerPhone,
    'merchant_key': merchantKey,
  };

  @override
  List<Object?> get props => [
    merchantId,
    orderId,
    items,
    amount,
    currency,
    returnUrl,
    notifyUrl,
    customerName,
    customerEmail,
    customerPhone,
    merchantKey,
  ];
}

class PaymentResponseModel extends Equatable {
  final BookingModel booking;
  final PaymentDetailsModel paymentDetails;

  const PaymentResponseModel({
    required this.booking,
    required this.paymentDetails,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentResponseModel(
      booking: BookingModel.fromJson(json['booking'] as Map<String, dynamic>),
      paymentDetails: PaymentDetailsModel.fromJson(
        json['paymentDetails'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'booking': booking,
    'paymentDetails': paymentDetails.toJson(),
  };

  @override
  List<Object?> get props => [booking, paymentDetails];
}
