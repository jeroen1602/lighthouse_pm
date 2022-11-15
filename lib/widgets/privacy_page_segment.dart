import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:lighthouse_pm/intl/ordinal.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/markdown/markdown.dart';

class PrivacyPageSegment extends StatefulWidget {
  const PrivacyPageSegment(
      {required this.version,
      required this.language,
      this.startDate,
      this.endDate,
      super.key});

  final String version;
  final String language;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  State<StatefulWidget> createState() {
    return _PrivacyPageSegmentState();
  }
}

class _PrivacyPageSegmentState extends State<PrivacyPageSegment> {
  String _formatDate(final DateTime dateTime) {
    return '${DateFormat("MMMM").format(dateTime)} ${Ordinal.ordinalWithNumber(dateTime.day)} ${dateTime.year}';
  }

  String _getSubtitle() {
    String out = "";
    final endDate = widget.endDate;
    final startDate = widget.startDate;
    if (endDate != null) {
      out += 'Pre ${_formatDate(endDate)}';
    }
    if (startDate != null) {
      if (out.isNotEmpty) {
        out += " | ";
      }
      out += 'Post ${_formatDate(startDate)}';
    }
    return out;
  }

  Future<String> _loadMarkdown(final BuildContext context, final String version,
      [final String language = "en"]) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/pages/privacy_v${version}_$language.md');
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final theming = Theming.fromTheme(theme);

    return Column(
      children: [
        ListTile(
          title: Text('Version ${widget.version}', style: theming.bodyTextBold),
          subtitle: Text(_getSubtitle()),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: FutureBuilder(
              future: _loadMarkdown(context, widget.version, widget.language),
              builder: (final context, final snapshot) {
                if (snapshot.hasError) {
                  debugPrint(snapshot.error?.toString());
                  return Container();
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return MarkdownBody(
                  data: snapshot.requireData,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme),
                  inlineSyntaxes: [SuperscriptSyntax()],
                  selectable: true,
                  onTapLink: markdownOpenLinkOnTap,
                );
              },
            )),
      ],
    );
  }
}
