/*U1M5.LW.Access and Join Methods Part 2 */
/*Task 1*/
set autotrace off 
set autotrace on 
set autotrace traceonly 

set autotrace on explain 
set autotrace on statistics 
set autotrace on explain statistics 

set autotrace traceonly explain 
set autotrace traceonly statistics 
set autotrace traceonly explain statistics 

set autotrace off explain 
set autotrace off statistics 
set autotrace off explain statistics
/*Task 1*/

CREATE TABLE emp AS
    SELECT *
      FROM emp;

CREATE TABLE dept AS
    SELECT *
      FROM dept;
/*1*/

/*Task 2*/
SELECT /*+ ORDERED USE_NL(d) */ empno, ename, dname, loc FROM scott.emp e, scott.dept d 
    WHERE e.deptno = d.deptno AND d.deptno = 10;
/*Task 2*/

/*Task 3*/
/*Task 3*/

/*Task 4*/
/*Task 4*/

/*Task 5*/
/*Task 5*/

/*Task 6*/
/*Task 6*/

/*Task 7*/
/*Task 7*/

/*Task 8*/
/*Task 8*/

/*Task 9*/
/*Task 9*/

/*Task 10*/
/*Task 10*/