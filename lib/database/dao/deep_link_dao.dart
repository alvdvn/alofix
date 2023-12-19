import 'package:base_project/database/models/deep_link.dart';
import 'package:floor/floor.dart';

@dao
abstract class DeepLinkDao {
  @Query("select * from DeepLink")
  Future<List<DeepLink>> getListDeepLink();

  @Query(
      "select * from DeepLink where phone = :phone and saveAt >= :fromDate and saveAt <= :toDate order by saveAt desc limit 1")
  Future<DeepLink?> findDeepLinkByPhone(String phone, int fromDate, int toDate);

  @Query("delete from DeepLink")
  Future<void> cleanDeepLink();

  @Query("delete from DeepLink where saveAt < :before")
  Future<void> removeOldDeepLink(int before);

  @insert
  Future<void> insertDeepLink(DeepLink link);
}
