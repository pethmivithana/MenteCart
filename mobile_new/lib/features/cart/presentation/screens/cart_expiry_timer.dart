import 'package:flutter/material.dart';

class CartExpiryTimer extends StatelessWidget {
  final Duration? timeRemaining;
  final VoidCallback? onExpired;

  const CartExpiryTimer({Key? key, this.timeRemaining, this.onExpired})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timeRemaining == null) {
      return const SizedBox.shrink();
    }

    final isExpiringSoon = timeRemaining!.inMinutes < 2;
    final minutes = timeRemaining!.inMinutes;
    final seconds = timeRemaining!.inSeconds.remainder(60);
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isExpiringSoon
            ? Colors.red.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        border: Border.all(
          color: isExpiringSoon ? Colors.red : Colors.orange,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: isExpiringSoon ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            'Cart expires in $timeStr',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isExpiringSoon ? Colors.red : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
