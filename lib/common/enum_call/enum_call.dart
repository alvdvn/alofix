enum DefaultCall { aloNinja, zalo, sim }

DefaultCall getCallTypeEnum(String callTypeString) {
  switch (callTypeString) {
    case '1':
      return DefaultCall.aloNinja;
    case '2':
      return DefaultCall.zalo;
    case '3':
      return DefaultCall.sim;
    default:
      return DefaultCall.aloNinja;
  }
}

String getTypeCall(DefaultCall callType) {
  switch (callType) {
    case DefaultCall.aloNinja:
      return '1';
    case DefaultCall.zalo:
      return '2';
    case DefaultCall.sim:
      return '3';
  }
}
