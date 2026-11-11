import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/features/home/domain/home_repository.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/product/data/local_product_repository.dart';

void main() {
  test('product lookup reads the shared local catalog by id', () async {
    final repository = LocalProductRepository(_FakeHomeRepository(_appData));

    final result = await repository.findById('coconut');

    expect(result, isA<Success<Product?>>());
    expect((result as Success<Product?>).value?.code, 'JD022123');
  });

  test(
    'missing product is represented as an empty successful lookup',
    () async {
      final repository = LocalProductRepository(_FakeHomeRepository(_appData));

      final result = await repository.findById('missing');

      expect(result, isA<Success<Product?>>());
      expect((result as Success<Product?>).value, isNull);
    },
  );
}

class _FakeHomeRepository implements HomeRepository {
  const _FakeHomeRepository(this.data);
  final AppData data;

  @override
  Future<Result<AppData>> load() async => Success(data);

  @override
  Future<Result<AppData>> refresh() async => Success(data);

  @override
  Future<Result<List<Product>>> loadSectionProducts(String sectionId) async =>
      const Success([]);
}

final _appData = AppData(
  member: const Member(
    id: 'member-1',
    name: 'Hania',
    tier: 'Silver',
    points: 680000,
    pointsToGold: 500,
    notifications: 2,
  ),
  products: const [
    Product(
      id: 'coconut',
      code: 'JD022123',
      name: 'Coconut Donut',
      priceMmk: 3200,
      isNew: true,
      image: 'coconut.svg',
      description: 'Coconut donut.',
    ),
  ],
  sections: const [],
  banners: const [],
  shops: const [],
  challenges: const [],
);
