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
        NEXT_DAY( sd + rn, '�����������' )
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