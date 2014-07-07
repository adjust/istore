SET DATESTYLE TO ISO;
SELECT '2014-06-12 16:31:40'::aj_time::date;
SELECT '2014-06-12 16:31:40'::aj_time::timestamp;
SELECT '2014-06-12 16:31:40'::timestamp::aj_time;
SELECT '2014-06-12'::aj_date::date;
SELECT '2014-06-12'::date::aj_date;
SELECT date('2014-06-12 16:31:40'::aj_time);