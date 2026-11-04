import 'package:url_launcher/url_launcher.dart';

/// Public Terms and Privacy pages (.env.json). Apple requires both links on
/// any screen that sells a subscription; Play requires the privacy URL.
abstract final class LegalLinks {
  static const terms = String.fromEnvironment('TERMS_URL');
  static const privacy = String.fromEnvironment('PRIVACY_URL');

  static bool get configured => terms.isNotEmpty && privacy.isNotEmpty;

  static Future<void> open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
