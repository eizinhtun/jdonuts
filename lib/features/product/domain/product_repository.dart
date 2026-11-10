import '../../../core/result/result.dart';
import '../../home/domain/models.dart';

abstract interface class ProductRepository {
  Future<Result<Product?>> findById(String id);
}
