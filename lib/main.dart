import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:lighthouse_pm/data/local/app_style.dart';
import 'package:lighthouse_pm/data/local/theme_data_and_app_style_stream.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider_start.dart';
import 'package:lighthouse_pm/pages/base_page.dart';
import 'package:lighthouse_pm/pages/database_test_page.dart';
import 'package:lighthouse_pm/pages/help_page.dart';
import 'package:lighthouse_pm/pages/log_page.dart';
import 'package:lighthouse_pm/pages/main_page.dart';
import 'package:lighthouse_pm/pages/not_found_page.dart';
import 'package:lighthouse_pm/pages/settings_page.dart';
import 'package:lighthouse_pm/pages/shortcut_handler_page.dart';
import 'package:lighthouse_pm/pages/simple_base_page.dart';
import 'package:lighthouse_pm/pages/troubleshooting_page.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut.dart';
import 'package:lighthouse_pm/platform_specific/mobile/in_app_purchases.dart';
import 'package:lighthouse_pm/platform_specific/shared/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_platform/shared_platform.dart';

import 'bloc.dart';
import 'build_options.dart';
import 'color_schemes.dart';
import 'pages/material_test_page.dart';

void main() {
  loadIntlStrings();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return Provider<LighthousePMBloc>(
      create: (final _) => _initializeDataBase(),
      dispose: (final _, final bloc) => bloc.close(),
      child: const LighthousePMApp(),
    );
  }

  LighthousePMBloc _initializeDataBase() {
    final db = constructDb();
    final mainBloc = LighthousePMBloc(db);

    initDatabaseLogger();
    LighthouseProviderStart.loadLibrary();
    LighthouseProviderStart.setupPersistence(mainBloc);
    LighthouseProviderStart.setupCallbacks();

    if (BuildOptions.includeGooglePlayInAppPurchases) {
      InAppPurchases.instance
          .handlePendingPurchases()
          .catchError((final error) {
        debugPrint(error.toString());
      });
    }

    return mainBloc;
  }
}

class LighthousePMApp extends StatelessWidget with WithBlocStateless {
  const LighthousePMApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return DynamicColorBuilder(builder: (final lightColor, final darkColor) {
      return StreamBuilder<ThemeDataAndAppStyleStream>(
        stream:
            ThemeDataAndAppStyleStream.getStream(blocWithoutListen(context)),
        initialData: const ThemeDataAndAppStyleStream(null, null, null),
        builder: (final BuildContext context,
            final AsyncSnapshot<ThemeDataAndAppStyleStream>
                themeAndStyleSnapshot) {
          final data = themeAndStyleSnapshot.data;
          final themeMode = data?.themeMode ?? ThemeMode.system;
          final useDynamicColors = data?.style == AppStyle.materialDynamic;
          final dynamicColorsLight = lightColor ?? lightColorScheme;
          final dynamicColorsDark = darkColor ?? darkColorScheme;
          final scrollbarDesktop = data?.alwaysShowScrollbar ?? false;

          final scrollbarTheme = ScrollbarThemeData(
            thumbVisibility: MaterialStateProperty.all(scrollbarDesktop),
            radius: scrollbarDesktop ? Radius.zero : null,
          );

          return MaterialApp(
            debugShowCheckedModeBanner: true,
            title: 'Lighthouse PM',
            theme: ThemeData(
                colorScheme:
                    useDynamicColors ? dynamicColorsLight : lightColorScheme,
                useMaterial3: true,
                scrollbarTheme: scrollbarTheme.copyWith()),
            darkTheme: ThemeData(
                colorScheme:
                    useDynamicColors ? dynamicColorsDark : darkColorScheme,
                useMaterial3: true,
                scrollbarTheme: scrollbarTheme.copyWith()),
            themeMode: themeMode,
            initialRoute: '/',
            onGenerateRoute: (final RouteSettings settings) {
              // Make sure all these pages extend the Base page or else shortcut
              // handling won't work!
              final routes = <String, PageBuilder>{
                '/': (final context) => MainPage(),
                // '/': _createShortcutDebugPage,
                // Uncomment the line above if you need to debug the shortcut handler.
                '/settings': (final context) => const SettingsPage(),
                '/troubleshooting': (final context) =>
                    const TroubleshootingPage(),
                '/help': (final context) => const HelpPage(),
                '/shortcutHandler': (final context) =>
                    ShortcutHandlerPage(settings.arguments),
              };

              routes.addAll(SettingsPage.getSubPages('/settings'));

              if (!kReleaseMode) {
                routes.addAll(<String, PageBuilder>{
                  '/databaseTest': (final context) => DatabaseTestPage()
                });
                routes.addAll(DatabaseTestPage.getSubPages('/databaseTest'));
                routes['/material'] =
                    (final context) => const MaterialTestPage();
                routes['/404'] = (final context) => const NotFoundPage();
                routes['/log'] = (final context) => const LogPage();
              }

              if (SharedPlatform.isWeb || !kReleaseMode) {
                final WidgetBuilder? builder = routes[settings.name];
                return MaterialPageRoute(
                    builder: (final ctx) =>
                        builder?.call(ctx) ?? const NotFoundPage(),
                    settings: settings);
              } else {
                final WidgetBuilder builder = routes[settings.name]!;
                return MaterialPageRoute(
                    builder: (final ctx) => builder(ctx), settings: settings);
              }
            },
          );
        },
      );
    });
  }
}

///
/// A simple shortcut handle debug page. Change the mac address if you need to
/// test it.
///
/// ignore: unused_element
BasePage _createShortcutDebugPage(final BuildContext context) {
  if (!kReleaseMode) {
    return const ShortcutHandlerPage(
        ShortcutHandle(ShortcutTypes.macType, "00:00:00:00:00:00"));
  }
  return const SimpleBasePage(Text('This should not be here.'));
}
