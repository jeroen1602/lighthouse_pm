class BuildOptions {
  BuildOptions._();

  // region donations
  static const bool includeSupportButtons =
      bool.fromEnvironment('includeSupportButtons', defaultValue: true);

  static const bool includeSupportPage =
      bool.fromEnvironment('includeSupportPage', defaultValue: true);

  static const bool includePaypal =
      bool.fromEnvironment('includePaypal', defaultValue: true);

  static const bool includeGithubSponsor =
      bool.fromEnvironment('includeGithubSponsor', defaultValue: true);

  static const bool includeGooglePlayInAppPurchases = bool.fromEnvironment(
      'includeGooglePlayInAppPurchases',
      defaultValue: false);
// endregion
}
