import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/json_readers.dart';

const defaultContentJson = '''
{
  "items": [
    {
      "label": "01",
      "title": "Custom Signal",
      "copy": "Describe a capability, proof point, process, or offer.",
      "url": ""
    }
  ],
  "actions": [
    {
      "label": "Contact",
      "url": "#contact"
    }
  ]
}''';

const defaultDesignJson = '''
{
  "accent": "signal",
  "mediaUrl": "",
  "caption": ""
}''';

String prettyJson(JsonMap value) {
  if (value.isEmpty) {
    return '{}';
  }
  return const JsonEncoder.withIndent('  ').convert(value);
}

JsonMap parseJsonObjectText(String value, String label) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return const <String, Object?>{};
  }
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is! Map) {
      throw ValidationFailure('$label must be a JSON object.');
    }
    return Map<String, Object?>.from(decoded);
  } on FormatException catch (error) {
    throw ValidationFailure('$label contains invalid JSON: ${error.message}');
  }
}

String? validateJsonObjectField(String label, String? value) {
  try {
    parseJsonObjectText(value ?? '', label);
    return null;
  } on ValidationFailure catch (error) {
    return error.message;
  }
}

String? validateOptionalHref(String? value) {
  final href = value?.trim() ?? '';
  if (href.isEmpty ||
      href.startsWith('#') ||
      href.startsWith('/') ||
      href.startsWith('mailto:')) {
    return null;
  }
  final parsed = Uri.tryParse(href);
  if (parsed == null || !parsed.hasScheme || parsed.host.trim().isEmpty) {
    return 'Use an absolute URL, anchor, or root-relative path.';
  }
  return null;
}

class SectionDropdown<T> extends StatelessWidget {
  const SectionDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem<T>(value: item, child: Text(labelFor(item))),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
