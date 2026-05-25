import 'package:flutter/material.dart';

final class SectionItemDraft {
  SectionItemDraft({
    required String label,
    required String title,
    required String copy,
    required String url,
  }) : label = TextEditingController(text: label),
       title = TextEditingController(text: title),
       copy = TextEditingController(text: copy),
       url = TextEditingController(text: url);

  factory SectionItemDraft.empty(int index) {
    return SectionItemDraft(
      label: (index + 1).toString().padLeft(2, '0'),
      title: '',
      copy: '',
      url: '',
    );
  }

  final TextEditingController label;
  final TextEditingController title;
  final TextEditingController copy;
  final TextEditingController url;

  void dispose() {
    label.dispose();
    title.dispose();
    copy.dispose();
    url.dispose();
  }
}

final class SectionActionDraft {
  SectionActionDraft({required String label, required String url})
    : label = TextEditingController(text: label),
      url = TextEditingController(text: url);

  factory SectionActionDraft.empty() {
    return SectionActionDraft(label: '', url: '');
  }

  final TextEditingController label;
  final TextEditingController url;

  void dispose() {
    label.dispose();
    url.dispose();
  }
}
