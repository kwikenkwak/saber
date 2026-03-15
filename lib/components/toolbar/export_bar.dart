import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/theming/adaptive_circular_progress_indicator.dart';
import 'package:saber/i18n/strings.g.dart';

class ExportBar extends StatefulWidget {
  const ExportBar({
    super.key,
    required this.axis,
    required this.toggleExportBar,
    required this.exportAsSba,
    required this.exportAsPdf,
    required this.exportAsPng,
  });

  final Axis axis;

  final VoidCallback toggleExportBar;

  final Future Function(BuildContext, {void Function(int, int)? onProgress})? exportAsSba;
  final Future Function(BuildContext, {void Function(int, int)? onProgress})? exportAsPdf;
  final Future Function(BuildContext, {void Function(int, int)? onProgress})? exportAsPng;

  @override
  State<ExportBar> createState() => _ExportBarState();
}

class _ExportBarState extends State<ExportBar> {
  /// The current export function being executed.
  /// If this is null, no export is being executed.
  Future Function(BuildContext, {void Function(int, int)? onProgress})? _currentlyExporting;
  String? _exportProgress;

  void Function()? _onPressed(
    Future Function(BuildContext, {void Function(int, int)? onProgress})? exportFunction,
    BuildContext context,
  ) {
    if (_currentlyExporting != null) return null;
    if (exportFunction == null) return null;
    return () {
      setState(() {
        _currentlyExporting = exportFunction;
        _exportProgress = null;
      });
      exportFunction(context, onProgress: (current, total) {
        setState(() {
          _exportProgress = '$current / $total';
        });
      }).then((_) {
        widget.toggleExportBar();
        setState(() {
          _currentlyExporting = null;
          _exportProgress = null;
        });
      });
    };
  }

  Widget _buttonChild(
    Future Function(BuildContext, {void Function(int, int)? onProgress})? exportFunction,
    String text,
  ) {
    if (exportFunction == null || _currentlyExporting != exportFunction) {
      return Text(text);
    } else {
      // if this is currently exporting, show progress
      if (_exportProgress != null) return Text(_exportProgress!);
      return AdaptiveCircularProgressIndicator.textStyled(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text(t.editor.toolbar.exportAs),
      const SizedBox.square(dimension: 8),
      Builder(
        builder: (context) {
          return TextButton(
            onPressed: _onPressed(widget.exportAsSba, context),
            child: _buttonChild(widget.exportAsSba, 'SBA'),
          );
        },
      ),
      Builder(
        builder: (context) {
          return TextButton(
            onPressed: _onPressed(widget.exportAsPdf, context),
            child: _buttonChild(widget.exportAsPdf, 'PDF'),
          );
        },
      ),
      if (kDebugMode)
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: _onPressed(widget.exportAsPng, context),
              child: _buttonChild(widget.exportAsPng, 'PNG'),
            );
          },
        ),
    ];

    return Center(
      child: Padding(
        padding: const .all(8),
        child: SingleChildScrollView(
          scrollDirection: widget.axis,
          child: Flex(direction: widget.axis, children: children),
        ),
      ),
    );
  }
}
