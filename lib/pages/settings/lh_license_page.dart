import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../simple_base_page.dart';

///
/// A wrapper for the license page so it's compatible.
///
class LHLicensePage extends SimpleBasePage {
  LHLicensePage({final Key? key})
    : super(
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (final _, final snapshot) {
            final data = snapshot.data;
            return LicensePage(
              applicationName: "Lighthouse Power management",
              applicationIcon: SvgPicture.asset('assets/images/app-icon.svg'),
              applicationVersion: data?.version,
              applicationLegalese: "Copyright© 2020-2024 Jeroen1602",
            );
          },
        ),
        key: key,
      );
}
