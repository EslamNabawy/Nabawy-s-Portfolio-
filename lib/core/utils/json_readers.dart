typedef JsonMap = Map<String, Object?>;

String readString(JsonMap json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('Missing required string field "$key".');
}

String? readOptionalString(JsonMap json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  throw FormatException('Field "$key" must be a string when provided.');
}

bool readBool(JsonMap json, String key, {bool defaultValue = false}) {
  final value = json[key];
  if (value == null) {
    return defaultValue;
  }
  if (value is bool) {
    return value;
  }
  throw FormatException('Field "$key" must be a boolean.');
}

int readInt(JsonMap json, String key, {int defaultValue = 0}) {
  final value = json[key];
  if (value == null) {
    return defaultValue;
  }
  if (value is int) {
    return value;
  }
  if (value is num && value % 1 == 0) {
    return value.toInt();
  }
  throw FormatException('Field "$key" must be an integer.');
}

DateTime? readOptionalDateTime(JsonMap json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.parse(value).toUtc();
  }
  throw FormatException('Field "$key" must be an ISO timestamp.');
}

List<String> readStringList(JsonMap json, String key) {
  final value = json[key];
  if (value == null) {
    return const <String>[];
  }
  if (value is Iterable) {
    return List<String>.unmodifiable(
      value.map((item) {
        if (item is! String || item.trim().isEmpty) {
          throw FormatException('Field "$key" contains a non-string item.');
        }
        return item.trim();
      }),
    );
  }
  throw FormatException('Field "$key" must be a string array.');
}

JsonMap readJsonObject(JsonMap json, String key) {
  final value = json[key];
  final field = key;
  if (value == null) {
    return const <String, Object?>{};
  }
  if (value is Map) {
    return Map<String, Object?>.unmodifiable(
      value.map((key, value) {
        if (key is! String) {
          throw FormatException('Field "$field" contains a non-string key.');
        }
        return MapEntry<String, Object?>(key, value);
      }),
    );
  }
  throw FormatException('Field "$key" must be a JSON object.');
}
