import 'package:flutter/material.dart';

/// Global key that lets services (e.g. notification tap handlers) navigate
/// without needing a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();