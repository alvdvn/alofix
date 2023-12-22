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
      return DefaultCall.sim;
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

enum DefaultSim { sim0, sim1, sim2 }

DefaultSim getSimTypeEnum(String simTypeString) {
  switch (simTypeString) {
    case 'Sim0':
      return DefaultSim.sim0;
    case 'Sim1':
      return DefaultSim.sim1;
    case 'Sim2':
      return DefaultSim.sim2;
    default:
      return DefaultSim.sim0;
  }
}

String getTypeSim(DefaultSim type) {
  switch (type) {
    case DefaultSim.sim0:
      return 'Sim0';
    case DefaultSim.sim1:
      return 'Sim1';
    case DefaultSim.sim2:
      return 'Sim2';
  }
}