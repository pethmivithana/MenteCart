// Shared JSON helpers for Mongo-style ids and numeric fields.

String idToString(dynamic value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value;
  }
  if (value is Map<String, dynamic>) {
    final oid = value[r'$oid'];
    if (oid is String) {
      return oid;
    }
    final id = value['_id'];
    if (id != null) {
      return idToString(id);
    }
  }
  return value.toString();
}

double? asDouble(dynamic v) {
  if (v == null) {
    return null;
  }
  if (v is double) {
    return v;
  }
  if (v is int) {
    return v.toDouble();
  }
  if (v is num) {
    return v.toDouble();
  }
  return null;
}

int asInt(dynamic v, [int fallback = 0]) {
  if (v == null) {
    return fallback;
  }
  if (v is int) {
    return v;
  }
  if (v is num) {
    return v.toInt();
  }
  return fallback;
}
