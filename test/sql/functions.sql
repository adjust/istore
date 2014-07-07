SELECT exist('1=>1'::istore, 1);
SELECT exist('1=>1'::istore, 2);
SELECT exist('1=>1, -1=>0'::istore, 2);
SELECT exist('1=>1, -1=>0', -1);

SELECT fetchval('1=>1'::istore, 1);
SELECT fetchval('2=>1'::istore, 1);
SELECT fetchval('1=>1, 1=>1'::istore, 1);
SELECT fetchval('1=>1, 1=>1'::istore, 2);

SELECT add('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore);
SELECT add('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore);
SELECT add('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT add('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT add('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT add('-1=>-1, 2=>1'::istore, 1);
SELECT add('-1=>-1, 2=>1'::istore, -1);
SELECT add('-1=>-1, 2=>1'::istore, 0);

SELECT subtract('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore);
SELECT subtract('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore);
SELECT subtract('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT subtract('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT subtract('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT subtract('-1=>-1, 2=>1'::istore, 1);
SELECT subtract('-1=>-1, 2=>1'::istore, -1);
SELECT subtract('-1=>-1, 2=>1'::istore, 0);

SELECT multiply('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore);
SELECT multiply('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore);
SELECT multiply('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT multiply('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT multiply('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT multiply('-1=>-1, 2=>1'::istore, 1);
SELECT multiply('-1=>-1, 2=>1'::istore, -1);
SELECT multiply('-1=>-1, 2=>1'::istore, 0);

SELECT istore_from_array(ARRAY[1]);
SELECT istore_from_array(ARRAY[1,1,1,1]);
SELECT istore_from_array(NULL);
SELECT istore_from_array(ARRAY[1,2,3,4]);
SELECT istore_from_array(ARRAY[1,2,3,4,1,2,3,4]);
SELECT istore_from_array(ARRAY[1,2,3,4,1,2,3,NULL]);
SELECT istore_from_array(ARRAY[NULL,2,3,4,1,2,3,4]);
SELECT istore_from_array(ARRAY[NULL,2,3,4,1,2,3,NULL]);
SELECT istore_from_array(ARRAY[1,2,3,NULL,1,NULL,3,4,1,2,3]);

SELECT istore_agg(ARRAY['1=>1']::istore[]);
SELECT istore_agg(ARRAY['1=>1','1=>1']::istore[]);
SELECT istore_agg(ARRAY['1=>1,2=>1','1=>1,2=>-1']::istore[]);
SELECT istore_agg(ARRAY['1=>1,2=>1','1=>1,2=>-1',NULL]::istore[]);
SELECT istore_agg(ARRAY[NULL,'1=>1,2=>1','1=>1,2=>-1']::istore[]);
SELECT istore_agg(ARRAY[NULL,'1=>1,2=>1','1=>1,2=>-1',NULL]::istore[]);

SELECT istore_sum_up('1=>1'::istore);
SELECT istore_sum_up(NULL::istore);
SELECT istore_sum_up('1=>1, 2=>1'::istore);
SELECT istore_sum_up('1=>1 ,2=>-1, 1=>1'::istore);

BEGIN;
CREATE TABLE test (a istore);
INSERT INTO test VALUES('1=>1');
INSERT INTO test VALUES('2=>1');
INSERT INTO test VALUES('3=>1');
SELECT SUM(a) FROM test;
ROLLBACK;

BEGIN;
CREATE TABLE test (a istore);
INSERT INTO test VALUES('1=>1');
INSERT INTO test VALUES('2=>1');
INSERT INTO test VALUES('3=>1');
INSERT INTO test VALUES(NULL);
INSERT INTO test VALUES('3=>3');
SELECT SUM(a) FROM test;
ROLLBACK;
