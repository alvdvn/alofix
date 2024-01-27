import 'package:base_project/database/enum.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'JobQueue')
class JobQueue {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String payload = "";
  int type = JobType.mapCall.value;

  JobQueue({this.id, required this.payload, this.type=1});

  @override
  String toString() {
    return "Job{id: $id, payload: $payload, type: $type}";
  }
}
