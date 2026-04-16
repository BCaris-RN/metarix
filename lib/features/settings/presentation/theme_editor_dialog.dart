import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/metarix_theme_config.dart';
import '../../../theme/metarix_theme_controller.dart';

const List<String> _uiFonts = <String>[
  'Segoe UI',
  'Arial',
  'Roboto',
  'Verdana',
];

const List<String> _codeFonts = <String>[
  'Cascadia Code',
  'Consolas',
  'Courier New',
  'monospace',
];

class ThemeEditorDialog extends StatelessWidget {
  const ThemeEditorDialog({required this.controller, super.key});

  final MetarixThemeController controller;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final config = controller.config;
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980, maxHeight: 820),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ThemeHeader(
                    config: config,
                    onModeChanged: controller.setThemeMode,
                  ),
                  const SizedBox(height: 14),
                  _ThemePreview(config: config),
                  const SizedBox(height: 14),
                  _ControlPanel(controller: controller, config: config),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThemeHeader extends StatelessWidget {
  const _ThemeHeader({required this.config, required this.onModeChanged});

  final MetarixThemeConfig config;
  final ValueChanged<ThemeMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Theme', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Tune the MetaRix interface without changing the product flow.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        SegmentedButton<ThemeMode>(
          segments: const <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text('Light'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text('Dark'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text('System'),
            ),
          ],
          selected: <ThemeMode>{config.themeMode},
          onSelectionChanged: (selection) => onModeChanged(selection.first),
        ),
      ],
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.config});

  final MetarixThemeConfig config;

  @override
  Widget build(BuildContext context) {
    final foreground = config.foreground;
    final muted = Color.lerp(config.foreground, config.background, 0.38)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color.lerp(config.background, foreground, 0.22)!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _PreviewDot(color: config.accent),
              const SizedBox(width: 8),
              Text(
                config.preset.label,
                style: TextStyle(
                  color: foreground,
                  fontFamily: config.uiFontFamily,
                  fontSize: config.uiFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                config.themeMode.name,
                style: TextStyle(
                  color: muted,
                  fontFamily: config.codeFontFamily,
                  fontSize: config.codeFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color.lerp(config.background, foreground, 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color.lerp(config.background, config.accent, 0.45)!,
              ),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: foreground,
                fontFamily: config.codeFontFamily,
                fontSize: config.codeFontSize,
                height: 1.35,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _DiffLine(
                    marker: '+',
                    text: 'accent: ${formatThemeColor(config.accent)}',
                    color: config.accent,
                  ),
                  _DiffLine(
                    marker: '~',
                    text: 'surface: ${formatThemeColor(config.background)}',
                    color: muted,
                  ),
                  _DiffLine(
                    marker: '+',
                    text:
                        'font: ${config.uiFontFamily} / ${config.codeFontFamily}',
                    color: foreground,
                  ),
                  _DiffLine(
                    marker: '>',
                    text: 'contrast: ${config.contrast.toStringAsFixed(2)}',
                    color: muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.controller, required this.config});

  final MetarixThemeController controller;
  final MetarixThemeConfig config;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Tokens', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showImportDialog(context),
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Import'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: controller.exportTheme()),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Theme copied')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy theme'),
                ),
                const SizedBox(width: 12),
                DropdownButton<MetarixThemePreset>(
                  value: config.preset,
                  onChanged: (value) {
                    if (value != null) controller.setPreset(value);
                  },
                  items: MetarixThemePreset.values
                      .map(
                        (preset) => DropdownMenuItem<MetarixThemePreset>(
                          value: preset,
                          child: Text(preset.label),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ColorRow(
              label: 'Accent',
              color: config.accent,
              onChanged: (color) =>
                  controller.update(config.copyWith(accent: color)),
            ),
            _ColorRow(
              label: 'Background',
              color: config.background,
              onChanged: (color) =>
                  controller.update(config.copyWith(background: color)),
            ),
            _ColorRow(
              label: 'Foreground',
              color: config.foreground,
              onChanged: (color) =>
                  controller.update(config.copyWith(foreground: color)),
            ),
            _DropdownRow(
              label: 'UI font',
              value: config.uiFontFamily,
              options: _uiFonts,
              onChanged: (value) =>
                  controller.update(config.copyWith(uiFontFamily: value)),
            ),
            _DropdownRow(
              label: 'Code font',
              value: config.codeFontFamily,
              options: _codeFonts,
              onChanged: (value) =>
                  controller.update(config.copyWith(codeFontFamily: value)),
            ),
            _SwitchRow(
              label: 'Translucent sidebar',
              value: config.translucentSidebar,
              onChanged: (value) =>
                  controller.update(config.copyWith(translucentSidebar: value)),
            ),
            _SliderRow(
              label: 'Contrast',
              value: config.contrast,
              min: 0,
              max: 1,
              onChanged: (value) =>
                  controller.update(config.copyWith(contrast: value)),
            ),
            _SwitchRow(
              label: 'Use pointer cursors',
              value: config.usePointerCursors,
              onChanged: (value) =>
                  controller.update(config.copyWith(usePointerCursors: value)),
            ),
            _StepperRow(
              label: 'UI font size',
              value: config.uiFontSize,
              min: 11,
              max: 18,
              onChanged: (value) =>
                  controller.update(config.copyWith(uiFontSize: value)),
            ),
            _StepperRow(
              label: 'Code font size',
              value: config.codeFontSize,
              min: 10,
              max: 18,
              onChanged: (value) =>
                  controller.update(config.copyWith(codeFontSize: value)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final textController = TextEditingController();
    final imported = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import theme'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: textController,
              minLines: 8,
              maxLines: 12,
              decoration: const InputDecoration(
                hintText: '{ "preset": "codexSignature", ... }',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(controller.importTheme(textController.text));
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
    textController.dispose();
    if (context.mounted && imported != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(imported ? 'Theme imported' : 'Theme import failed'),
        ),
      );
    }
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = formatThemeColor(color);
    return _TokenRow(
      label: label,
      control: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: TextFormField(
              key: ValueKey('$label-$value'),
              initialValue: value,
              onFieldSubmitted: (raw) {
                final parsed = parseThemeColor(raw);
                if (parsed != null) onChanged(parsed);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _TokenRow(
      label: label,
      control: DropdownButton<String>(
        value: value,
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
        items: options
            .map(
              (option) =>
                  DropdownMenuItem<String>(value: option, child: Text(option)),
            )
            .toList(),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _TokenRow(
      label: label,
      control: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return _TokenRow(
      label: label,
      control: SizedBox(
        width: 260,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 42,
              child: Text(value.toStringAsFixed(2), textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return _TokenRow(
      label: label,
      control: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: value <= min ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 40,
            child: Text(value.toStringAsFixed(0), textAlign: TextAlign.center),
          ),
          IconButton(
            onPressed: value >= max ? null : () => onChanged(value + 1),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  const _TokenRow({required this.label, required this.control});

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          control,
        ],
      ),
    );
  }
}

class _PreviewDot extends StatelessWidget {
  const _PreviewDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DiffLine extends StatelessWidget {
  const _DiffLine({
    required this.marker,
    required this.text,
    required this.color,
  });

  final String marker;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 18,
            child: Text(marker, style: TextStyle(color: color)),
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
