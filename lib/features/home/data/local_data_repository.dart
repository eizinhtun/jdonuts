import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/models.dart';

abstract interface class LocalDataRepository {
  Future<AppData> load();
  Future<void> refresh();
}

class SeedDataRepository implements LocalDataRepository {
  AppData? _data;
  @override
  Future<AppData> load() async {
    if (_data != null) return _data!;
    final raw = await rootBundle.loadString('assets/data/seed.json');
    _data = AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _data!;
  }

  @override
  Future<void> refresh() async {
    await load();
  }
}
