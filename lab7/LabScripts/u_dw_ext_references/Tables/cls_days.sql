CREATE TABLE cls_days(     
DAY_NAME                      VARCHAR2(44) ,
DAY_NUMBER_IN_WEEK            VARCHAR2(1)  ,
DAY_NUMBER_IN_MONTH           VARCHAR2(2)  ,
DAY_NUMBER_IN_YEAR            VARCHAR2(3)  
)
TABLESPACE TS_REFERENCES_EXT_DATA_01;

EXEC pkg_load_ext_ref_calendar.load_cls_days;
SELECT * FROM cls_days;