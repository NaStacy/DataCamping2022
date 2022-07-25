CREATE TABLE cls_weeks (
CALENDAR_WEEK_NUMBER          VARCHAR2(1)  ,
WEEK_ENDING_DATE              DATE        
) 
TABLESPACE TS_REFERENCES_EXT_DATA_01;

EXEC pkg_load_ext_ref_calendar.load_cls_weeks;
SELECT * FROM cls_weeks;