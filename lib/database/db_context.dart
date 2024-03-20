import 'dart:async';
import 'package:base_project/database/dao/call_log_dao.dart';
import 'package:base_project/database/dao/deep_link_dao.dart';
import 'package:base_project/database/dao/job_dao.dart';
import 'package:base_project/database/enum.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/database/models/deep_link.dart';
import 'package:base_project/database/models/job.dart';
import 'package:base_project/database/models/options.dart';
import 'package:base_project/database/type_converter.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'db_context.g.dart'; // the generated code will be there

@Database(version: 2, entities: [CallLog, Option, DeepLink, JobQueue])
@TypeConverters([
  CallLogValidConverter,
  CallByConverter,
  EndByConverter,
  CallMethodConverter,
  SyncByConverter,
  CallTypeConverter,
  JobTypeConverter
])
abstract class AppDatabase extends FloorDatabase {
  CallLogDao get callLogs;

  DeepLinkDao get deepLinks;

  JobDao get jobs;

  Future<void> reset() async {
    await sqflite.deleteDatabase("app_database.db");
    print("Clean Database");
  }
  @transaction
  Future<List<CallLog>> getCallLogs(
      {DateTimeRange? range, String? search}) async {
    var query = "SELECT * FROM CallLog";
    List<String> filters = <String>[];

    if (search != null && search.isNotEmpty) {
      filters.add("phoneNumber like '%$search%'");
    }

    if (range != null) {
      filters.add("startAt >= ${range.start.millisecondsSinceEpoch}");
      filters.add("startAt <= ${range.end.millisecondsSinceEpoch}");
    }
    if (filters.isNotEmpty) {
      query += " where ${filters.join(" and ")}";
    }
    query += " order by startAt desc";

    List<Map<String, dynamic>> output = await database.rawQuery(query);

    return output.map((e) => CallLog.fromMap(e)).toList();
  }
}

class DatabaseContext {
  static Future<AppDatabase> instance() async {
    final migration1to2 = Migration(1, 2, (database) async {
      await database.execute('CREATE TABLE IF NOT EXISTS `JobQueue` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `payload` TEXT NOT NULL, `type` INTEGER NOT NULL)');
    });
    return await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2]).build();
  }
}
