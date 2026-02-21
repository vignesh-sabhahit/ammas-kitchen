/// App-level configuration constants.
class AppConfig {
  AppConfig._();

  /// Current app version (display string).
  static const String currentVersion = '0.1.0';

  /// Current version code (integer, bump this with every release).
  static const int currentVersionCode = 1;

  /// URL to check for updates.
  /// Host a JSON file here with the latest version info.
  ///
  /// You can use a GitHub Gist (free) — create a gist with a file called
  /// `update.json` and use the raw URL. For example:
  /// `https://gist.githubusercontent.com/YOUR_USERNAME/GIST_ID/raw/update.json`
  ///
  /// The JSON should look like:
  /// ```json
  /// {
  ///   "latest_version": "0.2.0",
  ///   "latest_version_code": 2,
  ///   "download_url": "https://github.com/you/ammas-kitchen/releases/download/v0.2.0/app-release.apk",
  ///   "changelog": "- Better item detection\n- Bug fixes",
  ///   "force_update": false
  /// }
  /// ```
  static const String updateCheckUrl =
      'https://gist.githubusercontent.com/vignesh-sabhahit/2b8b64ce77833afc0cd3a6c91f581fb1/raw/update.json';
}
