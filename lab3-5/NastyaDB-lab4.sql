/*U1M4.LW.Access and Join Methods Part 1 */
/*Task 1: Full Scans and the High-water Mark and Block reading. */
GRANT
    UNLIMITED TABLESPACE
TO alogacheva;
--create table t2
CREATE TABLE t2 AS
SELECT TRUNC ( rownum / 100 ) id, rpad( rownum,100 ) t_pad 
FROM dual 
CONNECT BY rownum < 100000; 
--create index t2_idx1
create index t2_idx1 on t2(id);
--how many blocks
select blocks from user_segments where segment_name = 'T2';
--how many blocks with data
select count (distinct(dbms_rowid.rowid_block_number(rowid))) block_ct from t2;
/*Explain Plan: */
SET autotrace ON; 
SELECT 
    COUNT(*) 
FROM t2 ;
INSERT INTO t2
  ( ID, T_PAD )
  VALUES
  (  1,'1' );
COMMIT;
TRUNCATE TABLE t2;
DELETE FROM t2;
drop table t2;

/*task 2. Index Scan types*/
/*1*/
CREATE TABLE t2 AS
SELECT TRUNC ( rownum / 100 ) id, rpad( rownum,100 ) t_pad 
FROM dual 

CONNECT BY rownum < 100000; 

create index t2_idx1 on t2(id);
/*1*/

/*2*/
CREATE TABLE t1 AS 
 SELECT MOD( rownum, 100 ) id, rpad( rownum,100 ) t_pad 
   FROM dual 
  CONNECT BY rownum < 100000;
/*2*/

/*3*/
CREATE INDEX t1_idx1 ON t1(id);
/*3*/

/*4*/
EXEC dbms_stats.gather_table_stats( USER,'t1',method_opt=>'FOR ALL COLUMNS SIZE 1',CASCADE=>TRUE ); 
EXEC dbms_stats.gather_table_stats( USER,'t2',method_opt=>'FOR ALL COLUMNS SIZE 1',CASCADE=>TRUE ); 
/*4*/

/*5 "Inner Join"*/
SELECT t.table_name||'.'||i.index_name idx_name, 
        i.clustering_factor, 
        t.blocks, 
        t.num_rows 

FROM user_indexes i, user_tables t 
WHERE i.table_name = t.table_name 
AND t.table_name  IN( 'T1','T2' );
/*5*/

drop table t1;
drop table t2;


/*task 3. Index Unique Scan*/
/*1*/
--create table t1
CREATE TABLE t1 AS 
 SELECT MOD( rownum, 100 ) id, rpad( rownum,100 ) t_pad 
   FROM dual 
  CONNECT BY rownum < 100000;
  
--create unique index
CREATE UNIQUE INDEX udx_t1 ON t1( t_pad );
/*1*/

/*2*/
SELECT t1.*  FROM t1 where t1.t_pad = '1';
/*2*/

/*task 4. Index Range Scan*/
/*1*/
CREATE TABLE t2 AS
SELECT TRUNC ( rownum / 100 ) id, rpad( rownum,100 ) t_pad 
FROM dual 

CONNECT BY rownum < 100000; 
SELECT t2.*  FROM t2 where t2.id = '1';
/*1*/

/*task 5. Index Skip Scan*/
/*1*/
CREATE TABLE emp AS
    SELECT *
      FROM emp;

CREATE TABLE employees AS
    SELECT *
      FROM emp;
/*1*/

/*2*/
CREATE INDEX idx_emp01 ON employees
      ( empno, ename, job );
/*2*/

SELECT BLOCKS FROM user_segments WHERE segment_name = 'EMP';
SELECT COUNT(DISTINCT (dbms_rowid.rowid_block_number(rowid))) block_ct FROM employees ;

SELECT emp.* FROM emp emp where ename = 'I_CON1';

/*3*/
SELECT /*+INDEX_SS(emp idx_emp01)*/ emp.* FROM employees emp where ename = 'I_CON1';
SELECT /*+FULL*/ emp.* FROM employees emp WHERE ename = 'I_CON1';
/*3*/

drop table employees;
drop table emp;