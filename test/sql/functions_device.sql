SELECT exist('phone=>1'::device_istore, 'phone');
SELECT exist('phone=>1'::device_istore, 'tablet');
SELECT exist('phone=>1, bot=>0'::device_istore, 'bot');
SELECT exist('phone=>1, bot=>0'::device_istore, 'kermit');

SELECT fetchval('phone=>1'::device_istore, 'phone');
SELECT fetchval('resolver=>1'::device_istore, 'phone');
SELECT fetchval('phone=>1, phone=>1'::device_istore, 'tablet');
SELECT fetchval('phone=>1, phone=>1'::device_istore, 'phone');

SELECT add('phone=>1, resolver=>1'::device_istore, 'phone=>1, resolver=>1'::device_istore);
SELECT add('phone=>1, resolver=>1'::device_istore, 'bot=>1, resolver=>1'::device_istore);
SELECT add('phone=>1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT add('bot=>1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT add('bot=>-1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT add('bot=>-1, resolver=>1'::device_istore, 1);
SELECT add('bot=>-1, resolver=>1'::device_istore, -1);
SELECT add('bot=>-1, resolver=>1'::device_istore, 0);

SELECT subtract('phone=>1, resolver=>1'::device_istore, 'phone=>1, resolver=>1'::device_istore);
SELECT subtract('phone=>1, resolver=>1'::device_istore, 'bot=>1, resolver=>1'::device_istore);
SELECT subtract('phone=>1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT subtract('bot=>1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT subtract('bot=>-1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT subtract('bot=>-1, resolver=>1'::device_istore, 1);
SELECT subtract('bot=>-1, resolver=>1'::device_istore, -1);
SELECT subtract('bot=>-1, resolver=>1'::device_istore, 0);

SELECT multiply('phone=>1, resolver=>1'::device_istore, 'phone=>1, resolver=>1'::device_istore);
SELECT multiply('phone=>1, resolver=>1'::device_istore, 'bot=>1, resolver=>1'::device_istore);
SELECT multiply('phone=>1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT multiply('bot=>1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT multiply('bot=>-1, resolver=>1'::device_istore, 'bot=>-1, resolver=>1'::device_istore);
SELECT multiply('bot=>-1, resolver=>1'::device_istore, 1);
SELECT multiply('bot=>-1, resolver=>1'::device_istore, -1);
SELECT multiply('bot=>-1, resolver=>1'::device_istore, 0);

SELECT device_istore_from_array(ARRAY['bot']);
SELECT device_istore_from_array(ARRAY['bot','bot','bot','bot']);
SELECT device_istore_from_array(NULL::text[]);
SELECT device_istore_from_array(ARRAY['bot','phone','resolver','mac']);
SELECT device_istore_from_array(ARRAY['bot','phone','resolver','mac','bot','phone','resolver','mac']);
SELECT device_istore_from_array(ARRAY['bot','phone','resolver','mac','bot','phone','resolver','mac',NULL]);
SELECT device_istore_from_array(ARRAY[NULL,'bot','phone','resolver','mac','bot','phone','resolver','mac']);
SELECT device_istore_from_array(ARRAY[NULL,'bot','phone','resolver','mac','bot','phone','resolver','mac',NULL]);
SELECT device_istore_from_array(ARRAY['bot','phone','resolver','mac','bot','phone','resolver','mac',NULL,'bot',NULL,'bot','phone','resolver','mac','bot','phone','resolver','mac']);

SELECT device_istore_from_array(ARRAY['bot'::device_type]);
SELECT device_istore_from_array(ARRAY['bot'::device_type,'bot'::device_type,'bot'::device_type,'bot'::device_type]);
SELECT device_istore_from_array(NULL::text[]);
SELECT device_istore_from_array(ARRAY['bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type]);
SELECT device_istore_from_array(ARRAY['bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type]);
SELECT device_istore_from_array(ARRAY['bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,NULL]);
SELECT device_istore_from_array(ARRAY[NULL,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type]);
SELECT device_istore_from_array(ARRAY[NULL,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,NULL]);
SELECT device_istore_from_array(ARRAY['bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,NULL,'bot'::device_type,NULL,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'resolver'::device_type,'mac'::device_type]);


SELECT device_istore_agg(ARRAY['phone=>1']::device_istore[]);
SELECT device_istore_agg(ARRAY['phone=>1','phone=>1']::device_istore[]);
SELECT device_istore_agg(ARRAY['phone=>1,resolver=>1','phone=>1,resolver=>-1']::device_istore[]);
SELECT device_istore_agg(ARRAY['phone=>1,resolver=>1','phone=>1,resolver=>-1',NULL]::device_istore[]);
SELECT device_istore_agg(ARRAY[NULL,'phone=>1,resolver=>1','phone=>1,resolver=>-1']::device_istore[]);
SELECT device_istore_agg(ARRAY[NULL,'phone=>1,resolver=>1','phone=>1,resolver=>-1',NULL]::device_istore[]);

SELECT device_istore_sum_up('phone=>1'::device_istore);
SELECT device_istore_sum_up(NULL::device_istore);
SELECT device_istore_sum_up('phone=>1, resolver=>1'::device_istore);
SELECT device_istore_sum_up('phone=>1 ,resolver=>-1, phone=>1'::device_istore);

BEGIN;
CREATE TABLE test (a device_istore);
INSERT INTO test VALUES('phone=>1');
INSERT INTO test VALUES('resolver=>1');
INSERT INTO test VALUES('mac=>1');
SELECT SUM(a) FROM test;
ROLLBACK;

BEGIN;
CREATE TABLE test (a device_istore);
INSERT INTO test VALUES('phone=>1');
INSERT INTO test VALUES('resolver=>1');
INSERT INTO test VALUES('mac=>1');
INSERT INTO test VALUES(NULL);
INSERT INTO test VALUES('mac=>3');
SELECT SUM(a) FROM test;
ROLLBACK;

