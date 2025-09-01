import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/markdown/markdown.dart';
import 'package:markdown_widget/markdown_widget.dart';

class HelpPageSegment extends StatefulWidget {
  const HelpPageSegment(this.page, {this.language = 'en', super.key});

  final String page;
  final String language;

  Future<String> _loadMarkdown(final BuildContext context) async {
    return await DefaultAssetBundle.of(
      context,
    ).loadString('assets/pages/help/${page}_$language.md');
  }

  @override
  State<StatefulWidget> createState() {
    return _HelpItemState();
  }
}

class _HelpItemState extends State<HelpPageSegment> {
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final theming = Theming.fromTheme(theme);

    final fallbackPConfig = theme.brightness == Brightness.dark
        ? PConfig.darkConfig
        : const PConfig();

    final markdownConfig = MarkdownConfigFrom.fromTheme(
      theme,
      creator: (final configs) => MarkdownConfigOpen(configs: configs),
      extraConfigs: [
        IconConfig(
          style: ((theme.textTheme.bodyMedium ?? fallbackPConfig.textStyle)
              .copyWith(
                fontSize: theming.bodyTextIconSize,
                color: theming.iconColor,
              )),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder(
            future: widget._loadMarkdown(context),
            builder: (final context, final snapshot) {
              if (snapshot.hasError) {
                debugPrint(snapshot.error?.toString());
                return Container();
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              return MarkdownBlock(
                data: snapshot.requireData,
                config: markdownConfig,
                selectable: false,
                generator: MarkdownGenerator(
                  inlineSyntaxList: [IconSyntax()],
                  generators: [IconNode.iconGeneratorWithTag],
                  textGenerator: getMarkdownTextGenerator(),
                ),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
