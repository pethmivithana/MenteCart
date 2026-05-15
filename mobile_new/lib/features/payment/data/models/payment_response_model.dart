import 'package:equatable/equatable.dart';
import '../../../bookings/data/models/booking_model.dart';

class PaymentDetailsModel extends Equatable {
  final String merchantId;
  final String orderId;
  final String items;
  final String amount;
  final String currency;
  final String returnUrl;
  final String cancelUrl;
  final String notifyUrl;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String merchantKey;

  const PaymentDetailsModel({
    required this.merchantId,
    required this.orderId,
    required this.items,
    required this.amount,
    required this.currency,
    required this.returnUrl,
    required this.cancelUrl,
    required this.notifyUrl,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.merchantKey,
  });

  /// Backend PayHerePaymentResponse fields:
  /// merchant_id, return_web, cancel_url, notify_url, order_id,
  /// items, amount, currency, first_name, last_name, email, phone,
  /// address, city, country, merchant_key
  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsModel(
      merchantId: json['merchant_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      items: json['items'] as String? ?? 'Service Booking',
      amount: json['amount'] as String? ?? '0',
      currency: json['currency'] as String? ?? 'LKR',
      returnUrl: json['return_web'] as String? ?? json['return_url'] as String? ?? '',
      cancelUrl: json['cancel_url'] as String? ?? '',
      notifyUrl: json['notify_url'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? 'N/A',
      city: json['city'] as String? ?? 'N/A',
      country: json['country'] as String? ?? 'Sri Lanka',
      merchantKey: json['merchant_key'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'merchant_id': merchantId,
    'order_id': orderId,
    'items': items,
    'amount': amount,
    'currency': currency,
    'return_web': returnUrl,
    'cancel_url': cancelUrl,
    'notify_url': notifyUrl,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'country': country,
    'merchant_key': merchantKey,
  };

  @override
  List<Object?> get props => [
    merchantId, orderId, items, amount, currency,
    returnUrl, cancelUrl, notifyUrl, firstName, lastName,
    email, phone, address, city, country, merchantKey,
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