import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../simple_base_page.dart';

///
/// A wrapper for the license page so it's compatible.
///
class LHLicensePage extends SimpleBasePage {
  LHLicensePage()
      : super(FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (_, snapshot) {
              final data = snapshot.data;
              return LicensePage(
                applicationName: "Lighthouse Power management",
                applicationIcon: SvgPicture.asset('assets/images/app-icon.svg'),
                applicationVersion: data?.version,
                applicationLegalese: "Copyright (C) 2020 Jeroen1602",
              );
            }));
}
