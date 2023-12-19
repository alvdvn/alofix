import 'package:floor/floor.dart';

@entity
class Option {
  @primaryKey
  String key = "";
  String value = "";

  Option(this.key, this.value);

  @override
  String toString() {
    return "Options{key:$key, value: $value)";
  }
}
