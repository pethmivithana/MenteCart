import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({Key? key, required this.serviceId}) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: Center(
        child: Text('Service ${widget.serviceId} details coming soon'),
      ),
    );
  }
}
