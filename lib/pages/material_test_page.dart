import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/color_schemes.dart';
import 'package:lighthouse_pm/theming.dart';

import 'base_page.dart';

///
/// A page showing all the colors the material colors that the app uses.
///
class MaterialTestPage extends BasePage with WithBlocStateless {
  const MaterialTestPage({final Key? key}) : super(key: key);

  Widget createBlock(final Color background, final Color text,
      final String name, final TextStyle baseTheme) {
    return Container(
      color: background,
      child: Text(
        name,
        style: baseTheme.copyWith(color: text),
      ),
    );
  }

  List<Widget> _createOnBlock(final Color mainColor, final Color onColor,
      final String mainName, final TextStyle baseTheme) {
    final onName =
        'on${mainName.substring(0, 1).toUpperCase()}${mainName.substring(1)}';
    return [
      createBlock(mainColor, onColor, mainName, baseTheme),
      createBlock(onColor, mainColor, onName, baseTheme),
    ];
  }

  List<Widget> _createCustomBlocks(
      final TextStyle baseTheme, final CustomColors colorScheme) {
    return [
      ..._createOnBlock(
          colorScheme.booting, colorScheme.onBooting, "booting", baseTheme),
      ..._createOnBlock(colorScheme.bootingContainer,
          colorScheme.onBootingContainer, "bootingContainer", baseTheme),
      ..._createOnBlock(
          colorScheme.standby, colorScheme.onStandby, "standby", baseTheme),
      ..._createOnBlock(colorScheme.standbyContainer,
          colorScheme.onStandbyContainer, "standbyContainer", baseTheme),
      ..._createOnBlock(
          colorScheme.sleep, colorScheme.onSleep, "sleep", baseTheme),
      ..._createOnBlock(colorScheme.sleepContainer,
          colorScheme.onSleepContainer, "sleepContainer", baseTheme),
      ..._createOnBlock(colorScheme.on, colorScheme.onOn, "on", baseTheme),
      ..._createOnBlock(colorScheme.onContainer, colorScheme.onOnContainer,
          "onContainer", baseTheme),
    ];
  }

  List<Widget> _createBlocks(
      final TextStyle baseTheme, final ColorScheme colorScheme) {
    return [
      ..._createOnBlock(
          colorScheme.primary, colorScheme.onPrimary, "primary", baseTheme),
      ..._createOnBlock(colorScheme.primaryContainer, colorScheme.onPrimary,
          "primaryContainer", baseTheme),
      ..._createOnBlock(colorScheme.secondary, colorScheme.onSecondary,
          "secondary", baseTheme),
      ..._createOnBlock(colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer, "secondaryContainer", baseTheme),
      ..._createOnBlock(
          colorScheme.tertiary, colorScheme.onTertiary, "tertiary", baseTheme),
      ..._createOnBlock(colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer, "tertiaryContainer", baseTheme),
      ..._createOnBlock(
          colorScheme.error, colorScheme.onError, "error", baseTheme),
      ..._createOnBlock(colorScheme.errorContainer,
          colorScheme.onErrorContainer, "errorContainer", baseTheme),
      ..._createOnBlock(colorScheme.background, colorScheme.onBackground,
          "background", baseTheme),
      ..._createOnBlock(
          colorScheme.surface, colorScheme.onSurface, "surface", baseTheme),
      ..._createOnBlock(colorScheme.surfaceVariant,
          colorScheme.onSurfaceVariant, "surfaceVariant", baseTheme),
      ..._createOnBlock(colorScheme.inverseSurface,
          colorScheme.onInverseSurface, "inverseSurface", baseTheme),
    ];
  }

  List<Widget> _createGridView(
      final String name, final List<Widget> items, final Theming theming) {
    return [
      Text(
        name,
        style: theming.headlineMedium,
      ),
      Expanded(
        child: GridView.count(
            crossAxisCount: 4,
            padding: const EdgeInsets.all(4),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: items),
      ),
    ];
  }

  List<Widget> _createMaterialColorScheme(
      final String name, final ColorScheme colorScheme, final Theming theming) {
    return _createGridView(
        name, _createBlocks(theming.bodyMedium!, colorScheme), theming);
  }

  List<Widget> _createCustomColorScheme(final String name,
      final CustomColors customColors, final Theming theming) {
    return _createGridView(
        name, _createCustomBlocks(theming.bodyMedium!, customColors), theming);
  }

  @override
  Widget buildPage(final BuildContext context) {
    final theme = Theme.of(context);
    final theming = Theming.fromTheme(theme);

    return Scaffold(
      appBar: AppBar(title: const Text('Material')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._createMaterialColorScheme(
              "Current color scheme", theme.colorScheme, theming),
          ..._createMaterialColorScheme(
              "Light color scheme", lightColorScheme, theming),
          ..._createMaterialColorScheme(
              "Dark color scheme", darkColorScheme, theming),
          ..._createCustomColorScheme(
              "Light custom color scheme", lightCustomColors, theming),
          ..._createCustomColorScheme(
              "Dark custom color scheme", darkCustomColors, theming),
        ],
      ),
    );
  }
}
