import 'package:flutter/material.dart';
import '../../domain/entities/booking.dart';

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;
  final PaymentStatus paymentStatus;

  const BookingStatusChip({
    Key? key,
    required this.status,
    required this.paymentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = _getStatusStyle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  (Color bgColor, Color textColor, String label) _getStatusStyle() {
    switch (status) {
      case BookingStatus.pending:
        return (Colors.amber, Colors.amber[900]!, 'Pending');
      case BookingStatus.confirmed:
        return (Colors.blue, Colors.blue[900]!, 'Confirmed');
      case BookingStatus.completed:
        return (Colors.green, Colors.green[900]!, 'Completed');
      case BookingStatus.cancelled:
        return (Colors.red, Colors.red[900]!, 'Cancelled');
      case BookingStatus.failed:
        return (Colors.grey, Colors.grey[800]!, 'Failed');
    }
  }
}

class BookingStatusTimeline extends StatelessWidget {
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const BookingStatusTimeline({
    Key? key,
    required this.status,
    required this.createdAt,
    this.completedAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _buildStatusStep('Pending', true, status == BookingStatus.pending),
          _buildConnector(status != BookingStatus.pending),
          _buildStatusStep(
            'Confirmed',
            status != BookingStatus.pending,
            status == BookingStatus.confirmed,
          ),
          _buildConnector(
            status == BookingStatus.completed ||
                status == BookingStatus.cancelled,
          ),
          _buildStatusStep(
            status == BookingStatus.cancelled ? 'Cancelled' : 'Completed',
            status == BookingStatus.completed ||
                status == BookingStatus.cancelled,
            status == BookingStatus.completed ||
                status == BookingStatus.cancelled,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(String label, bool completed, bool current) {
    Color getColor() {
      if (completed && !current) return Colors.green;
      if (current) return Colors.blue;
      return Colors.grey[400]!;
    }

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: getColor(), shape: BoxShape.circle),
          child: completed && !current
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: current ? FontWeight.bold : FontWeight.normal,
            color: current ? Colors.blue : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Container(
        width: 2,
        height: 20,
        color: active ? Colors.green : Colors.grey[400],
      ),
    );
  }
}
