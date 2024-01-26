import 'package:base_project/database/enum.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'JobQueue')
class JobQueue {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String payload = "";
  JobType type = JobType.mapCall;

  JobQueue({this.id, required this.payload, required this.type});

  @override
  String toString() {
    return "Job{id: $id, payload: $payload, type: $type}";
  }
}
