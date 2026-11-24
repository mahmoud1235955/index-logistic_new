import '../../directory/domain/company.dart';
import 'sector.dart';

abstract interface class HomeRepository {
  Future<List<Sector>> getSectors();

  Future<List<Company>> getFeaturedCompanies();
}

enum HomeRepositoryFailureKind { error, offline, expired, permissionDenied }

class HomeRepositoryException implements Exception {
  const HomeRepositoryException(this.kind);

  final HomeRepositoryFailureKind kind;
}
