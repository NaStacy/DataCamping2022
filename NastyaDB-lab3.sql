CREATE TABLESPACE tbs_lab
    DATAFILE 'db_lab_002.dat' SIZE 5M
    AUTOEXTEND ON NEXT 5M MAXSIZE 100M;

GRANT
    UNLIMITED TABLESPACE
TO alogacheva;

SELECT DISTINCT
    bytes / blocks
FROM
    user_segments; --check block size

--the creation of table t & insert values 1,2,3
CREATE TABLE t (
    a INT,
    b VARCHAR2(4000) DEFAULT rpad('*', 4000, '*'),
    c VARCHAR2(3000) DEFAULT rpad('*', 3000, '*')
)
/

INSERT INTO t ( a ) VALUES ( 1 );

INSERT INTO t ( a ) VALUES ( 2 );

INSERT INTO t ( a ) VALUES ( 3 );

COMMIT; --end of the tranzaction


--delete from our table content form the 2 cell & inserting one more value
DELETE FROM t
WHERE
    a = 2;

COMMIT;

INSERT INTO t ( a ) VALUES ( 4 );

COMMIT;

SELECT
    a
FROM
    t
/

DROP TABLE t;

/*task 2*/
CREATE TABLE t (
    x INT PRIMARY KEY,
    y CLOB,
    z BLOB
);

--during this selection there will be no segments
--until at least one row will be added
SELECT
    segment_name,
    segment_type
FROM
    user_segments;

DROP TABLE t;

CREATE TABLE t (
    x INT PRIMARY KEY,
    y CLOB,
    z BLOB
)
SEGMENT CREATION IMMEDIATE
/

SELECT
    segment_name,
    segment_type
FROM
    user_segments;

SELECT
    dbms_metadata.get_ddl('TABLE', 'T')
FROM
    dual;

DROP TABLE t;

/*task 3*/
--create new table emp
CREATE TABLE emp
    AS
        SELECT
            object_id   empno,
            object_name ename,
            created     hiredate,
            owner       job
        FROM
            all_objects
/
--create index
ALTER TABLE emp ADD CONSTRAINT emp_pk PRIMARY KEY ( empno );

SELECT
    *
FROM
    emp;
--statistic's output
BEGIN
    dbms_stats.gather_table_stats(user, 'emp', cascade => true);
END;
--create table heap_address
CREATE TABLE heap_addresses (
    empno
        REFERENCES emp ( empno )
            ON DELETE CASCADE,
    addr_type VARCHAR2(10),
    street    VARCHAR2(20),
    city      VARCHAR2(20),
    state     VARCHAR2(2),
    zip       NUMBER,
    PRIMARY KEY ( empno,
                  addr_type )
)
/
--create child table iot_address
CREATE TABLE iot_addresses (
    empno
        REFERENCES emp ( empno )
            ON DELETE CASCADE,
    addr_type VARCHAR2(10),
    street    VARCHAR(20),
    city      VARCHAR(20),
    state     VARCHAR(20),
    zip       NUMBER,
    PRIMARY KEY ( empno,
                  addr_type )
)
ORGANIZATION INDEX
/

INSERT INTO heap_addresses
    SELECT
        empno,
        'WORK',
        '123 main street',
        'Washington',
        'DC',
        20123
    FROM
        emp;

INSERT INTO iot_addresses
    SELECT
        empno,
        'WORK',
        '123 main street',
        'Washington',
        'DC',
        20123
    FROM
        emp;

INSERT INTO heap_addresses
    SELECT
        empno,
        'home',
        '123 main street',
        'Washington',
        'DC',
        20123
    FROM
        emp;

INSERT INTO iot_addresses
    SELECT
        empno,
        'home',
        '123 main street',
        'Washington',
        'DC',
        20123
    FROM
        emp;

INSERT INTO heap_addresses
    SELECT
        empno,
        'PREV',
        '123 main street',
        'Washington',
        'DC',
        20123
    FROM
        emp;

INSERT INTO iot_addresses
    SELECT
        empno,
        'PREV',
        '123 main street',
        'Washington',
        'DC',
        20123
    FROM
        emp;

INSERT INTO heap_addresses
    SELECT
        empno,
        'SCHOOL',
        '123 main street',
        'Washington',
        'DC',
        20123
    FROM
        emp;

INSERT INTO iot_addresses
    SELECT
        empno,
        'SCHOOL',
        '123 main street',
        'Washington',
        'DC',
        20123
    FROM
        emp;

COMMIT;

exec dbms_stats.gather_table_stats( user, 'HEAP_ADDRESSES' ); 
exec dbms_stats.gather_table_stats( user, 'IOT_ADDRESSES' );

EXPLAIN PLAN
    FOR
SELECT
    *
FROM
    emp,
    heap_addresses
WHERE
        emp.empno = heap_addresses.empno
    AND emp.empno = 42;

SELECT
    *
FROM
    TABLE ( dbms_xplan.display );

EXPLAIN PLAN
    FOR
SELECT
    *
FROM
    emp,
    iot_addresses
WHERE
        emp.empno = iot_addresses.empno
    AND emp.empno = 42;

SELECT
    *
FROM
    TABLE ( dbms_xplan.display );

DROP TABLE heap_addresses;

DROP TABLE iot_addresses;

DROP TABLE emp;

/*task 4*/
CREATE CLUSTER emp_dept_cluster ( deptno NUMBER(2) ) SIZE 1024
    STORAGE ( INITIAL 100K NEXT 50K );

CREATE INDEX idxcl_emp_dept ON CLUSTER emp_dept_cluster;

CREATE TABLE dept (
    deptno NUMBER(2) PRIMARY KEY,
    dname  VARCHAR2(14),
    loc    VARCHAR2(13)
)
CLUSTER emp_dept_cluster ( deptno );

CREATE TABLE emp (
    empno    NUMBER PRIMARY KEY,
    ename    VARCHAR2(10),
    job      VARCHAR2(9),
    mgr      NUMBER,
    hiredate DATE,
    sal      NUMBER,
    comm     NUMBER,
    deptno   NUMBER(2)
        REFERENCES dept ( deptno )
)

INSERT INTO dept (
    deptno,
    dname,
    loc
)
    SELECT
        deptno,
        dname,
        loc
    FROM
        dept;

COMMIT;

INSERT INTO emp (
    empno,
    ename,
    job,
    mgr,
    hiredate,
    sal,
    comm,
    deptno
)
    SELECT
        ROWNUM,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno
    FROM
        emp commit;

SELECT
    *
FROM
    (
        SELECT
            dept_blk,
            emp_blk,
            CASE
                WHEN dept_blk <> emp_blk THEN
                    '*'
            END flag,
            deptno
        FROM
            (
                SELECT
                    dbms_rowid.rowid_block_number(dept.rowid) dept_blk,
                    dbms_rowid.rowid_block_number(emp.rowid)  emp_blk,
                    dept.deptno
                FROM
                    emp,
                    dept
                WHERE
                    emp.deptno = dept.deptno
            )
    )
ORDER BY
    deptno;

DROP TABLE emp;

DROP TABLE dept;

DROP CLUSTER emp_dept_cluster;

DROP CLUSTER hash_cluster;