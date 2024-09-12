
```sql
mysql> select version();
+------------+
| version()  |
+------------+
| 5.7.44-log |
+------------+
1 row in set (0.00 sec)


mysql> show create table test;
+-------+--------------------------------------------------------------------------------------------+
| Table | Create Table                                                                               |
+-------+--------------------------------------------------------------------------------------------+
| test  | CREATE TABLE `test` (
  `rank` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 |
+-------+--------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)


mysql> insert into test (rank) values (3);
Query OK, 1 row affected (0.03 sec)

mysql> select * from test;
+------+
| rank |
+------+
|    1 |
|    2 |
|    3 |
+------+
3 rows in set (0.02 sec)

```

```sql
mysql> select version();
+-----------+
| version() |
+-----------+
| 8.0.28    |
+-----------+
1 row in set (0.01 sec)

mysql> show replica status\G
*************************** 1. row ***************************
             Replica_IO_State: Waiting for source to send event
                  Source_Host: mysql5.7
                  Source_User: repl
                  Source_Port: 3306
                Connect_Retry: 60
              Source_Log_File: mysql-bin.000001
          Read_Source_Log_Pos: 445
               Relay_Log_File: ef081d2b1634-relay-bin.000002
                Relay_Log_Pos: 323
        Relay_Source_Log_File: mysql-bin.000001
           Replica_IO_Running: Yes
          Replica_SQL_Running: No
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 1064
                   Last_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000001, end_log_pos 414. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
                 Skip_Counter: 0
          Exec_Source_Log_Pos: 154
              Relay_Log_Space: 831
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Source_SSL_Allowed: No
           Source_SSL_CA_File:
           Source_SSL_CA_Path:
              Source_SSL_Cert:
            Source_SSL_Cipher:
               Source_SSL_Key:
        Seconds_Behind_Source: NULL
Source_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 1064
               Last_SQL_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000001, end_log_pos 414. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
  Replicate_Ignore_Server_Ids:
             Source_Server_Id: 2
                  Source_UUID: 8632b152-5fcc-11ef-8c98-0242ac120002
             Source_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
    Replica_SQL_Running_State:
           Source_Retry_Count: 86400
                  Source_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp: 240821 15:25:36
               Source_SSL_Crl:
           Source_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Source_TLS_Version:
       Source_public_key_path:
        Get_Source_public_key: 0
            Network_Namespace:
1 row in set (0.02 sec)

mysql>  SELECT * FROM performance_schema.replication_applier_status_by_worker WHERE WORKER_ID = 1\G;
*************************** 1. row ***************************
                                           CHANNEL_NAME:
                                              WORKER_ID: 1
                                              THREAD_ID: NULL
                                          SERVICE_STATE: OFF
                                      LAST_ERROR_NUMBER: 1064
                                     LAST_ERROR_MESSAGE: Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000001, end_log_pos 414; Error 'You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'rank) values (3)' at line 1' on query. Default database: 'sample'. Query: 'insert into test (rank) values (3)'
                                   LAST_ERROR_TIMESTAMP: 2024-08-21 15:25:36.154983
                               LAST_APPLIED_TRANSACTION:
     LAST_APPLIED_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
    LAST_APPLIED_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
         LAST_APPLIED_TRANSACTION_START_APPLY_TIMESTAMP: 0000-00-00 00:00:00.000000
           LAST_APPLIED_TRANSACTION_END_APPLY_TIMESTAMP: 0000-00-00 00:00:00.000000
                                   APPLYING_TRANSACTION: ANONYMOUS
         APPLYING_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
        APPLYING_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
             APPLYING_TRANSACTION_START_APPLY_TIMESTAMP: 2024-08-21 15:25:36.150361
                 LAST_APPLIED_TRANSACTION_RETRIES_COUNT: 0
   LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_NUMBER: 0
  LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_MESSAGE:
LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
                     APPLYING_TRANSACTION_RETRIES_COUNT: 0
       APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_NUMBER: 0
      APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_MESSAGE:
    APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
1 row in set (0.03 sec)

ERROR:
No query specified
```

クオートしてinsertすると

```sql
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      445 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.01 sec)

# ここのログを開始点にするので、rank=4の行はレプリケーションされない
mysql> insert into test (`rank`) values (4);
Query OK, 1 row affected (0.02 sec)

mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      738 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.01 sec)

mysql> insert into test (`rank`) values (5);
Query OK, 1 row affected (0.02 sec)

mysql>
```

```sql
mysql> stop replica;
Query OK, 0 rows affected (0.02 sec)

mysql> CHANGE REPLICATION SOURCE TO SOURCE_LOG_POS=738;
Query OK, 0 rows affected (0.08 sec)

mysql> start replica;
Query OK, 0 rows affected (0.06 sec)

mysql> select * from test;
+------+
| rank |
+------+
|    1 |
|    2 |
|    5 |
+------+
3 rows in set (0.02 sec)

mysql> show replica status\G
*************************** 1. row ***************************
             Replica_IO_State: Waiting for source to send event
                  Source_Host: mysql5.7
                  Source_User: repl
                  Source_Port: 3306
                Connect_Retry: 60
              Source_Log_File: mysql-bin.000001
          Read_Source_Log_Pos: 1031
               Relay_Log_File: ef081d2b1634-relay-bin.000002
                Relay_Log_Pos: 616
        Relay_Source_Log_File: mysql-bin.000001
           Replica_IO_Running: Yes
          Replica_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Source_Log_Pos: 1031
              Relay_Log_Space: 833
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Source_SSL_Allowed: No
           Source_SSL_CA_File:
           Source_SSL_CA_Path:
              Source_SSL_Cert:
            Source_SSL_Cipher:
               Source_SSL_Key:
        Seconds_Behind_Source: 0
Source_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Source_Server_Id: 2
                  Source_UUID: 8632b152-5fcc-11ef-8c98-0242ac120002
             Source_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
    Replica_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Source_Retry_Count: 86400
                  Source_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Source_SSL_Crl:
           Source_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Source_TLS_Version:
       Source_public_key_path:
        Get_Source_public_key: 0
            Network_Namespace:
1 row in set (0.02 sec)

mysql>
```

うまくいった。
