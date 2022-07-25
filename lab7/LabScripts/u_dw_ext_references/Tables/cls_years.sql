CREATE TABLE cls_years
(
    DAYS_IN_CAL_YEAR NUMBER,     
    BEG_OF_CAL_YEAR DATE,      
    END_OF_CAL_YEAR DATE,
    CALENDAR_YEAR VARCHAR2(4)
)
TABLESPACE TS_REFERENCES_EXT_DATA_01;

EXEC pkg_load_ext_ref_calendar.load_cls_years;
SELECT * FROM cls_years;