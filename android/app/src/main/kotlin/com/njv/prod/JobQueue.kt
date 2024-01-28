package com.njv.prod

import androidx.room.ColumnInfo
import androidx.room.Dao
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.PrimaryKey

@Entity(tableName = "JobQueue")
data class JobQueue(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    @ColumnInfo(name = "payload") val payload: String?,
    @ColumnInfo(name = "type") val type: Int?
)

@Dao
interface JobDao {

    @Insert
     fun insertAll(vararg jobs: JobQueue)
}