// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_context.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CallLogDao? _callLogsInstance;

  DeepLinkDao? _deepLinksInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CallLog` (`id` TEXT NOT NULL, `phoneNumber` TEXT NOT NULL, `hotlineNumber` TEXT, `startAt` INTEGER NOT NULL, `endedAt` INTEGER, `answeredAt` INTEGER, `type` INTEGER, `callDuration` INTEGER, `endedBy` INTEGER, `syncBy` INTEGER, `answeredDuration` INTEGER, `timeRinging` INTEGER, `method` INTEGER NOT NULL, `callBy` INTEGER NOT NULL, `syncAt` INTEGER, `date` TEXT NOT NULL, `isLocal` INTEGER, `callLogValid` INTEGER, `customData` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Option` (`key` TEXT NOT NULL, `value` TEXT NOT NULL, PRIMARY KEY (`key`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `DeepLink` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `phone` TEXT NOT NULL, `data` TEXT, `saveAt` INTEGER)');
        await database.execute(
            'CREATE INDEX `index_CallLog_phoneNumber_startAt` ON `CallLog` (`phoneNumber`, `startAt`)');
        await database.execute(
            'CREATE INDEX `index_DeepLink_saveAt_phone` ON `DeepLink` (`saveAt`, `phone`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CallLogDao get callLogs {
    return _callLogsInstance ??= _$CallLogDao(database, changeListener);
  }

  @override
  DeepLinkDao get deepLinks {
    return _deepLinksInstance ??= _$DeepLinkDao(database, changeListener);
  }
}

class _$CallLogDao extends CallLogDao {
  _$CallLogDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _callLogInsertionAdapter = InsertionAdapter(
            database,
            'CallLog',
            (CallLog item) => <String, Object?>{
                  'id': item.id,
                  'phoneNumber': item.phoneNumber,
                  'hotlineNumber': item.hotlineNumber,
                  'startAt': item.startAt,
                  'endedAt': item.endedAt,
                  'answeredAt': item.answeredAt,
                  'type': _callTypeConverter.encode(item.type),
                  'callDuration': item.callDuration,
                  'endedBy': _endByConverter.encode(item.endedBy),
                  'syncBy': _syncByConverter.encode(item.syncBy),
                  'answeredDuration': item.answeredDuration,
                  'timeRinging': item.timeRinging,
                  'method': item.method.index,
                  'callBy': item.callBy.index,
                  'syncAt': item.syncAt,
                  'date': item.date,
                  'isLocal':
                      item.isLocal == null ? null : (item.isLocal! ? 1 : 0),
                  'callLogValid':
                      _callLogValidConverter.encode(item.callLogValid),
                  'customData': item.customData
                }),
        _callLogUpdateAdapter = UpdateAdapter(
            database,
            'CallLog',
            ['id'],
            (CallLog item) => <String, Object?>{
                  'id': item.id,
                  'phoneNumber': item.phoneNumber,
                  'hotlineNumber': item.hotlineNumber,
                  'startAt': item.startAt,
                  'endedAt': item.endedAt,
                  'answeredAt': item.answeredAt,
                  'type': _callTypeConverter.encode(item.type),
                  'callDuration': item.callDuration,
                  'endedBy': _endByConverter.encode(item.endedBy),
                  'syncBy': _syncByConverter.encode(item.syncBy),
                  'answeredDuration': item.answeredDuration,
                  'timeRinging': item.timeRinging,
                  'method': item.method.index,
                  'callBy': item.callBy.index,
                  'syncAt': item.syncAt,
                  'date': item.date,
                  'isLocal':
                      item.isLocal == null ? null : (item.isLocal! ? 1 : 0),
                  'callLogValid':
                      _callLogValidConverter.encode(item.callLogValid),
                  'customData': item.customData
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CallLog> _callLogInsertionAdapter;

  final UpdateAdapter<CallLog> _callLogUpdateAdapter;

  @override
  Future<List<CallLog>> getAllCallLogs() async {
    return _queryAdapter.queryList(
        'SELECT * FROM CallLog order by startAt desc',
        mapper: (Map<String, Object?> row) => CallLog(
            id: row['id'] as String,
            phoneNumber: row['phoneNumber'] as String,
            startAt: row['startAt'] as int,
            method: CallMethod.values[row['method'] as int],
            date: row['date'] as String,
            callBy: CallBy.values[row['callBy'] as int],
            endedAt: row['endedAt'] as int?,
            answeredAt: row['answeredAt'] as int?,
            type: _callTypeConverter.decode(row['type'] as int?),
            callDuration: row['callDuration'] as int?,
            endedBy: _endByConverter.decode(row['endedBy'] as int?),
            answeredDuration: row['answeredDuration'] as int?,
            timeRinging: row['timeRinging'] as int?,
            syncAt: row['syncAt'] as int?,
            syncBy: _syncByConverter.decode(row['syncBy'] as int?),
            callLogValid:
                _callLogValidConverter.decode(row['callLogValid'] as int?),
            hotlineNumber: row['hotlineNumber'] as String?,
            customData: row['customData'] as String?));
  }

  @override
  Future<List<CallLog>> getCallLogsByDate(String date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CallLog where date = ?1 order by startAt desc',
        mapper: (Map<String, Object?> row) => CallLog(
            id: row['id'] as String,
            phoneNumber: row['phoneNumber'] as String,
            startAt: row['startAt'] as int,
            method: CallMethod.values[row['method'] as int],
            date: row['date'] as String,
            callBy: CallBy.values[row['callBy'] as int],
            endedAt: row['endedAt'] as int?,
            answeredAt: row['answeredAt'] as int?,
            type: _callTypeConverter.decode(row['type'] as int?),
            callDuration: row['callDuration'] as int?,
            endedBy: _endByConverter.decode(row['endedBy'] as int?),
            answeredDuration: row['answeredDuration'] as int?,
            timeRinging: row['timeRinging'] as int?,
            syncAt: row['syncAt'] as int?,
            syncBy: _syncByConverter.decode(row['syncBy'] as int?),
            callLogValid:
                _callLogValidConverter.decode(row['callLogValid'] as int?),
            hotlineNumber: row['hotlineNumber'] as String?,
            customData: row['customData'] as String?),
        arguments: [date]);
  }

  @override
  Future<CallLog?> find(String id) async {
    return _queryAdapter.query('SELECT * FROM CallLog WHERE id = ?1',
        mapper: (Map<String, Object?> row) => CallLog(
            id: row['id'] as String,
            phoneNumber: row['phoneNumber'] as String,
            startAt: row['startAt'] as int,
            method: CallMethod.values[row['method'] as int],
            date: row['date'] as String,
            callBy: CallBy.values[row['callBy'] as int],
            endedAt: row['endedAt'] as int?,
            answeredAt: row['answeredAt'] as int?,
            type: _callTypeConverter.decode(row['type'] as int?),
            callDuration: row['callDuration'] as int?,
            endedBy: _endByConverter.decode(row['endedBy'] as int?),
            answeredDuration: row['answeredDuration'] as int?,
            timeRinging: row['timeRinging'] as int?,
            syncAt: row['syncAt'] as int?,
            syncBy: _syncByConverter.decode(row['syncBy'] as int?),
            callLogValid:
                _callLogValidConverter.decode(row['callLogValid'] as int?),
            hotlineNumber: row['hotlineNumber'] as String?,
            customData: row['customData'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> clean() async {
    await _queryAdapter.queryNoReturn('delete from CallLog');
  }

  @override
  Future<List<CallLog>> getTopByPhone(String phone) async {
    return _queryAdapter.queryList(
        'select * from CallLog where phoneNumber = ?1 order by startAt desc limit 100',
        mapper: (Map<String, Object?> row) => CallLog(id: row['id'] as String, phoneNumber: row['phoneNumber'] as String, startAt: row['startAt'] as int, method: CallMethod.values[row['method'] as int], date: row['date'] as String, callBy: CallBy.values[row['callBy'] as int], endedAt: row['endedAt'] as int?, answeredAt: row['answeredAt'] as int?, type: _callTypeConverter.decode(row['type'] as int?), callDuration: row['callDuration'] as int?, endedBy: _endByConverter.decode(row['endedBy'] as int?), answeredDuration: row['answeredDuration'] as int?, timeRinging: row['timeRinging'] as int?, syncAt: row['syncAt'] as int?, syncBy: _syncByConverter.decode(row['syncBy'] as int?), callLogValid: _callLogValidConverter.decode(row['callLogValid'] as int?), hotlineNumber: row['hotlineNumber'] as String?, customData: row['customData'] as String?),
        arguments: [phone]);
  }

  @override
  Future<List<CallLog>> getCallLogToSync(int minStartAt) async {
    return _queryAdapter.queryList(
        'select * from CallLog where syncAt is null and (syncBy = 1 or startAt > ?1)',
        mapper: (Map<String, Object?> row) => CallLog(id: row['id'] as String, phoneNumber: row['phoneNumber'] as String, startAt: row['startAt'] as int, method: CallMethod.values[row['method'] as int], date: row['date'] as String, callBy: CallBy.values[row['callBy'] as int], endedAt: row['endedAt'] as int?, answeredAt: row['answeredAt'] as int?, type: _callTypeConverter.decode(row['type'] as int?), callDuration: row['callDuration'] as int?, endedBy: _endByConverter.decode(row['endedBy'] as int?), answeredDuration: row['answeredDuration'] as int?, timeRinging: row['timeRinging'] as int?, syncAt: row['syncAt'] as int?, syncBy: _syncByConverter.decode(row['syncBy'] as int?), callLogValid: _callLogValidConverter.decode(row['callLogValid'] as int?), hotlineNumber: row['hotlineNumber'] as String?, customData: row['customData'] as String?),
        arguments: [minStartAt]);
  }

  @override
  Future<List<CallLog>> findByIds(List<String> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM CallLog WHERE id in (' + _sqliteVariablesForIds + ')',
        mapper: (Map<String, Object?> row) => CallLog(
            id: row['id'] as String,
            phoneNumber: row['phoneNumber'] as String,
            startAt: row['startAt'] as int,
            method: CallMethod.values[row['method'] as int],
            date: row['date'] as String,
            callBy: CallBy.values[row['callBy'] as int],
            endedAt: row['endedAt'] as int?,
            answeredAt: row['answeredAt'] as int?,
            type: _callTypeConverter.decode(row['type'] as int?),
            callDuration: row['callDuration'] as int?,
            endedBy: _endByConverter.decode(row['endedBy'] as int?),
            answeredDuration: row['answeredDuration'] as int?,
            timeRinging: row['timeRinging'] as int?,
            syncAt: row['syncAt'] as int?,
            syncBy: _syncByConverter.decode(row['syncBy'] as int?),
            callLogValid:
                _callLogValidConverter.decode(row['callLogValid'] as int?),
            hotlineNumber: row['hotlineNumber'] as String?,
            customData: row['customData'] as String?),
        arguments: [...ids]);
  }

  @override
  Future<List<CallLog>> getLastCallLog() async {
    return _queryAdapter.queryList(
        'SELECT * FROM CallLog ORDER BY startAt DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => CallLog(
            id: row['id'] as String,
            phoneNumber: row['phoneNumber'] as String,
            startAt: row['startAt'] as int,
            method: CallMethod.values[row['method'] as int],
            date: row['date'] as String,
            callBy: CallBy.values[row['callBy'] as int],
            endedAt: row['endedAt'] as int?,
            answeredAt: row['answeredAt'] as int?,
            type: _callTypeConverter.decode(row['type'] as int?),
            callDuration: row['callDuration'] as int?,
            endedBy: _endByConverter.decode(row['endedBy'] as int?),
            answeredDuration: row['answeredDuration'] as int?,
            timeRinging: row['timeRinging'] as int?,
            syncAt: row['syncAt'] as int?,
            syncBy: _syncByConverter.decode(row['syncBy'] as int?),
            callLogValid:
                _callLogValidConverter.decode(row['callLogValid'] as int?),
            hotlineNumber: row['hotlineNumber'] as String?,
            customData: row['customData'] as String?));
  }

  @override
  Future<void> insertCallLog(CallLog callLog) async {
    await _callLogInsertionAdapter.insert(callLog, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCallLog(CallLog callLog) async {
    await _callLogUpdateAdapter.update(callLog, OnConflictStrategy.abort);
  }

  @override
  Future<void> batchUpdate(List<CallLog> callLogs) async {
    if (database is sqflite.Transaction) {
      await super.batchUpdate(callLogs);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.callLogs.batchUpdate(callLogs);
      });
    }
  }

  @override
  Future<CallLog> insertOrUpdateCallLog(CallLog callLog) async {
    if (database is sqflite.Transaction) {
      return super.insertOrUpdateCallLog(callLog);
    } else {
      return (database as sqflite.Database)
          .transaction<CallLog>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.callLogs.insertOrUpdateCallLog(callLog);
      });
    }
  }

  @override
  Future<void> batchInsertOrUpdate(List<CallLog> callLogs) async {
    if (database is sqflite.Transaction) {
      await super.batchInsertOrUpdate(callLogs);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.callLogs.batchInsertOrUpdate(callLogs);
      });
    }
  }
}

class _$DeepLinkDao extends DeepLinkDao {
  _$DeepLinkDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _deepLinkInsertionAdapter = InsertionAdapter(
            database,
            'DeepLink',
            (DeepLink item) => <String, Object?>{
                  'id': item.id,
                  'phone': item.phone,
                  'data': item.data,
                  'saveAt': item.saveAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DeepLink> _deepLinkInsertionAdapter;

  @override
  Future<List<DeepLink>> getListDeepLink() async {
    return _queryAdapter.queryList('select * from DeepLink',
        mapper: (Map<String, Object?> row) => DeepLink(
            id: row['id'] as int?,
            phone: row['phone'] as String,
            data: row['data'] as String?,
            saveAt: row['saveAt'] as int?));
  }

  @override
  Future<DeepLink?> findDeepLinkByPhone(
    String phone,
    int fromDate,
    int toDate,
  ) async {
    return _queryAdapter.query(
        'select * from DeepLink where phone = ?1 and saveAt >= ?2 and saveAt <= ?3 order by saveAt desc limit 1',
        mapper: (Map<String, Object?> row) => DeepLink(id: row['id'] as int?, phone: row['phone'] as String, data: row['data'] as String?, saveAt: row['saveAt'] as int?),
        arguments: [phone, fromDate, toDate]);
  }

  @override
  Future<void> cleanDeepLink() async {
    await _queryAdapter.queryNoReturn('delete from DeepLink');
  }

  @override
  Future<void> removeOldDeepLink(int before) async {
    await _queryAdapter.queryNoReturn('delete from DeepLink where saveAt < ?1',
        arguments: [before]);
  }

  @override
  Future<void> insertDeepLink(DeepLink link) async {
    await _deepLinkInsertionAdapter.insert(link, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _callLogValidConverter = CallLogValidConverter();
final _callByConverter = CallByConverter();
final _endByConverter = EndByConverter();
final _callMethodConverter = CallMethodConverter();
final _syncByConverter = SyncByConverter();
final _callTypeConverter = CallTypeConverter();
