import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider_start.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:logging/logging.dart';
import 'package:toast/toast.dart';

import 'base_page.dart';

class LogPage extends BasePage {
  const LogPage({super.key});

  @override
  Widget buildPage(final BuildContext context) {
    return _LogPageContent();
  }
}

class _LogPageContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LogPageContentState();
  }
}

class _LogPageContentState extends State<_LogPageContent> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity log'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                LighthouseProviderStart.logs.add([]);
              });
            },
            icon: const Icon(Icons.delete_forever),
          ),
          IconButton(
            onPressed: () {
              final clipboard = LighthouseProviderStart.logs.value.fold("", (
                final previousValue,
                final element,
              ) {
                return "$previousValue\n${element.time}: ${element.level.name}: ${element.message}";
              });
              Clipboard.setData(ClipboardData(text: clipboard)).then((final _) {
                if (context.mounted) {
                  ToastContext().init(context);
                  Toast.show("Copied to clipboard");
                }
              });
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: StreamBuilder<List<LogRecord>>(
        initialData: const [],
        stream: LighthouseProviderStart.logs,
        builder: (final context, final snapshot) {
          final logs = snapshot.requireData;

          return ContentContainerListView.builder(
            itemCount: logs.length,
            itemBuilder: (final BuildContext context, final int index) {
              if (index >= logs.length) {
                return null;
              } else if (index < 0) {
                return null;
              }
              final item = logs[index];

              return ListTile(
                title: Text(
                  "${item.time}: ${item.level.name}: ${item.message}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
