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