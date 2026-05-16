import 'package:flutter/material.dart';
import '../../domain/entities/service.dart';

class SlotCard extends StatelessWidget {
  final ServiceSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const SlotCard({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFullyBooked = slot.isFullyBooked;
    final hasLimited = slot.hasLimitedSlots;

    Color getBgColor() {
      if (isSelected) {
        return const Color(0xFF6C63FF);
      }
      if (isFullyBooked) {
        return isDark ? Colors.grey[800]! : Colors.grey[300]!;
      }
      return isDark ? Colors.grey[800]! : Colors.grey[100]!;
    }

    Color getTextColor() {
      if (isSelected || isFullyBooked) {
        return Colors.white;
      }
      return isDark ? Colors.white : Colors.black87;
    }

    return GestureDetector(
      onTap: isFullyBooked ? null : onTap,
      child: Opacity(
        opacity: isFullyBooked ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: getBgColor(),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                : Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(slot.time),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(hasLimited, isFullyBooked),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getAvailabilityText(slot),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(hasLimited, isFullyBooked),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${slot.remaining}/${slot.capacity} spots',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        return time;
      }
    } catch (_) {}
    return time;
  }

  String _getAvailabilityText(ServiceSlot slot) {
    if (slot.isFullyBooked) {
      return 'Fully Booked';
    }
    if (slot.hasLimitedSlots) {
      return 'Limited Slots';
    }
    return 'Available';
  }

  Color _getStatusBgColor(bool hasLimited, bool isFullyBooked) {
    if (isFullyBooked) {
      return Colors.red.withValues(alpha: 0.2);
    }
    if (hasLimited) {
      return Colors.orange.withValues(alpha: 0.2);
    }
    return Colors.green.withValues(alpha: 0.2);
  }

  Color _getStatusTextColor(bool hasLimited, bool isFullyBooked) {
    if (isFullyBooked) {
      return Colors.red;
    }
    if (hasLimited) {
      return Colors.orange;
    }
    return Colors.green;
  }
}