SELECT exist('de=>1'::country_istore, 'de');
SELECT exist('de=>1'::country_istore, 'es');
SELECT exist('de=>1, es=>0'::country_istore, 'uk');
SELECT exist('de=>1, es=>0'::country_istore, 'es');

SELECT fetchval('de=>1'::country_istore, 'de');
SELECT fetchval('us=>1'::country_istore, 'uk');
SELECT fetchval('de=>1, de=>1'::country_istore, 'uk');
SELECT fetchval('de=>1, de=>1'::country_istore, 'de');

SELECT add('de=>1, us=>1'::country_istore, 'de=>1, us=>1'::country_istore);
SELECT add('de=>1, us=>1'::country_istore, 'es=>1, us=>1'::country_istore);
SELECT add('de=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT add('es=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT add('es=>-1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT add('es=>-1, us=>1'::country_istore, 1);
SELECT add('es=>-1, us=>1'::country_istore, -1);
SELECT add('es=>-1, us=>1'::country_istore, 0);

SELECT subtract('de=>1, us=>1'::country_istore, 'de=>1, us=>1'::country_istore);
SELECT subtract('de=>1, us=>1'::country_istore, 'es=>1, us=>1'::country_istore);
SELECT subtract('de=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT subtract('es=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT subtract('es=>-1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT subtract('es=>-1, us=>1'::country_istore, 1);
SELECT subtract('es=>-1, us=>1'::country_istore, -1);
SELECT subtract('es=>-1, us=>1'::country_istore, 0);

SELECT multiply('de=>1, us=>1'::country_istore, 'de=>1, us=>1'::country_istore);
SELECT multiply('de=>1, us=>1'::country_istore, 'es=>1, us=>1'::country_istore);
SELECT multiply('de=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT multiply('es=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT multiply('es=>-1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);
SELECT multiply('es=>-1, us=>1'::country_istore, 1);
SELECT multiply('es=>-1, us=>1'::country_istore, -1);
SELECT multiply('es=>-1, us=>1'::country_istore, 0);

SELECT country_istore_from_array(ARRAY['de']);
SELECT country_istore_from_array(ARRAY['de','de','de','de']);
SELECT country_istore_from_array(NULL::text[]);
SELECT country_istore_from_array(ARRAY['de','es','io','us']);
SELECT country_istore_from_array(ARRAY['de','es','io','us','de','es','io','us']);
SELECT country_istore_from_array(ARRAY['de','es','io','us','de','es','io','us',NULL]);
SELECT country_istore_from_array(ARRAY[NULL,'de','es','io','us','de','es','io','us']);
SELECT country_istore_from_array(ARRAY[NULL,'de','es','io','us','de','es','io','us',NULL]);
SELECT country_istore_from_array(ARRAY['de','es','io','us','de','es','io','us',NULL,'de',NULL,'de','es','io','us','de','es','io','us']);

SELECT country_istore_agg(ARRAY['de=>1']::country_istore[]);
SELECT country_istore_agg(ARRAY['de=>1','de=>1']::country_istore[]);
SELECT country_istore_agg(ARRAY['de=>1,us=>1','de=>1,us=>-1']::country_istore[]);
SELECT country_istore_agg(ARRAY['de=>1,us=>1','de=>1,us=>-1',NULL]::country_istore[]);
SELECT country_istore_agg(ARRAY[NULL,'de=>1,us=>1','de=>1,us=>-1']::country_istore[]);
SELECT country_istore_agg(ARRAY[NULL,'de=>1,us=>1','de=>1,us=>-1',NULL]::country_istore[]);

SELECT country_istore_sum_up('de=>1'::country_istore);
SELECT country_istore_sum_up(NULL::country_istore);
SELECT country_istore_sum_up('de=>1, us=>1'::country_istore);
SELECT country_istore_sum_up('de=>1 ,us=>-1, de=>1'::country_istore);

BEGIN;
CREATE TABLE test (a country_istore);
INSERT INTO test VALUES('de=>1');
INSERT INTO test VALUES('us=>1');
INSERT INTO test VALUES('io=>1');
SELECT SUM(a) FROM test;
ROLLBACK;

BEGIN;
CREATE TABLE test (a country_istore);
INSERT INTO test VALUES('de=>1');
INSERT INTO test VALUES('us=>1');
INSERT INTO test VALUES('io=>1');
INSERT INTO test VALUES(NULL);
INSERT INTO test VALUES('io=>3');
SELECT SUM(a) FROM test;
ROLLBACK;

