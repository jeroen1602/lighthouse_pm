class BuildOptions {
  BuildOptions._();

  // region donations
  static const bool includeDonationButtons =
      bool.fromEnvironment('includeDonationButtons', defaultValue: true);

  static const bool includeDonationsPage =
      bool.fromEnvironment('includeDonationsPage', defaultValue: true);

  static const bool includePaypal =
      bool.fromEnvironment('includePaypal', defaultValue: true);

  static const bool includeGithubSponsor =
      bool.fromEnvironment('includeGithubSponsor', defaultValue: true);
// endregion
}
