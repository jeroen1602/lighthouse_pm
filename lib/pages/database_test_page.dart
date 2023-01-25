import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/pages/database/group_dao_page.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:lighthouse_pm/widgets/content_container_widget.dart';
import 'package:toast/toast.dart';

import 'base_page.dart';
import 'database/nickname_dao_page.dart';
import 'database/settings_dao_page.dart';
import 'database/vive_base_station_dao_page.dart';

class DatabaseTestPage extends BasePage with WithBlocStateless {
  DatabaseTestPage({final Key? key}) : super(key: key, replace: true);

  @override
  Widget buildPage(final BuildContext context) {
    final theming = Theming.of(context);

    final bloc = blocWithoutListen(context);

    final items = <Widget>[
      ListTile(
        leading: const Icon(
          Icons.warning,
          color: Colors.orange,
          size: 30,
        ),
        title: Text(
          'WARNING!',
          style: theming.headlineMedium,
        ),
        subtitle: const Text(
            'This is a page meant for development, changing values here may cause the (web)app to become unstable and crash!'),
        isThreeLine: true,
      ),
      const Divider(
        thickness: 3,
      ),
      ListTile(
        title: const Text('Schema version'),
        subtitle: Text('Version: ${bloc.db.schemaVersion}'),
      ),
      const Divider(),
      ListTile(
        title: const Text('Known tables'),
        subtitle: Text(_getTables(bloc)),
        onLongPress: () async {
          await Clipboard.setData(ClipboardData(text: _getTables(bloc)));
          Toast.show('Copied to clipboard',
              duration: Toast.lengthShort, gravity: Toast.bottom);
        },
        isThreeLine: true,
      ),
      const Divider(),
      FutureBuilder<String>(
          future: _getInstalledTables(bloc),
          builder: (final context, final snapshot) {
            final data = snapshot.data;
            if (snapshot.hasError) {
              final error = snapshot.error;
              return ListTile(
                title: const Text('Error!'),
                subtitle: Text(error.toString()),
              );
            } else if (data != null) {
              final knownTables = _getTables(bloc).split('\n');
              final installedTables = data.split('\n');
              // Check if the lists are equal, if they are not show a warning.
              if (listEquals(knownTables, installedTables)) {
                return ListTile(
                  title: const Text('Installed tables'),
                  subtitle: Text(data),
                  onLongPress: () async {
                    await Clipboard.setData(ClipboardData(text: data));
                    Toast.show('Copied to clipboard',
                        duration: Toast.lengthShort, gravity: Toast.bottom);
                  },
                );
              } else {
                return Column(
                  children: [
                    ListTile(
                      title: const Text('Installed tables'),
                      subtitle: Text(data),
                      onLongPress: () async {
                        await Clipboard.setData(ClipboardData(text: data));
                        Toast.show('Copied to clipboard',
                            duration: Toast.lengthShort, gravity: Toast.bottom);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                          'WARNING installed tables do not match known tables!'
                          '\nYou should create a migration!',
                          style: theming.headlineSmall),
                      leading: const Icon(
                        Icons.warning,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),
                  ],
                );
              }
            } else {
              return const CircularProgressIndicator();
            }
          }),
      const Divider(),
      ListTile(
        title: Text('Daos',
            style: theming.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      const Divider(thickness: 1.5),
    ];

    for (final dao in _DaoContainer._knownDaos) {
      items.addAll(<Widget>[
        ListTile(
          title: Text(dao.daoName),
          subtitle:
              dao.daoDescription != null ? Text(dao.daoDescription!) : null,
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            Navigator.pushNamed(context, '/databaseTest${dao.pageLink}');
          },
        ),
        const Divider(),
      ]);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Database test page'),
        ),
        body: ContentContainerListView(
          children: items,
        ));
  }

  String _getTables(final LighthousePMBloc bloc) {
    final tableList = bloc.getKnownTables();
    var tables = '';
    for (final table in tableList) {
      tables += '$table\n';
    }

    return tables.trim();
  }

  Future<String> _getInstalledTables(final LighthousePMBloc bloc) async {
    return bloc.getInstalledTables().then((final tableList) {
      var tables = '';
      for (final table in tableList) {
        tables += '$table\n';
      }

      return tables.trim();
    });
  }

  static final Map<String, PageBuilder> _subPages = {
    '/nicknameDao': (final context) => const NicknameDaoPage(),
    '/settingsDao': (final context) => const SettingsDaoPage(),
    '/viveBaseStationDao': (final context) => const ViveBaseStationDaoPage(),
    '/groupDao': (final context) => const GroupDaoPage(),
  };

  static Map<String, PageBuilder> getSubPages(final String parentPath) {
    final Map<String, PageBuilder> subPages = {};

    for (final subPage in _subPages.entries) {
      subPages['$parentPath${subPage.key}'] = subPage.value;
    }

    return subPages;
  }
}

class _DaoContainer {
  final String daoName;
  final String? daoDescription;
  final String pageLink;

  const _DaoContainer(this.daoName, this.pageLink, {this.daoDescription});

  static const List<_DaoContainer> _knownDaos = [
    _DaoContainer('NicknameDao', '/nicknameDao',
        daoDescription:
            'A dao that handles storage of nicknames and last seen'),
    _DaoContainer('SettingsDao', '/settingsDao',
        daoDescription: 'A dao that handles storage of settings'),
    _DaoContainer('ViveBaseStationDao', '/viveBaseStationDao',
        daoDescription: 'A dao that handles storage of vive base station ids'),
    _DaoContainer('GroupDao', '/groupDao',
        daoDescription:
            'A dao that handles the storage and linking of groups to lighthouses')
  ];
}
