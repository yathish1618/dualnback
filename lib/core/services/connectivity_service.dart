import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns true when the device has any network connectivity.
bool _isConnected(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// Stream provider — emits `true` when online, `false` when offline.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map(_isConnected);
});

/// Async provider — resolves once with the *current* connectivity state.
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final results = await Connectivity().checkConnectivity();
  return _isConnected(results);
});
