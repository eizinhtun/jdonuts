import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jdonuts/core/network/network_reachability.dart';

void main() {
  test(
    'reports offline until a connected interface has internet reachability',
    () async {
      final changes = StreamController<List<ConnectivityResult>>();
      var internetAvailable = false;
      var probeCount = 0;
      final reachability = NetworkReachability(
        checkConnectivity: () async => const [ConnectivityResult.none],
        connectivityChanges: changes.stream,
        probe: () async {
          probeCount++;
          return internetAvailable;
        },
      );
      final initialState = Completer<bool>();
      final reconnectionState = Completer<bool>();
      var eventIndex = 0;
      final subscription = reachability.watch().listen((isOnline) {
        if (eventIndex++ == 0) {
          initialState.complete(isOnline);
        } else {
          reconnectionState.complete(isOnline);
        }
      });

      try {
        expect(
          await initialState.future.timeout(const Duration(seconds: 2)),
          isFalse,
        );
        expect(probeCount, 0);

        internetAvailable = true;
        changes.add(const [ConnectivityResult.wifi]);
        expect(
          await reconnectionState.future.timeout(const Duration(seconds: 2)),
          isTrue,
        );
        expect(probeCount, 1);
      } finally {
        await subscription.cancel();
        await changes.close();
        reachability.dispose();
      }
    },
  );

  test(
    'reports offline when a connected interface cannot reach the probe',
    () async {
      final reachability = NetworkReachability(
        checkConnectivity: () async => const [ConnectivityResult.mobile],
        connectivityChanges: const Stream.empty(),
        probe: () async => false,
      );
      addTearDown(reachability.dispose);

      await expectLater(reachability.watch(), emits(false));
    },
  );

  test('checks the HTTP reachability endpoint for its 204 response', () async {
    Uri? requestedUri;
    final reachability = NetworkReachability(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response('', 204);
      }),
      checkConnectivity: () async => const [ConnectivityResult.wifi],
      connectivityChanges: const Stream.empty(),
    );
    addTearDown(reachability.dispose);

    await expectLater(reachability.watch(), emits(true));

    expect(requestedUri, Uri.https('www.google.com', '/generate_204'));
  });
}
