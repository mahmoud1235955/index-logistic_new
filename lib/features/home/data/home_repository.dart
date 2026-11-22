import '../domain/sector.dart';

abstract interface class HomeRepository {
  Future<List<Sector>> getSectors();
}
