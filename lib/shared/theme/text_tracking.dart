import 'package:flutter/widgets.dart';

/// Letter-spacing that is safe in every script.
///
/// Arabic-script languages such as Urdu join letters together; any added
/// letter-spacing pulls the joined letters apart, so tracking is dropped in
/// right-to-left text. Use instead of a raw `letterSpacing:` value.
double tracking(BuildContext context, double value) =>
    Directionality.of(context) == TextDirection.rtl ? 0 : value;
