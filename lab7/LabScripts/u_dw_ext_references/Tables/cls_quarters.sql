ALTER SESSION SET current_schema=u_dw_ext_references;

CREATE TABLE cls_quarters(
DAYS_IN_CAL_QUARTER           NUMBER,
BEG_OF_CAL_QUARTER            DATE,
END_OF_CAL_QUARTER            DATE,
CALENDAR_QUARTER_NUMBER       VARCHAR2(1)
)
TABLESPACE TS_REFERENCES_EXT_DATA_01;

EXEC pkg_load_ext_ref_calendar.load_cls_quarters;
SELECT * FROM cls_quarters;