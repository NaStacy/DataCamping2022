-----------------1 calendar ------------------
ALTER SESSION SET current_schema=u_dw_ext_references;
SELECT 
  TRUNC( sd + rn ) time_id,
  TO_CHAR( sd + rn, 'fmDay' ) day_name,
  TO_CHAR( sd + rn, 'D' ) day_number_in_week,
  TO_CHAR( sd + rn, 'DD' ) day_number_in_month,
  TO_CHAR( sd + rn, 'DDD' ) day_number_in_year,
  TO_CHAR( sd + rn, 'W' ) calendar_week_number,
  ( CASE
      WHEN TO_CHAR( sd + rn, 'D' ) IN ( 1, 2, 3, 4, 5, 6 ) THEN
        NEXT_DAY( sd + rn, '—”¡¡Œ“¿' )
      ELSE
        ( sd + rn )
    END ) week_ending_date,
  TO_CHAR( sd + rn, 'MM' ) calendar_month_number,
  TO_CHAR( LAST_DAY( sd + rn ), 'DD' ) days_in_cal_month,
  LAST_DAY( sd + rn ) end_of_cal_month,
  TO_CHAR( sd + rn, 'FMMonth' ) calendar_month_name,
  ( ( CASE
      WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
        TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
        TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
        TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
        TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    END ) - TRUNC( sd + rn, 'Q' ) + 1 ) days_in_cal_quarter,
  TRUNC( sd + rn, 'Q' ) beg_of_cal_quarter,
  ( CASE
      WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
        TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
        TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
        TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
        TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    END ) end_of_cal_quarter,
  TO_CHAR( sd + rn, 'Q' ) calendar_quarter_number,
  TO_CHAR( sd + rn, 'YYYY' ) calendar_year,
  ( TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    - TRUNC( sd + rn, 'YEAR' ) ) days_in_cal_year,
  TRUNC( sd + rn, 'YEAR' ) beg_of_cal_year,
  TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' ) end_of_cal_year
FROM
  ( 
    SELECT 
      TO_DATE( '12/31/2021', 'MM/DD/YYYY' ) sd,
      rownum rn
    FROM dual
      CONNECT BY level <= 300
  );

  ----------------- 2 t_ext_calendar ---------------------
  --  DROP TABLE u_dw_ext_references.t_ext_calendar;

ALTER SESSION SET current_schema=u_dw_ext_references;

CREATE TABLE t_ext_calendar (
TIME_ID                       DATE  ,       
DAY_NAME                      VARCHAR2(44) ,
DAY_NUMBER_IN_WEEK            VARCHAR2(1)  ,
DAY_NUMBER_IN_MONTH           VARCHAR2(2)  ,
DAY_NUMBER_IN_YEAR            VARCHAR2(3)  ,
CALENDAR_WEEK_NUMBER          VARCHAR2(1)  ,
WEEK_ENDING_DATE              DATE         ,
CALENDAR_MONTH_NUMBER         VARCHAR2(2)  ,
DAYS_IN_CAL_MONTH             VARCHAR2(2)  ,
END_OF_CAL_MONTH              DATE         ,
CALENDAR_MONTH_NAME           VARCHAR2(32) ,
DAYS_IN_CAL_QUARTER           NUMBER       ,
BEG_OF_CAL_QUARTER            DATE         ,
END_OF_CAL_QUARTER            DATE         ,
CALENDAR_QUARTER_NUMBER       VARCHAR2(1) , 
CALENDAR_YEAR                 VARCHAR2(4),  
DAYS_IN_CAL_YEAR              NUMBER  ,     
BEG_OF_CAL_YEAR               DATE   ,      
END_OF_CAL_YEAR               DATE         
);


  ----------------- 3 cls_days ---------------------
--drop table cls_days;
  ALTER SESSION SET current_schema=u_dw_ext_references;
CREATE TABLE cls_days(     
DAY_NAME                      VARCHAR2(44) ,
DAY_NUMBER_IN_WEEK            VARCHAR2(1)  ,
DAY_NUMBER_IN_MONTH           VARCHAR2(2)  ,
DAY_NUMBER_IN_YEAR            VARCHAR2(3)  
)
TABLESPACE TS_REFERENCES_EXT_DATA_01;

  ----------------- 4 cls_weeks --------------------- 
--drop table u_dw_ext_references.cls_weeks
  
ALTER SESSION SET current_schema=u_dw_ext_references;
CREATE TABLE cls_weeks (
CALENDAR_WEEK_NUMBER          VARCHAR2(1)  ,
WEEK_ENDING_DATE              DATE        
) 
TABLESPACE TS_REFERENCES_EXT_DATA_01;

select * from cls_weeks;

  ----------------- 5 cls_quarters --------------------- 
ALTER SESSION SET current_schema=u_dw_ext_references;
--drop table u_dw_ext_references.cls_quarters;

CREATE TABLE cls_quarters(
DAYS_IN_CAL_QUARTER           NUMBER,
BEG_OF_CAL_QUARTER            DATE,
END_OF_CAL_QUARTER            DATE,
CALENDAR_QUARTER_NUMBER       VARCHAR2(1)
)
TABLESPACE TS_REFERENCES_EXT_DATA_01;

  ----------------- 12 cls_months --------------------- 
  --drop table u_dw_ext_references.cls_months
alter session set current_schema=u_dw_ext_references;

Create table cls_months (
CALENDAR_MONTH_NUMBER         VARCHAR2(2)  ,
DAYS_IN_CAL_MONTH             VARCHAR2(2)  ,
END_OF_CAL_MONTH              DATE         ,
CALENDAR_MONTH_NAME           VARCHAR2(32)   
)
TABLESPACE TS_REFERENCES_EXT_DATA_01;

  ----------------- 6 cls_years --------------------- 
--drop table u_dw_ext_references.cls_years;
alter session set current_schema=u_dw_ext_references;
CREATE TABLE cls_years
(
    DAYS_IN_CAL_YEAR NUMBER,     
    BEG_OF_CAL_YEAR DATE,      
    END_OF_CAL_YEAR DATE,
    CALENDAR_YEAR VARCHAR2(4)
)
TABLESPACE TS_REFERENCES_EXT_DATA_01;

 ----------------- 7 package-def ------------------------
 ALTER SESSION SET current_schema=u_dw_ext_references;
  CREATE OR REPLACE PACKAGE pkg_load_ext_ref_calendar
-- Package Reload Data From External Sources to DataBase
--
AS
   -- Extract Data from external source = External Table
   PROCEDURE load_ref_calendar;
   PROCEDURE load_cls_days;
   PROCEDURE load_cls_weeks;
   PROCEDURE load_cls_months;
   PROCEDURE load_cls_quarters;
   PROCEDURE load_cls_years;
END;
/  
------------------- 8 paskage-impl -----------------------
ALTER SESSION SET current_schema=u_dw_ext_references;

CREATE OR REPLACE PACKAGE BODY pkg_load_ext_ref_calendar
-- Package Reload Data From External Sources to DataBase
--
AS
   -- Extract Data from external source = External Table
   PROCEDURE load_ref_calendar
   AS
   BEGIN

      EXECUTE IMMEDIATE 'TRUNCATE TABLE t_ext_calendar';


      --Extract data
      INSERT INTO t_ext_calendar ( time_id,
  day_name,
  day_number_in_week,
  day_number_in_month,
  day_number_in_year,
  calendar_week_number,
  
  
  week_ending_date,
  calendar_month_number,
  days_in_cal_month,
  end_of_cal_month,
  calendar_month_name,
  
  days_in_cal_quarter,
  beg_of_cal_quarter,
  
  
  end_of_cal_quarter,
  calendar_quarter_number,
  calendar_year,
  days_in_cal_year,
  beg_of_cal_year,
  end_of_cal_year )
         SELECT * FROM 
  (SELECT 
  TRUNC( sd + rn ) time_id,
  TO_CHAR( sd + rn, 'fmDay' ) day_name,
  TO_CHAR( sd + rn, 'D' ) day_number_in_week,
  TO_CHAR( sd + rn, 'DD' ) day_number_in_month,
  TO_CHAR( sd + rn, 'DDD' ) day_number_in_year,
  TO_CHAR( sd + rn, 'W' ) calendar_week_number,
  ( CASE
      WHEN TO_CHAR( sd + rn, 'D' ) IN ( 1, 2, 3, 4, 5, 6 ) THEN
        NEXT_DAY( sd + rn, 'œŒÕ≈ƒ≈À‹Õ» ' )
      ELSE
        ( sd + rn )
    END ) week_ending_date,
  TO_CHAR( sd + rn, 'MM' ) calendar_month_number,
  TO_CHAR( LAST_DAY( sd + rn ), 'DD' ) days_in_cal_month,
  LAST_DAY( sd + rn ) end_of_cal_month,
  TO_CHAR( sd + rn, 'FMMonth' ) calendar_month_name,
  ( ( CASE
      WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
        TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
        TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
        TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
        TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    END ) - TRUNC( sd + rn, 'Q' ) + 1 ) days_in_cal_quarter,
  TRUNC( sd + rn, 'Q' ) beg_of_cal_quarter,
  ( CASE
      WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
        TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
        TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
        TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
        TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    END ) end_of_cal_quarter,
  TO_CHAR( sd + rn, 'Q' ) calendar_quarter_number,
  TO_CHAR( sd + rn, 'YYYY' ) calendar_year,
  ( TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    - TRUNC( sd + rn, 'YEAR' ) ) days_in_cal_year,
  TRUNC( sd + rn, 'YEAR' ) beg_of_cal_year,
  TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' ) end_of_cal_year
FROM
  ( 
    SELECT 
      TO_DATE( '12/31/2021', 'MM/DD/YYYY' ) sd,
      rownum rn
    FROM dual
      CONNECT BY level <= 200
  )
  )
;
      --Commit Data
      COMMIT;
   END load_ref_calendar;
   
    PROCEDURE load_cls_quarters
     AS
     BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE cls_quarters';
      INSERT INTO cls_quarters (days_in_cal_quarter, beg_of_cal_quarter, end_of_cal_quarter, calendar_quarter_number )
      SELECT days_in_cal_quarter, beg_of_cal_quarter, end_of_cal_quarter, calendar_quarter_number 
      FROM t_ext_calendar;
      COMMIT;
   END load_cls_quarters;
   
   PROCEDURE load_cls_years
   AS
   BEGIN
   EXECUTE IMMEDIATE 'TRUNCATE TABLE cls_years';
   INSERT INTO cls_years ( DAYS_IN_CAL_YEAR, BEG_OF_CAL_YEAR, END_OF_CAL_YEAR, CALENDAR_YEAR)
   SELECT DAYS_IN_CAL_YEAR, BEG_OF_CAL_YEAR, END_OF_CAL_YEAR, CALENDAR_YEAR 
   FROM t_ext_calendar;
   COMMIT;
   END load_cls_years;
   
   PROCEDURE load_cls_days
   AS
   BEGIN 
   EXECUTE IMMEDIATE 'TRUNCATE TABLE cls_days';
   INSERT INTO cls_days ( DAY_NAME, DAY_NUMBER_IN_WEEK, DAY_NUMBER_IN_MONTH,DAY_NUMBER_IN_YEAR)    
   SELECT DAY_NAME,DAY_NUMBER_IN_WEEK,DAY_NUMBER_IN_MONTH,DAY_NUMBER_IN_YEAR
    FROM t_ext_calendar;
    COMMIT;
    END load_cls_days;
    
    
   PROCEDURE load_cls_months
   AS
   BEGIN
   EXECUTE IMMEDIATE 'TRUNCATE TABLE cls_months';
    INSERT INTO cls_months (CALENDAR_MONTH_NUMBER, DAYS_IN_CAL_MONTH, END_OF_CAL_MONTH, CALENDAR_MONTH_NAME)
    SELECT CALENDAR_MONTH_NUMBER, DAYS_IN_CAL_MONTH, END_OF_CAL_MONTH, CALENDAR_MONTH_NAME 
    FROM t_ext_calendar; 
      COMMIT;
   END load_cls_months;
   
   PROCEDURE load_cls_weeks
   AS
   BEGIN
   EXECUTE IMMEDIATE 'TRUNCATE TABLE cls_weeks';
   INSERT INTO cls_weeks ( CALENDAR_WEEK_NUMBER, WEEK_ENDING_DATE)
   SELECT CALENDAR_WEEK_NUMBER, WEEK_ENDING_DATE 
   FROM t_ext_calendar;
   COMMIT;
   END load_cls_weeks;
   
END;
/

EXEC pkg_load_ext_ref_calendar.load_ref_calendar;


EXEC pkg_load_ext_ref_calendar.load_cls_days;
EXEC pkg_load_ext_ref_calendar.load_cls_weeks;
EXEC pkg_load_ext_ref_calendar.load_cls_months;

EXEC pkg_load_ext_ref_calendar.load_cls_quarters;
EXEC pkg_load_ext_ref_calendar.load_cls_years;



select * from t_ext_calendar;


  ----------------- 9 sq_days ---------------------
--drop sequence u_dw_references.sq_day_id;  
alter session set current_schema=u_dw_ext_references;

create sequence u_dw_references.sq_day_id start with 1;

grant SELECT on u_dw_references.sq_day_id to u_dw_ext_references;

  ----------------- 10 t_days ---------------------
--creating table with id PK
--drop table u_dw_references.t_days;
--alter table u_dw_references.t_days
--  drop constraint PK_DW.T_DAY;
alter user u_dw_references quota unlimited on ts_references_idx_01;

alter session set current_schema = u_dw_references;


CREATE TABLE t_days(
DAY_ID                    NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
DAY_NAME                      VARCHAR2(44) ,
DAY_NUMBER_IN_WEEK            VARCHAR2(1)  ,
DAY_NUMBER_IN_MONTH           VARCHAR2(2)  ,
DAY_NUMBER_IN_YEAR            VARCHAR2(3),
CONSTRAINT "PK_DW.T_DAY" PRIMARY KEY ( DAY_ID ) USING INDEX TABLESPACE ts_references_idx_01
);

  ----------------- 11 t_days-init ---------------------

alter session set current_schema = u_dw_references;
INSERT INTO t_days(
DAY_NAME                    ,  
DAY_NUMBER_IN_WEEK          , 
DAY_NUMBER_IN_MONTH         ,
DAY_NUMBER_IN_YEAR          )
SELECT DAY_NAME             ,  
DAY_NUMBER_IN_WEEK          , 
DAY_NUMBER_IN_MONTH         ,
DAY_NUMBER_IN_YEAR         
FROM u_dw_ext_references.cls_days;
commit;

select * from t_days;

  ----------------- 12 w_days ---------------------
--drop view u_dw_references.w_days

alter session set current_schema = u_dw_references;
create or replace view u_dw_references.w_days as
SELECT            DAY_ID    ,                
                DAY_NAME    ,               
      DAY_NUMBER_IN_WEEK    ,     
     DAY_NUMBER_IN_MONTH    ,    
      DAY_NUMBER_IN_YEAR           
  FROM t_days;

grant DELETE,INSERT,UPDATE,SELECT on u_dw_references.w_days to u_dw_ext_references;
select * from w_days;



  ----------------- 13 sq_weeks --------------------- 
--drop sequence u_dw_references.sq_week_id;

alter session set current_schema=u_dw_references;

create sequence u_dw_references.sq_week_id start with 1;

grant SELECT on u_dw_references.sq_week_id to u_dw_ext_references;

  ----------------- 9 t_weeks ---------------------
--DROP TABLE u_dw_references.t_weeks;

alter session set current_schema=u_dw_references;
CREATE TABLE t_weeks(
WEEK_ID                    NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
CALENDAR_WEEK_NUMBER          VARCHAR2(1)  ,
WEEK_ENDING_DATE              DATE,   
CONSTRAINT "PK_DW.T_WEEK" PRIMARY KEY ( WEEK_ID ) USING INDEX TABLESPACE ts_references_idx_01
);



  ----------------- 10 t_weeks-init --------------------- 
alter session set current_schema=u_dw_references;

INSERT INTO t_weeks (
     CALENDAR_WEEK_NUMBER, 
     WEEK_ENDING_DATE
 )
  SELECT CALENDAR_WEEK_NUMBER, 
     WEEK_ENDING_DATE FROM u_dw_ext_references.cls_weeks;

COMMIT;
select * from t_weeks;
----------------- 11 w_weeks --------------------- 
--drop view u_dw_references.w_weeks;

--==============================================================
-- View: w_weeks                          
--==============================================================

create or replace view u_dw_references.w_weeks as
SELECT WEEK_ID,
    CALENDAR_WEEK_NUMBER,     
    WEEK_ENDING_DATE   
  FROM t_weeks;

grant DELETE,INSERT,UPDATE,SELECT on u_dw_references.w_weeks to u_dw_ext_references;



  ----------------- 13 sq_months --------------------- 
--drop sequence u_dw_references.sq_month_id;
alter session set current_schema=u_dw_references;

create sequence u_dw_references.sq_month_id start with 1;

grant SELECT on u_dw_references.sq_month_id to u_dw_ext_references;


  ----------------- 14 t_months --------------------- 
alter session set current_schema=u_dw_references;
--drop table u_dw_references.t_months;

Create table t_months (
MONTH_ID                      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY, 
CALENDAR_MONTH_NUMBER         VARCHAR2(2)  ,
DAYS_IN_CAL_MONTH             VARCHAR2(2)  ,
END_OF_CAL_MONTH              DATE         ,
CALENDAR_MONTH_NAME           VARCHAR2(32) ,
CONSTRAINT "PK_DW.T_MONTH" PRIMARY KEY ( MONTH_ID ) USING INDEX TABLESPACE ts_references_idx_01
);


  ----------------- 15 t_months-init --------------------- 
alter session set current_schema=u_dw_references;

INSERT INTO t_months ( 
     CALENDAR_MONTH_NUMBER,
     DAYS_IN_CAL_MONTH,
     END_OF_CAL_MONTH,
     CALENDAR_MONTH_NAME
 )
  SELECT CALENDAR_MONTH_NUMBER,
     DAYS_IN_CAL_MONTH,
     END_OF_CAL_MONTH,
     CALENDAR_MONTH_NAME FROM u_dw_ext_references.cls_months;
     
COMMIT;

select * from t_months;

  ----------------- 16 w_months --------------------- 
--drop view u_dw_references.w_months;

--==============================================================
-- View: w_months                                            
--==============================================================
alter session set current_schema=u_dw_references;

create or replace view u_dw_references.w_months as
SELECT month_id
     , calendar_month_number
     , days_in_cal_month
     , end_of_cal_month
     , calendar_month_name
  FROM t_months;

comment on column u_dw_references.w_months.month_id is
'Identifier of the Month';

comment on column u_dw_references.w_months.days_in_cal_month is
'Number of days in month';

comment on column u_dw_references.w_months.end_of_cal_month is
'Last day of month';

comment on column u_dw_references.w_months.calendar_month_name is
'Month name';



grant DELETE,INSERT,UPDATE,SELECT on u_dw_references.w_months to u_dw_ext_references;




  ----------------- 17 sq_quarters --------------------- 
--drop sequence u_dw_references.sq_quarter_id;
alter session set current_schema=u_dw_references;

create sequence u_dw_references.sq_quarter_id start with 1;

grant SELECT on u_dw_references.sq_quarter_id to u_dw_ext_references;


  ----------------- 18 t_quarters --------------------- 
alter session set current_schema=u_dw_references;
--drop table u_dw_references.t_quarters;

Create table t_quarters (
QUARTER_ID                      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY, 
DAYS_IN_CAL_QUARTER           NUMBER,
BEG_OF_CAL_QUARTER            DATE,
END_OF_CAL_QUARTER            DATE,
CALENDAR_QUARTER_NUMBER       VARCHAR2(1),
CONSTRAINT "PK_DW.T_QUARTER" PRIMARY KEY ( QUARTER_ID ) USING INDEX TABLESPACE ts_references_idx_01
);


  ----------------- 19 t_quarters-init --------------------- 
alter session set current_schema=u_dw_references;

INSERT INTO t_quarters ( 
    DAYS_IN_CAL_QUARTER,
    BEG_OF_CAL_QUARTER,
    END_OF_CAL_QUARTER,
    CALENDAR_QUARTER_NUMBER
 )
  SELECT DAYS_IN_CAL_QUARTER,
    BEG_OF_CAL_QUARTER,
    END_OF_CAL_QUARTER,
    CALENDAR_QUARTER_NUMBER FROM u_dw_ext_references.cls_quarters;
     
COMMIT;

select * from t_quarters;

  ----------------- 20 w_quarters --------------------- 
--drop view u_dw_references.w_quarters
create or replace view u_dw_references.w_quarters as
SELECT QUARTER_ID,
     DAYS_IN_CAL_QUARTER,
    BEG_OF_CAL_QUARTER,
    END_OF_CAL_QUARTER,
    CALENDAR_QUARTER_NUMBER
  FROM t_quarters;

grant DELETE,INSERT,UPDATE,SELECT on u_dw_references.w_quarters to u_dw_ext_references;


  ----------------- 21 sq_years --------------------- 
--drop sequence u_dw_references.sq_year_id;
alter session set current_schema=u_dw_references;

create sequence u_dw_references.sq_year_id start with 1;

grant SELECT on u_dw_references.sq_year_id to u_dw_ext_references;


  ----------------- 22 t_years --------------------- 
alter session set current_schema=u_dw_references;
--drop table u_dw_references.t_years;

Create table t_years (
    YEAR_ID                      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY, 
    DAYS_IN_CAL_YEAR NUMBER,     
    BEG_OF_CAL_YEAR DATE,      
    END_OF_CAL_YEAR DATE,
    CALENDAR_YEAR VARCHAR2(4),
CONSTRAINT "PK_DW.T_YEAR" PRIMARY KEY ( YEAR_ID ) USING INDEX TABLESPACE ts_references_idx_01
);


  ----------------- 23 t_years-init --------------------- 
alter session set current_schema=u_dw_references;

INSERT INTO t_years ( 
    DAYS_IN_CAL_YEAR,     
    BEG_OF_CAL_YEAR,      
    END_OF_CAL_YEAR,
    CALENDAR_YEAR
 )
  SELECT DAYS_IN_CAL_YEAR,     
    BEG_OF_CAL_YEAR,      
    END_OF_CAL_YEAR,
    CALENDAR_YEAR FROM u_dw_ext_references.cls_years;
     
COMMIT;

 ----------------- 24 w_years ------------------------
 ALTER SESSION SET current_schema=u_dw_references;
create or replace view u_dw_references.w_years as
SELECT YEAR_ID,
      DAYS_IN_CAL_YEAR,     
    BEG_OF_CAL_YEAR,      
    END_OF_CAL_YEAR,
    CALENDAR_YEAR
  FROM t_years;

grant DELETE,INSERT,UPDATE,SELECT on u_dw_references.w_years to u_dw_ext_references;


 ---------------------25---------------------------------

select * from u_dw_ext_references.cls_days;
select * from u_dw_ext_references.cls_weeks;
SELECT * FROM u_dw_ext_references.cls_months;
SELECT * FROM u_dw_ext_references.cls_quarters;
SELECT * FROM u_dw_ext_references.cls_years;

ALTER SESSION SET current_schema=u_dw_references;

SELECT * FROM t_ext_calendar;

select * from t_days;
select * from t_weeks;
SELECT * FROM t_months;
SELECT * FROM t_quarters;
SELECT * FROM t_years;

select * from w_days;
select * from w_weeks;
SELECT * FROM w_months;
SELECT * FROM w_quarters;
SELECT * FROM w_years;
