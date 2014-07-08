BEGIN;
CREATE TABLE country_test AS SELECT 'de'::country, 1 as num;
SELECT * FROM country_test;
UPDATE country_test SET num = 2;
SELECT * FROM country_test;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_test AS SELECT 'ios'::os_name, 1 as num;
SELECT * FROM os_name_test;
UPDATE os_name_test SET num = 2;
SELECT * FROM os_name_test;
ROLLBACK;

BEGIN;
CREATE TABLE device_type_test AS SELECT 'phone'::device_type, 1 as num;
SELECT * FROM device_type_test;
UPDATE device_type_test SET num = 2;
SELECT * FROM device_type_test;
ROLLBACK;
