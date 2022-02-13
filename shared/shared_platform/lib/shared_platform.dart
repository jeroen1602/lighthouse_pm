export 'src/shared_platform_unsupported.dart'
    if (dart.library.html) 'src/shared_platform_web.dart'
    if (dart.library.io) 'shared_platform_io.dart';
