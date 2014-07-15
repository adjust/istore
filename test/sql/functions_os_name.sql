SELECT exist('ios=>1'::os_name_istore, 'ios');
SELECT exist('ios=>1'::os_name_istore, 'android');
SELECT exist('ios=>1, android=>0'::os_name_istore, 'ios');
SELECT exist('ios=>1, android=>0'::os_name_istore, 'windows');

SELECT fetchval('ios=>1'::os_name_istore, 'ios');
SELECT fetchval('windows=>1'::os_name_istore, 'ios');
SELECT fetchval('ios=>1, ios=>1'::os_name_istore, 'ios');
SELECT fetchval('ios=>1, ios=>1'::os_name_istore, 'windows');

SELECT add('ios=>1, windows=>1'::os_name_istore, 'ios=>1, windows=>1'::os_name_istore);
SELECT add('ios=>1, windows=>1'::os_name_istore, 'android=>1, windows=>1'::os_name_istore);
SELECT add('ios=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT add('android=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT add('android=>-1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT add('android=>-1, windows=>1'::os_name_istore, 1);
SELECT add('android=>-1, windows=>1'::os_name_istore, -1);
SELECT add('android=>-1, windows=>1'::os_name_istore, 0);

SELECT subtract('ios=>1, windows=>1'::os_name_istore, 'ios=>1, windows=>1'::os_name_istore);
SELECT subtract('ios=>1, windows=>1'::os_name_istore, 'android=>1, windows=>1'::os_name_istore);
SELECT subtract('ios=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT subtract('android=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT subtract('android=>-1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT subtract('android=>-1, windows=>1'::os_name_istore, 1);
SELECT subtract('android=>-1, windows=>1'::os_name_istore, -1);
SELECT subtract('android=>-1, windows=>1'::os_name_istore, 0);

SELECT multiply('ios=>1, windows=>1'::os_name_istore, 'ios=>1, windows=>1'::os_name_istore);
SELECT multiply('ios=>1, windows=>1'::os_name_istore, 'android=>1, windows=>1'::os_name_istore);
SELECT multiply('ios=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT multiply('android=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT multiply('android=>-1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore);
SELECT multiply('android=>-1, windows=>1'::os_name_istore, 1);
SELECT multiply('android=>-1, windows=>1'::os_name_istore, -1);
SELECT multiply('android=>-1, windows=>1'::os_name_istore, 0);

SELECT os_name_istore_from_array(ARRAY['android']);
SELECT os_name_istore_from_array(ARRAY['android','android','android','android']);
SELECT os_name_istore_from_array(NULL::text[]);
SELECT os_name_istore_from_array(ARRAY['android','ios','windows','windows-phone']);
SELECT os_name_istore_from_array(ARRAY['android','ios','windows','windows-phone','android','ios','windows','windows-phone']);
SELECT os_name_istore_from_array(ARRAY['android','ios','windows','windows-phone','android','ios','windows',NULL]);
SELECT os_name_istore_from_array(ARRAY[NULL,'ios','windows','windows-phone','android','ios','windows','windows-phone']);
SELECT os_name_istore_from_array(ARRAY[NULL,'ios','windows','windows-phone','android','ios','windows',NULL]);
SELECT os_name_istore_from_array(ARRAY['android','ios','windows',NULL,'android',NULL,'windows','windows-phone','android','ios','windows']);

SELECT os_name_istore_from_array(ARRAY['android'::os_name]);
SELECT os_name_istore_from_array(ARRAY['android'::os_name,'android'::os_name,'android'::os_name,'android'::os_name]);
SELECT os_name_istore_from_array(NULL::text[]);
SELECT os_name_istore_from_array(ARRAY['android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name]);
SELECT os_name_istore_from_array(ARRAY['android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name]);
SELECT os_name_istore_from_array(ARRAY['android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name,NULL]);
SELECT os_name_istore_from_array(ARRAY[NULL,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name]);
SELECT os_name_istore_from_array(ARRAY[NULL,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name,NULL]);
SELECT os_name_istore_from_array(ARRAY['android'::os_name,'ios'::os_name,'windows'::os_name,NULL,'android'::os_name,NULL,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name]);

SELECT os_name_istore_agg(ARRAY['ios=>1']::os_name_istore[]);
SELECT os_name_istore_agg(ARRAY['ios=>1','ios=>1']::os_name_istore[]);
SELECT os_name_istore_agg(ARRAY['ios=>1,windows=>1','ios=>1,windows=>-1']::os_name_istore[]);
SELECT os_name_istore_agg(ARRAY['ios=>1,windows=>1','ios=>1,windows=>-1',NULL]::os_name_istore[]);
SELECT os_name_istore_agg(ARRAY[NULL,'ios=>1,windows=>1','ios=>1,windows=>-1']::os_name_istore[]);
SELECT os_name_istore_agg(ARRAY[NULL,'ios=>1,windows=>1','ios=>1,windows=>-1',NULL]::os_name_istore[]);

SELECT os_name_istore_sum_up('ios=>1'::os_name_istore);
SELECT os_name_istore_sum_up(NULL::os_name_istore);
SELECT os_name_istore_sum_up('ios=>1, windows=>1'::os_name_istore);
SELECT os_name_istore_sum_up('ios=>1 ,windows=>-1, ios=>1'::os_name_istore);

BEGIN;
CREATE TABLE test (a os_name_istore);
INSERT INTO test VALUES('ios=>1');
INSERT INTO test VALUES('windows=>1');
INSERT INTO test VALUES('windows-phone=>1');
SELECT SUM(a) FROM test;
ROLLBACK;

BEGIN;
CREATE TABLE test (a os_name_istore);
INSERT INTO test VALUES('ios=>1');
INSERT INTO test VALUES('windows=>1');
INSERT INTO test VALUES('windows-phone=>1');
INSERT INTO test VALUES(NULL);
INSERT INTO test VALUES('windows-phone=>3');
SELECT SUM(a) FROM test;
ROLLBACK;

