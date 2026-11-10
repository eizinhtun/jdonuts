import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Combines the device's network interface state with a real reachability probe.
/// A Wi-Fi/mobile connection alone does not guarantee internet access.
class NetworkReachability {
  factory NetworkReachability({
    Connectivity? connectivity,
    http.Client? client,
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
    Stream<List<ConnectivityResult>>? connectivityChanges,
    Future<bool> Function()? probe,
  }) => NetworkReachability._(
    connectivity ?? Connectivity(),
    client ?? http.Client(),
    checkConnectivity,
    connectivityChanges,
    probe,
  );

  NetworkReachability._(
    this._connectivity,
    this._client,
    this._checkConnectivity,
    this._connectivityChanges,
    this._probe,
  );

  static final _probeUri = Uri.parse('https://www.google.com/generate_204');
  static const _probeTimeout = Duration(seconds: 3);

  final Connectivity _connectivity;
  final http.Client _client;
  final Future<List<ConnectivityResult>> Function()? _checkConnectivity;
  final Stream<List<ConnectivityResult>>? _connectivityChanges;
  final Future<bool> Function()? _probe;

  Stream<bool> watch() async* {
    yield await _readReachability(await _currentConnectivity());
    await for (final state
        in _connectivityChanges ?? _connectivity.onConnectivityChanged) {
      yield await _readReachability(state);
    }
  }

  Future<List<ConnectivityResult>> _currentConnectivity() async {
    try {
      return await (_checkConnectivity?.call() ??
          _connectivity.checkConnectivity());
    } on Object {
      return const [ConnectivityResult.none];
    }
  }

  Future<bool> _readReachability(List<ConnectivityResult> state) async {
    if (state.isEmpty || state.contains(ConnectivityResult.none)) return false;
    try {
      if (_probe != null) return await _probe();
      final response = await _client.get(_probeUri).timeout(_probeTimeout);
      return response.statusCode == 204;
    } on Object {
      return false;
    }
  }

  void dispose() => _client.close();
}
