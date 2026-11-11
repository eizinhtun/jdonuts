import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../result/result.dart';

enum InternetReachability { reachable, unreachable, unknown }

/// Reports interface availability separately from internet reachability.
class NetworkStatus {
  static const offline = NetworkStatus(
    networkAvailable: false,
    internetReachability: InternetReachability.unreachable,
  );
  static const online = NetworkStatus(
    networkAvailable: true,
    internetReachability: InternetReachability.reachable,
  );

  const NetworkStatus({
    required this.networkAvailable,
    required this.internetReachability,
    this.failure,
  });

  const NetworkStatus.unknown({Failure? failure})
    : this(
        networkAvailable: null,
        internetReachability: InternetReachability.unknown,
        failure: failure,
      );

  final bool? networkAvailable;
  final InternetReachability internetReachability;
  final Failure? failure;

  bool get canReachInternet =>
      internetReachability == InternetReachability.reachable;
}

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

  Stream<NetworkStatus> watch() async* {
    yield await _readCurrentStatus();
    await for (final state
        in _connectivityChanges ?? _connectivity.onConnectivityChanged) {
      yield await _readReachability(state);
    }
  }

  Future<NetworkStatus> _readCurrentStatus() async {
    try {
      final state =
          await (_checkConnectivity?.call() ??
              _connectivity.checkConnectivity());
      return await _readReachability(state);
    } on Object catch (error, stackTrace) {
      return NetworkStatus.unknown(
        failure: NetworkFailure(
          'Could not determine network availability.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<NetworkStatus> _readReachability(
    List<ConnectivityResult> state,
  ) async {
    if (state.isEmpty || state.contains(ConnectivityResult.none)) {
      return const NetworkStatus(
        networkAvailable: false,
        internetReachability: InternetReachability.unreachable,
      );
    }
    try {
      final reachable = _probe != null
          ? await _probe()
          : (await _client.get(_probeUri).timeout(_probeTimeout)).statusCode ==
                204;
      return NetworkStatus(
        networkAvailable: true,
        internetReachability: reachable
            ? InternetReachability.reachable
            : InternetReachability.unreachable,
      );
    } on Object catch (error, stackTrace) {
      return NetworkStatus(
        networkAvailable: true,
        internetReachability: InternetReachability.unknown,
        failure: NetworkFailure(
          'Could not determine internet reachability.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  void dispose() => _client.close();
}
