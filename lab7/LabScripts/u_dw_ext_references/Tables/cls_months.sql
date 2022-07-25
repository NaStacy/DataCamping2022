alter session set current_schema=u_dw_ext_references;

Create table cls_months (
CALENDAR_MONTH_NUMBER         VARCHAR2(2)  ,
DAYS_IN_CAL_MONTH             VARCHAR2(2)  ,
END_OF_CAL_MONTH              DATE         ,
CALENDAR_MONTH_NAME           VARCHAR2(32)   
)
TABLESPACE TS_REFERENCES_EXT_DATA_01;

EXEC pkg_load_ext_ref_calendar.load_cls_months;
SELECT * FROM cls_months;