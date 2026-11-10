import '../../../core/result/result.dart';
import 'models.dart';

abstract interface class HomeRepository {
  Future<Result<AppData>> load();
  Future<Result<AppData>> refresh();
  Future<Result<List<Product>>> loadSectionProducts(String sectionId);
}
