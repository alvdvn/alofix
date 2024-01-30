enum EndBy {
  rider(1),
  other(2);

  const EndBy(this.value);

  final int value;

  static EndBy getByValue(int i) {
    if (i == 0) return EndBy.other;
    return EndBy.values.firstWhere((x) => x.value == i);
  }
}

enum SyncBy {
  background(1),
  other(2);

  const SyncBy(this.value);

  final int value;

  static SyncBy getByValue(int i) {
    if (i == 0) return SyncBy.other;
    return SyncBy.values.firstWhere((x) => x.value == i);
  }
}

enum CallType {
  incomming(2),
  outgoing(1);

  const CallType(this.value);

  final int value;

  static CallType getByValue(int i) {
    if (i == 0) return CallType.outgoing;
    return CallType.values.firstWhere((x) => x.value == i);
  }
}

enum CallMethod {
  sim(2),
  stringee(1);

  const CallMethod(this.value);

  final int value;

  static CallMethod getByValue(int i) {
    if (i == 0) return CallMethod.sim;
    return CallMethod.values.firstWhere((x) => x.value == i);
  }
}

enum CallLogValid {
  valid(1),
  invalid(2);

  const CallLogValid(this.value);

  final int value;

  static CallLogValid getByValue(int? i) {
    if (i == null || i == 0) return CallLogValid.valid;
    return CallLogValid.values.firstWhere((x) => x.value == i);
  }
}

enum CallBy {
  alo(1),
  other(2);

  const CallBy(this.value);

  final int value;

  static CallBy getByValue(int? i) {
    if (i==null || i == 0) return CallBy.other;
    return CallBy.values.firstWhere((x) => x.value == i);
  }
}

enum JobType {
  mapCall(1);

  const JobType(this.value);

  final int value;

  static JobType getByValue(int i) {
    if (i == 0) return JobType.mapCall;
    return JobType.values.firstWhere((x) => x.value == i);
  }
}
