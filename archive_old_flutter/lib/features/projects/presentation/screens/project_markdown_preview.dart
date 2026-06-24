import 'package:flutter/material.dart';

import 'project_form_support.dart';

class ProjectMarkdownPreviewSection extends StatelessWidget {
  const ProjectMarkdownPreviewSection({
    super.key,
    required this.description,
    required this.architectureNotes,
    required this.caseStudyMarkdown,
  });

  final String description;
  final String architectureNotes;
  final String caseStudyMarkdown;

  @override
  Widget build(BuildContext context) {
    return ProjectFormSection(
      title: 'Content Preview',
      children: [
        _PreviewBlock(title: 'Description', markdown: description),
        const SizedBox(height: 16),
        _PreviewBlock(title: 'Architecture', markdown: architectureNotes),
        const SizedBox(height: 16),
        _PreviewBlock(title: 'Case Study', markdown: caseStudyMarkdown),
      ],
    );
  }
}

class _PreviewBlock extends StatelessWidget {
  const _PreviewBlock({required this.title, required this.markdown});

  final String title;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final trimmed = markdown.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: trimmed.isEmpty
                ? const Text('Nothing to preview.')
                : SimpleMarkdownPreview(markdown: trimmed),
          ),
        ),
      ],
    );
  }
}

class SimpleMarkdownPreview extends StatelessWidget {
  const SimpleMarkdownPreview({super.key, required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];
    final codeBuffer = <String>[];
    var inCodeBlock = false;

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.trim().startsWith('```')) {
        if (inCodeBlock) {
          widgets.add(_CodeBlock(code: codeBuffer.join('\n')));
          codeBuffer.clear();
        }
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) {
        codeBuffer.add(line);
        continue;
      }
      widgets.add(_renderLine(context, line));
    }
    if (codeBuffer.isNotEmpty) {
      widgets.add(_CodeBlock(code: codeBuffer.join('\n')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _renderLine(BuildContext context, String line) {
    final text = line.trim();
    if (text.isEmpty) {
      return const SizedBox(height: 8);
    }
    if (text.startsWith('### ')) {
      return _TextLine(text: text.substring(4), style: _headingStyle(context));
    }
    if (text.startsWith('## ')) {
      return _TextLine(text: text.substring(3), style: _headingStyle(context));
    }
    if (text.startsWith('# ')) {
      return _TextLine(text: text.substring(2), style: _headingStyle(context));
    }
    if (text.startsWith('- ') || text.startsWith('* ')) {
      return _BulletLine(text: text.substring(2));
    }
    return _TextLine(text: text, style: Theme.of(context).textTheme.bodyMedium);
  }

  TextStyle? _headingStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
  }
}

class _TextLine extends StatelessWidget {
  const _TextLine({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: style),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•'),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }
}
