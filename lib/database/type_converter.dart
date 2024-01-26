import 'package:base_project/database/enum.dart';
import 'package:floor/floor.dart';

class CallLogValidConverter extends TypeConverter<CallLogValid?, int?> {
  @override
  CallLogValid? decode(int? databaseValue) {
    return databaseValue == null
        ? CallLogValid.getByValue(0)
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
    return databaseValue == null
        ? EndBy.getByValue(0)
        : EndBy.getByValue(databaseValue);
  }

  @override
  int? encode(EndBy? value) {
    return value?.value;
  }
}

class CallByConverter extends TypeConverter<CallBy?, int?> {
  @override
  CallBy? decode(int? databaseValue) {
    return databaseValue == null
        ? CallBy.getByValue(0)
        : CallBy.getByValue(databaseValue);
  }

  @override
  int? encode(CallBy? value) {
    return value?.value;
  }
}

class CallMethodConverter extends TypeConverter<CallMethod?, int?> {
  @override
  CallMethod? decode(int? databaseValue) {
    return databaseValue == null
        ? CallMethod.getByValue(0)
        : CallMethod.getByValue(databaseValue);
  }

  @override
  int? encode(CallMethod? value) {
    return value?.value;
  }
}

class SyncByConverter extends TypeConverter<SyncBy?, int?> {
  @override
  SyncBy? decode(int? databaseValue) {
    return databaseValue == null
        ? SyncBy.getByValue(0)
        : SyncBy.getByValue(databaseValue);
  }

  @override
  int? encode(SyncBy? value) {
    return value?.value;
  }
}

class CallTypeConverter<T> extends TypeConverter<CallType?, int?> {
  @override
  CallType? decode(int? databaseValue) {
    return databaseValue == null
        ? CallType.getByValue(0)
        : CallType.getByValue(databaseValue);
  }

  @override
  int? encode(CallType? value) {
    return value?.value;
  }
}

class JobTypeConverter extends TypeConverter<JobType?, int?> {
  @override
  JobType? decode(int? databaseValue) {
    return databaseValue == null
        ? JobType.getByValue(0)
        : JobType.getByValue(databaseValue);
  }

  @override
  int? encode(JobType? value) {
    return value?.value;
  }
}
