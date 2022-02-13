import 'package:shared_platform/shared_platform.dart';

void main() {
  if (SharedPlatform.isAndroid) {
    print("Running on Android");
  } else if (SharedPlatform.isFuchsia) {
    print("Running on Fuchsia");
  } else if (SharedPlatform.isIOS) {
    print("Running on IOS");
  } else if (SharedPlatform.isLinux) {
    print("Running on Linux");
  } else if (SharedPlatform.isWindows) {
    print("Running on Windows");
  } else if (SharedPlatform.isWeb) {
    print("Running on web");
  } else {
    print("Running on unknown");
  }
}
