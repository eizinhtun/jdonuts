import '../../../core/result/result.dart';
import '../../home/domain/home_repository.dart';
import '../../home/domain/models.dart';
import '../domain/product_repository.dart';

class LocalProductRepository implements ProductRepository {
  const LocalProductRepository(this._homeRepository);

  final HomeRepository _homeRepository;

  @override
  Future<Result<Product?>> findById(String id) async {
    final result = await _homeRepository.load();
    return result.fold<Result<Product?>>(
      (data) => Success(data.product(id)),
      (failure) => Error<Product?>(failure),
    );
  }
}
