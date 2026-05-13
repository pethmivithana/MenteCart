/// App-wide constants: storage keys, route names, pagination defaults.
class AppConstants {
  AppConstants._();

  // ─── Secure Storage Keys ──────────────────────────────────────────────────
  static const String accessTokenKey = 'mc_access_token';
  static const String userKey = 'mc_user';

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 10;

  // ─── Service Categories ───────────────────────────────────────────────────
  static const List<String> serviceCategories = [
    'All',
    'cleaning',
    'plumbing',
    'electrical',
    'tutoring',
    'beauty',
    'fitness',
    'repair',
    'other',
  ];

  // ─── Booking Statuses ─────────────────────────────────────────────────────
  static const List<String> bookingStatuses = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
    'failed',
  ];
}
