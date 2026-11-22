import '../../directory/domain/company.dart';
import 'sector.dart';

abstract interface class HomeRepository {
  Future<List<Sector>> getSectors();

  Future<List<Company>> getFeaturedCompanies();
}
