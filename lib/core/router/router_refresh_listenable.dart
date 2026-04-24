import 'package:flutter/foundation.dart';

/// A [Listenable] that triggers GoRouter to re-evaluate redirects.
/// Call [notify] whenever auth state or other routing-relevant state changes.
class RouterRefreshListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}
