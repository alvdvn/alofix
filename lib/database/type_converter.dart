import 'package:base_project/database/enum.dart';
import 'package:floor/floor.dart';

class CallLogValidConverter extends TypeConverter<CallLogValid?, int?> {
  @override
  CallLogValid? decode(int? databaseValue) {
    return databaseValue == null
        ? null
        : CallLogValid.getByValue(databaseValue);
  }

  @override
  int? encode(CallLogValid? value) {
    return value?.value;
  }
}

class EndByConverter extends TypeConverter<EndBy?, int?> {
  @override
  EndBy? decode(int? databaseValue) {
    return databaseValue == null ? null : EndBy.getByValue(databaseValue);
  }

  @override
  int? encode(EndBy? value) {
    return value?.value;
  }
}

class CallByConverter extends TypeConverter<CallBy?, int?> {
  @override
  CallBy? decode(int? databaseValue) {
    return databaseValue == null ? null : CallBy.getByValue(databaseValue);
  }

  @override
  int? encode(CallBy? value) {
    return value?.value;
  }
}

class CallMethodConverter extends TypeConverter<CallMethod?, int?> {
  @override
  CallMethod? decode(int? databaseValue) {
    return databaseValue == null ? null : CallMethod.getByValue(databaseValue);
  }

  @override
  int? encode(CallMethod? value) {
    return value?.value;
  }
}

class SyncByConverter extends TypeConverter<SyncBy?, int?> {
  @override
  SyncBy? decode(int? databaseValue) {
    return databaseValue == null ? null : SyncBy.getByValue(databaseValue);
  }

  @override
  int? encode(SyncBy? value) {
    return value?.value;
  }
}

class CallTypeConverter extends TypeConverter<CallType?, int?> {
  @override
  CallType? decode(int? databaseValue) {
    return databaseValue == null ? null : CallType.getByValue(databaseValue);
  }

  @override
  int? encode(CallType? value) {
    return value?.value;
  }
}
