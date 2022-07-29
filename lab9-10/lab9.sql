-----------------------RANGE PARTITIONING-----------------------------
CREATE TABLE range_example
   ( range_key_column           date         NOT NULL,
data varchar2(20))
PARTITION BY RANGE (range_key_column)
( 
   PARTITION part_1 VALUES LESS THAN (to_date('01/01/2020','dd/mm/yyyy')),
   PARTITION part_2 VALUES LESS THAN (to_date('01/01/2021','dd/mm/yyyy'))
);

insert into range_example (range_key_column, data)
values (to_date('15-дек-2019 00:00:00',
                'dd-mon-yyyy hh24:mi:ss'),
        'application data...');
        
insert into range_example (range_key_column, data)
values (to_date('31-дек-2019 23:59:59',
                'dd-mon-yyyy hh24:mi:ss'),
        'application data...');
        
insert into range_example (range_key_column, data)
values (to_date('01-янв-2020 00:00:00',
                'dd-mon-yyyy hh24:mi:ss'),
        'application data...');
        
insert into range_example (range_key_column, data)
values (to_date('31-дек-2020 00:00:00',
                'dd-mon-yyyy hh24:mi:ss'),
        'application data...');

select * from range_example;        
select to_char(range_key_column, 'dd-mon-yyyy hh24:mi:ss') 
from range_example partition (part_3);

--add
ALTER TABLE range_example
ADD PARTITION part_3 VALUES LESS THAN (to_date('01/01/2022','dd/mm/yyyy'));

insert into range_example (range_key_column, data)
values (to_date('31-дек-2021 00:00:00',
                'dd-mon-yyyy hh24:mi:ss'),
        'application data...');
        
commit;

--drop
ALTER TABLE range_example DROP PARTITION part_3;

--merge
ALTER TABLE range_example
ADD PARTITION quarter_one  VALUES LESS THAN (to_date('01/01/2023','dd/mm/yyyy'));

ALTER TABLE range_example
ADD PARTITION quarter_two  VALUES LESS THAN (to_date('01/01/2024','dd/mm/yyyy'));

ALTER TABLE range_example 
MERGE PARTITIONS quarter_one, quarter_two INTO PARTITION quarter_two
UPDATE INDEXES;

select to_char(range_key_column, 'dd-mon-yyyy hh24:mi:ss') 
from range_example partition (quarter_one);

--move
CREATE TABLESPACE ts094
DATAFILE '/oracle/u02/oradata/ALogachevadb/db_ts094.dat'
SIZE 20M
 AUTOEXTEND ON NEXT 10M
 SEGMENT SPACE MANAGEMENT AUTO;
 
ALTER TABLE range_example MOVE PARTITION quarter_two
     TABLESPACE ts094 NOLOGGING COMPRESS;

SELECT partition_name, tablespace_name FROM all_tab_partitions;

--split
ALTER TABLE range_example 
   SPLIT PARTITION quarter_two 
   INTO 
    ( PARTITION quarter_one VALUES LESS THAN (to_date('01/01/2023','dd/mm/yyyy')),
      PARTITION quarter_two);
      
SELECT partition_name, tablespace_name FROM all_tab_partitions;

--truncate
DELETE FROM range_example PARTITION (quarter_two);
ALTER TABLE range_example TRUNCATE PARTITION quarter_two;

-----------------------HASH PARTITIONING-----------------------------
CREATE TABLESPACE p1
DATAFILE '/oracle/u02/oradata/ALogachevadb/db_p1.dat'
SIZE 20M
 AUTOEXTEND ON NEXT 10M
 SEGMENT SPACE MANAGEMENT AUTO;
 CREATE TABLESPACE p2
DATAFILE '/oracle/u02/oradata/ALogachevadb/db_p2.dat'
SIZE 20M
 AUTOEXTEND ON NEXT 10M
 SEGMENT SPACE MANAGEMENT AUTO;
 
CREATE TABLE hash_example( hash_key_column   date,
                           data   varchar2(20)
)
PARTITION BY HASH (hash_key_column)
( 
    partition part_1 tablespace p1,
    partition part_2 tablespace p2
);

insert into hash_example (hash_key_column, data)
values (to_date('27-фев-2020'),
        'application data...');
        
insert into hash_example (hash_key_column, data)
values (to_date('25-июн-2020'),
        'application data...');

select * from hash_example;        
select to_char(hash_key_column, 'dd-mon-yyyy') 
from hash_example partition (part_1);

--add
ALTER TABLE hash_example
      ADD PARTITION part_3 TABLESPACE p2;
      
SELECT partition_name, tablespace_name FROM all_tab_partitions where table_name = 'HASH_EXAMPLE';

--coalesce
ALTER TABLE hash_example
     COALESCE PARTITION;

SELECT partition_name, tablespace_name FROM all_tab_partitions where table_name = 'HASH_EXAMPLE';

--move
ALTER TABLE hash_example MOVE PARTITION part_2
     TABLESPACE ts094;

SELECT partition_name, tablespace_name FROM all_tab_partitions where table_name = 'HASH_EXAMPLE';

--truncate
DELETE FROM hash_example PARTITION (part_1);
ALTER TABLE hash_example TRUNCATE PARTITION part_1;
      
SELECT partition_name, tablespace_name FROM all_tab_partitions where table_name = 'HASH_EXAMPLE';
      
      
-----------------------LIST PARTITIONING-----------------------------
create table list_example
    ( state_cd varchar2(2),
          data varchar2(20)
    )
partition by list(state_cd)
   ( partition part_1 values ( 'ME', 'NH', 'VT', 'MA' ),
     partition part_2 values ( 'CT', 'RI', 'NY' )
   );
   
insert into list_example (state_cd, data) values ( 'CT', 'application data...');
insert into list_example (state_cd, data) values ( 'MA', 'application data...');
insert into list_example (state_cd, data) values ( 'ME', 'application data...');
insert into list_example (state_cd, data) values ( 'NH', 'application data...');
insert into list_example (state_cd, data) values ( 'NY', 'application data...');
insert into list_example (state_cd, data) values ( 'RI', 'application data...');
insert into list_example (state_cd, data) values ( 'VT', 'application data...');

SELECT partition_name, tablespace_name, high_value FROM all_tab_partitions 
where table_name = 'LIST_EXAMPLE';

--add 
ALTER TABLE list_example 
   ADD PARTITION part_3 VALUES ('HI', 'PR')
      STORAGE (INITIAL 20K NEXT 20K) TABLESPACE p1
      NOLOGGING;
      
SELECT partition_name, tablespace_name, high_value FROM all_tab_partitions 
where table_name = 'LIST_EXAMPLE';

--drop
ALTER TABLE list_example 
   ADD PARTITION part_4 VALUES ('RE', 'PA', 'AA', 'CU')
      STORAGE (INITIAL 20K NEXT 20K) TABLESPACE p1
      NOLOGGING;

ALTER TABLE list_example DROP PARTITION part_4;

SELECT partition_name, tablespace_name, high_value FROM all_tab_partitions 
where table_name = 'LIST_EXAMPLE';

--merge
ALTER TABLE list_example 
   ADD PARTITION part_4 VALUES ('RE', 'PA', 'AA', 'CU')
      STORAGE (INITIAL 20K NEXT 20K) TABLESPACE p1
      NOLOGGING;
      
ALTER TABLE list_example 
   ADD PARTITION part_5 VALUES ('AB')
      STORAGE (INITIAL 20K NEXT 20K) TABLESPACE p1
      NOLOGGING;
      
ALTER TABLE list_example 
MERGE PARTITIONS part_4, part_5 INTO PARTITION part_4
UPDATE INDEXES;

SELECT partition_name, tablespace_name, high_value FROM all_tab_partitions 
where table_name = 'LIST_EXAMPLE';

--move
ALTER TABLE list_example MOVE PARTITION part_2
     TABLESPACE ts094;
     
SELECT partition_name, tablespace_name, high_value FROM all_tab_partitions 
where table_name = 'LIST_EXAMPLE';

--split
ALTER TABLE list_example 
   SPLIT PARTITION part_4 
   INTO 
    ( PARTITION part_5 VALUES ('AB','AA'),
      PARTITION part_4);

SELECT partition_name, tablespace_name, high_value FROM all_tab_partitions 
where table_name = 'LIST_EXAMPLE';

--truncate
DELETE FROM list_example PARTITION (part_5);
ALTER TABLE list_example TRUNCATE PARTITION part_5;

SELECT partition_name, tablespace_name, high_value FROM all_tab_partitions 
where table_name = 'LIST_EXAMPLE';

-----------------------INTERVAL PARTITIONING-----------------------------
create table audit_trail
   (   ts timestamp,
     data varchar2(30)
    )
partition by range(ts)
interval (numtoyminterval(1,'month'))
(partition p0 values less than (to_date('01-01-1900','dd-mm-yyyy')));

insert into audit_trail (ts, data)
values (to_date('01-янв-1800', 'dd-mon-yyyy'), 'application data...' );
        
insert into audit_trail (ts, data)
values (to_date('01-янв-1820', 'dd-mon-yyyy'), 'application data...');
        
insert into audit_trail (ts, data)
values (to_date('01-янв-1940', 'dd-mon-yyyy'), 'application data...');
        
insert into audit_trail (ts, data)
values (to_date('01-янв-1960', 'dd-mon-yyyy'), 'application data...');

commit;

SELECT partition_name, tablespace_name, high_value, decode (interval, 'YES', interval) 
interval FROM all_tab_partitions where table_name = 'AUDIT_TRAIL';

select * from audit_trail;        
select to_char(ts, 'dd-mon-yyyy') 
from audit_trail partition (p0);

--add
ALTER TABLE audit_trail
ADD PARTITION p1 values less than (to_date('01-01-1980','dd-mm-yyyy')));

insert into audit_trail (ts, data)
values (to_date('31-дек-1979', 'dd-mon-yyyy'),
        'application data...');
        
commit;

SELECT partition_name, tablespace_name, high_value, decode (interval, 'YES', interval) 
interval FROM all_tab_partitions where table_name = 'AUDIT_TRAIL';

--drop
ALTER TABLE AUDIT_TRAIL DROP PARTITION SYS_P1004;

commit;

SELECT partition_name, tablespace_name, high_value, decode (interval, 'YES', interval) 
interval FROM all_tab_partitions where table_name = 'AUDIT_TRAIL';

--merge
insert into audit_trail (ts, data)
values (to_date('31-янв-1991', 'dd-mon-yyyy'),
        'application data...');
        
insert into audit_trail (ts, data)
values (to_date('31-дек-1990', 'dd-mon-yyyy'),
        'application data...');

ALTER TABLE audit_trail 
MERGE PARTITIONS SYS_P1006, SYS_P1007 INTO PARTITION SYS_P1007;

SELECT partition_name, tablespace_name, high_value, decode (interval, 'YES', interval) 
interval FROM all_tab_partitions where table_name = 'AUDIT_TRAIL';

--move
ALTER TABLE audit_trail MOVE PARTITION SYS_P1007
     TABLESPACE ts094 NOLOGGING COMPRESS;

SELECT partition_name, tablespace_name, high_value, decode (interval, 'YES', interval) 
interval FROM all_tab_partitions where table_name = 'AUDIT_TRAIL';

--split
ALTER TABLE audit_trail 
   SPLIT PARTITION SYS_P1007 
   INTO 
    ( PARTITION SYS_P1006 VALUES LESS THAN (to_date('31-дек-1990', 'dd-mon-yyyy')),
      PARTITION SYS_P1007);
      
SELECT partition_name, tablespace_name, high_value, decode (interval, 'YES', interval) 
interval FROM all_tab_partitions where table_name = 'AUDIT_TRAIL';

--truncate
DELETE FROM audit_trail PARTITION (SYS_P1007);
ALTER TABLE audit_trail TRUNCATE PARTITION SYS_P1007;

commit;

SELECT partition_name, tablespace_name, high_value, decode (interval, 'YES', interval) 
interval FROM all_tab_partitions where table_name = 'AUDIT_TRAIL';


-----------------------REFERENCE PARTITIONING-----------------------------
create table orders
  (
    order#          number primary key,
    order_date      date,
    data            varchar2(30)
  )
   enable row movement
 PARTITION BY RANGE (order_date)
  (
    PARTITION part_2009 VALUES LESS THAN (to_date('01-01-2010','dd-mm-yyyy')) ,
    PARTITION part_2010 VALUES LESS THAN (to_date('01-01-2011','dd-mm-yyyy'))
  );
/

insert into orders values (1, to_date('01-01-2009','dd-mm-yyyy'), 'application data...');
insert into orders values (2, to_date('01-06-2010','dd-mm-yyyy'), 'application data...');

commit;

SELECT partition_name, tablespace_name, high_value 
interval FROM all_tab_partitions where table_name = 'ORDERS';

create table order_line_items
  (
    order#     number,
    line#      number,
    order_date date, -- manually copied from ORDERS!
    data varchar2(30),
    constraint c1_pk primary key(order#, line#),
    constraint c1_fk_p foreign key(order#) references orders
  )
   enable row movement
   PARTITION BY RANGE (order_date)
   (
     PARTITION part_2009 VALUES LESS THAN (to_date('01-01-2010','dd-mm-yyyy')) ,
     PARTITION part_2010 VALUES LESS THAN (to_date('01-01-2011','dd-mm-yyyy'))
   );
/

insert into order_line_items values (1, 1, to_date('01-01-2009','dd-mm-yyyy'), 'application data...');
insert into order_line_items values (2, 1,  to_date('01-06-2010','dd-mm-yyyy'), 'application data...');

SELECT partition_name, tablespace_name, table_name FROM all_tab_partitions 
where table_name in ('ORDER_LINE_ITEMS', 'ORDERS') ;

--move
ALTER TABLE orders MOVE PARTITION part_2010
     TABLESPACE ts094;

SELECT partition_name, tablespace_name, table_name FROM all_tab_partitions 
where table_name in ('ORDER_LINE_ITEMS', 'ORDERS') ;

--trancate
DELETE FROM ORDER_LINE_ITEMS PARTITION (PART_2009);
ALTER TABLE ORDER_LINE_ITEMS TRUNCATE PARTITION PART_2009 CASCADE;