import 'dart:async';
import 'package:base_project/database/dao/call_log_dao.dart';
import 'package:base_project/database/dao/deep_link_dao.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/database/models/deep_link.dart';
import 'package:base_project/database/models/options.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'DbContext.g.dart'; // the generated code will be there

@Database(version: 1, entities: [CallLog, Option, DeepLink])
abstract class AppDatabase extends FloorDatabase {
  CallLogDao get callLogs;

  DeepLinkDao get deepLinks;

  Future<void> reset() async {
    await sqflite.deleteDatabase("app_database.db");
    print("Clean Database");
  }
}

class DatabaseContext {
  static Future<AppDatabase> instance() async {
    return await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }
}