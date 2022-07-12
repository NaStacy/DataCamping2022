create tablespace tbs_lab datafile 'db_lab_002.dat' size 5M autoextend ON next 5M MAXSIZE 100M; 
GRANT UNLIMITED TABLESPACE TO ALogacheva;
create table t
    (a int,
     b varchar2 (4000) default rpad ('*',4000,'*'),
     c varchar2 (3000) default rpad ('*',3000,'*')
     )
     /
 insert into t (a) values (1);
 insert into t (a) values (2);
 insert into t (a) values (3);
 commit;
 delete from t where a=2;
 commit;
 insert into t (a) values (4);
 commit;
 select a from t
 /
drop table t;

/*task 2.2*/
create table t
    (x int primary key,
     y clob,
     z blob)
SEGMENT CREATION IMMEDIATE 
/
select DBMS_METADATA.GET_DDL('TABLE','T') from dual;
drop table t;

/*task 3*/
create table emp as 
select
 object_id empno,
 object_name ename,
 created hiredate,
 owner job from all_objects
 /
 alter table emp add constraint emp_pk primary key (empno);
 select * from emp;
 begin
   dbms_stats.gather_table_stats(user, 'emp', cascade=> true);
 end; 
 create table heap_addresses 
    (
     empno REFERENCES emp(empno) ON DELETE CASCADE,
     addr_type VARCHAR2(10),
     street VARCHAR2(20),
     city VARCHAR2(20),
     state VARCHAR2(2),
     zip NUMBER,
     primary key (empno, addr_type)
     )
/

create table iot_addresses 
(
    empno REFERENCES emp(empno) ON DELETE CASCADE,
    addr_type VARCHAR2(10),
    street VARCHAR(20),
    city VARCHAR (20),
    state VARCHAR (20),
    zip NUMBER ,
    primary key (empno, addr_type)
    )
    ORGANIZATION INDEX
/

insert into heap_addresses 
select empno, 'WORK', '123 main street' , 'Washington', 'DC', 20123 from emp;

insert into iot_addresses 
select empno, 'WORK', '123 main street' , 'Washington', 'DC', 20123 from emp;

insert into heap_addresses 
select empno, 'home', '123 main street' , 'Washington', 'DC', 20123 from emp;
insert into iot_addresses 
select empno, 'home', '123 main street' , 'Washington', 'DC', 20123 from emp;

INSERT INTO heap_addresses 
SELECT empno, 'PREV' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 
INSERT INTO iot_addresses 
SELECT empno, 'PREV' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 
INSERT INTO heap_addresses 
SELECT empno, 'SCHOOL' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 
INSERT INTO iot_addresses 
SELECT empno, 'SCHOOL' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 
Commit;
exec dbms_stats.gather_table_stats( user, 'HEAP_ADDRESSES' ); 
exec dbms_stats.gather_table_stats( user, 'IOT_ADDRESSES' );

SELECT * 
   FROM emp , 
        heap_addresses 
  WHERE emp.empno = heap_addresses.empno 
  AND emp.empno   = 42; 
SELECT * 
   FROM emp , 
        iot_addresses 
  WHERE emp.empno = iot_addresses.empno 
  AND emp.empno = 42;
  
drop table emp;
drop table heap_addresses;
drop table iot_addresses;