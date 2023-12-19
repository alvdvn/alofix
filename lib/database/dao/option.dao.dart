import 'package:base_project/database/models/options.dart';
import 'package:floor/floor.dart';

@dao
abstract class OptionDao {
  @Query("select * from Option")
  Future<List<Option>> getOptions();

  @Query("select * from Option where key = :key")
  Future<Option> findOption(String key);

  @insert
  Future<Option> setOption(Option option);

  @update
  Future<Option> updateOption(Option option);

  @delete
  Future<void> deleteOption(Option option);
}
