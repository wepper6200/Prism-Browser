import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Writes each watchPerformance report to build/KEY.json.
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    for (final e in data.entries) {
      final f = File('build/${e.key}.json');
      await f.create(recursive: true);
      await f.writeAsString(
        const JsonEncoder.withIndent('  ').convert(e.value),
      );
    }
  },
);
