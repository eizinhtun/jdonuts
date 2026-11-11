import '../../../core/result/result.dart';
import 'models.dart';

abstract interface class HomeRepository {
  Future<Result<AppData>> load();
  Future<Result<AppData>> loadForAccount(String accountPhone);
  Future<Result<AppData>> refresh();
  Future<Result<AppData>> refreshForAccount(String accountPhone);
  Future<Result<List<Product>>> loadSectionProducts(String sectionId);
}
