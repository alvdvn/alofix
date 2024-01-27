import 'package:base_project/database/models/job.dart';
import 'package:floor/floor.dart';

@dao
abstract class JobDao {
  @Query("select * from JobQueue")
  Future<List<JobQueue>> getJobs();

  @insert
  Future<void> insertJob(JobQueue job);

  @delete
  Future<void> deleteJob(JobQueue job);

  @Query("delete from JobQueue where id =:jobId")
  Future<void> deleteJobById(int jobId);

  @Query("select count(*) from JobQueue")
  Future<int?> countJob();

  @Query("delete from JobQueue")
  Future<void> clean();
}
