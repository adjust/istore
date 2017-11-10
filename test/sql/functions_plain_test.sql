BEGIN;
-- bigistore functions should find keys with exists;
-- ./spec/istore/functions_plain_spec.rb:10;
CREATE EXTENSION istore;
SELECT exist('1=>1'::bigistore, 1);
SELECT exist('1=>1'::bigistore, 2);
SELECT exist('1=>1, -1=>0'::bigistore, 2);
SELECT exist('1=>1, -1=>0'::bigistore, -1);
ROLLBACK;
BEGIN;
-- bigistore functions should fetchvals;
-- ./spec/istore/functions_plain_spec.rb:17;
CREATE EXTENSION istore;
SELECT fetchval('1=>1'::bigistore, 1);
SELECT fetchval('2=>1'::bigistore, 1);
SELECT fetchval('1=>1, 1=>1'::bigistore, 1);
SELECT fetchval('1=>1, 1=>1'::bigistore, 2);
ROLLBACK;
BEGIN;
-- bigistore functions should return set of ints;
-- ./spec/istore/functions_plain_spec.rb:24;
CREATE EXTENSION istore;
SELECT * FROM each('1=>1'::bigistore);
SELECT * FROM each('5=>11, 4=>8'::bigistore);
SELECT * FROM each('5=>-411, 4=>8'::bigistore);
SELECT value + 100 FROM each('5=>-411, 4=>8'::bigistore);
SELECT * FROM each('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore);
SELECT * FROM each(NULL::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should compact istores;
-- ./spec/istore/functions_plain_spec.rb:49;
CREATE EXTENSION istore;
SELECT compact('0=>2, 1=>2, 3=>0 ,2=>2'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should add istores;
-- ./spec/istore/functions_plain_spec.rb:54;
CREATE EXTENSION istore;
SELECT add('1=>1, 2=>1'::bigistore, '1=>1, 2=>1'::bigistore);
SELECT add('1=>1, 2=>1'::bigistore, '-1=>1, 2=>1'::bigistore);
SELECT add('1=>1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT add('-1=>1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT add('-1=>-1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT add('-1=>-1, 2=>1'::bigistore, 1);
SELECT add('-1=>-1, 2=>1'::bigistore, -1);
SELECT add('-1=>-1, 2=>1'::bigistore, 0);
SELECT add(bigistore(Array[]::integer[], Array[]::integer[]), '1=>0'::bigistore);;
ROLLBACK;
BEGIN;
-- bigistore functions should substract istores;
-- ./spec/istore/functions_plain_spec.rb:75;
CREATE EXTENSION istore;
SELECT subtract('1=>1, 2=>1'::bigistore, '1=>1, 2=>1'::bigistore);
SELECT subtract('1=>1, 2=>1'::bigistore, '-1=>1, 2=>1'::bigistore);
SELECT subtract('1=>1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT subtract('-1=>1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT subtract('-1=>-1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT subtract('-1=>-1, 2=>1'::bigistore, 1);
SELECT subtract('-1=>-1, 2=>1'::bigistore, -1);
SELECT subtract('-1=>-1, 2=>1'::bigistore, 0);
SELECT subtract(bigistore(Array[]::integer[], Array[]::integer[]), '1=>0'::bigistore);;
ROLLBACK;
BEGIN;
-- bigistore functions should multiply istores;
-- ./spec/istore/functions_plain_spec.rb:96;
CREATE EXTENSION istore;
SELECT multiply('1=>1, 2=>1'::bigistore, '1=>1, 2=>1'::bigistore);
SELECT multiply('1=>1, 2=>1'::bigistore, '-1=>1, 2=>1'::bigistore);
SELECT multiply('1=>1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT multiply('-1=>1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT multiply('-1=>-1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT multiply('-1=>-1, 2=>1'::bigistore, 1);
SELECT multiply('-1=>-1, 2=>1'::bigistore, -1);
SELECT multiply('-1=>-1, 2=>1'::bigistore, 0);
ROLLBACK;
BEGIN;
-- bigistore functions should divide istores;
-- ./spec/istore/functions_plain_spec.rb:115;
CREATE EXTENSION istore;
SELECT divide('1=>1, 2=>1'::bigistore, '1=>1, 2=>1'::bigistore);
SELECT divide('1=>1, 2=>1'::bigistore, '-1=>1, 2=>1'::bigistore);
SELECT divide('1=>1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT divide('-1=>1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT divide('-1=>-1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT divide('-1=>-1, 2=>1'::bigistore, '-1=>-1, 2=>1'::bigistore);
SELECT divide('1=>0, 2=>1'::bigistore, '1=>-1, 2=>1'::bigistore);
SELECT divide('1=>1, 2=>1'::bigistore, '1=>-1, 2=>1, 3=>0'::bigistore);
SELECT divide('1=>1, 2=>1'::bigistore, '3=>0'::bigistore);
SELECT divide('-1=>-1, 2=>1'::bigistore, -1);
ROLLBACK;
BEGIN;
-- bigistore functions should raise division by zero error;
-- ./spec/istore/functions_plain_spec.rb:137;
CREATE EXTENSION istore;
SELECT divide('-1=>-1, 2=>1'::bigistore, 0);
ROLLBACK;
BEGIN;
-- bigistore functions should raise division by zero error;
-- ./spec/istore/functions_plain_spec.rb:141;
CREATE EXTENSION istore;
SELECT divide('-1=>-1, 2=>1'::bigistore, '2=>0');
ROLLBACK;
BEGIN;
-- bigistore functions should generate #{type} from array;
-- ./spec/istore/functions_plain_spec.rb:145;
CREATE EXTENSION istore;
SELECT bigistore(ARRAY[1]);
SELECT bigistore(ARRAY[1,1,1,1]);
SELECT bigistore(NULL);
SELECT bigistore(ARRAY[1,2,3,4]);
SELECT bigistore(ARRAY[1,2,3,4,1,2,3,4]);
SELECT bigistore(ARRAY[1,2,3,4,1,2,3,NULL]);
SELECT bigistore(ARRAY[NULL,2,3,4,1,2,3,4]);
SELECT bigistore(ARRAY[NULL,2,3,4,1,2,3,NULL]);
SELECT bigistore(ARRAY[1,2,3,NULL,1,NULL,3,4,1,2,3]);
SELECT bigistore(ARRAY[NULL,NULL,NULL,NULL]::integer[]);
SELECT bigistore(ARRAY[]::integer[]);
ROLLBACK;
BEGIN;
-- bigistore functions should sum up istores;
-- ./spec/istore/functions_plain_spec.rb:167;
CREATE EXTENSION istore;
SELECT sum_up('1=>1'::bigistore);
SELECT sum_up(NULL::bigistore);
SELECT sum_up('1=>1, 2=>1'::bigistore);
SELECT sum_up('1=>1, 5=>1, 3=> 4'::bigistore, 3);
SELECT sum_up('1=>1 ,2=>-1, 1=>1'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should sum istores from table;
-- ./spec/istore/functions_plain_spec.rb:175;
CREATE EXTENSION istore;
CREATE TABLE test (a bigistore);
INSERT INTO test VALUES('1=>1'),('2=>1'), ('3=>1');
SELECT SUM(a) FROM test;
ROLLBACK;
BEGIN;
-- bigistore functions should sum istores from table;
-- ./spec/istore/functions_plain_spec.rb:182;
CREATE EXTENSION istore;
CREATE TABLE test (a bigistore);
INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>3');
SELECT SUM(a) FROM test;
ROLLBACK;
BEGIN;
-- bigistore functions should sum istores from table;
-- ./spec/istore/functions_plain_spec.rb:189;
CREATE EXTENSION istore;
CREATE TABLE test (a bigistore);
INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>0');
SELECT SUM(a) FROM test;
ROLLBACK;
BEGIN;
-- bigistore functions should return istores from arrays;
-- ./spec/istore/functions_plain_spec.rb:196;
CREATE EXTENSION istore;
SELECT bigistore(Array[5,3,4,5], Array[1,2,3,4]);
SELECT bigistore(Array[5,3,4,5], Array[1,2,3,4]);
SELECT bigistore(Array[5,3,4,5], Array[4000,2,4000,4]);
SELECT bigistore(Array[5,3,4]::int[], Array[5000000000,4000000000,5]::bigint[]);
ROLLBACK;
BEGIN;
-- bigistore functions should fill gaps;
-- ./spec/istore/functions_plain_spec.rb:211;
CREATE EXTENSION istore;
SELECT fill_gaps('2=>17, 4=>3'::bigistore, 5, 0);
SELECT fill_gaps('2=>17, 4=>3'::bigistore, 5);
SELECT fill_gaps('2=>17, 4=>3'::bigistore, 3, 11);
SELECT fill_gaps('2=>17, 4=>3'::bigistore, 0, 0);
SELECT fill_gaps('2=>17'::bigistore, 3, NULL);
SELECT fill_gaps('2=>0, 3=>3'::bigistore, 3, 0);
SELECT fill_gaps(''::bigistore, 3, 0);
SELECT fill_gaps(''::bigistore, 3, 400);
SELECT fill_gaps(NULL::bigistore, 3, 0);
SELECT fill_gaps('2=>17, 4=>3'::bigistore, -5, 0);
ROLLBACK;
BEGIN;
-- bigistore functions should fill accumulate;
-- ./spec/istore/functions_plain_spec.rb:240;
CREATE EXTENSION istore;
SELECT accumulate('2=>17, 4=>3'::bigistore);
SELECT accumulate('2=>0, 4=>3'::bigistore);
SELECT accumulate('1=>3, 2=>0, 4=>3, 6=>2'::bigistore);
SELECT accumulate(''::bigistore);
SELECT accumulate('10=>5'::bigistore);
SELECT accumulate(NULL::bigistore);
SELECT accumulate('-20=> 5, -10=> 5'::bigistore);
SELECT accumulate('-5=> 5, 3=> 5'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should fill accumulate upto;
-- ./spec/istore/functions_plain_spec.rb:256;
CREATE EXTENSION istore;
SELECT accumulate('2=>17, 4=>3'::bigistore, 8);
SELECT accumulate('2=>0, 4=>3'::bigistore, 8);
SELECT accumulate('1=>3, 2=>0, 4=>3, 6=>2'::bigistore, 8);
SELECT accumulate(''::bigistore, 8);
SELECT accumulate('10=>5'::bigistore, 8);
SELECT accumulate('1=>5'::bigistore, 0);
SELECT accumulate(NULL::bigistore, 8);
SELECT accumulate('-20=> 5, -10=> 5'::bigistore, -8);
SELECT accumulate('-5=> 5, 3=> 5'::bigistore, 2);
ROLLBACK;
BEGIN;
-- bigistore functions should accumulate big numbers;
-- ./spec/istore/functions_plain_spec.rb:273;
CREATE EXTENSION istore;
SELECT accumulate('0=>20000000000, 1=>10000000000, 3=>10000000000'::bigistore, 4);
ROLLBACK;
BEGIN;
-- bigistore functions should seed an #{type} from integer;
-- ./spec/istore/functions_plain_spec.rb:278;
CREATE EXTENSION istore;
SELECT istore_seed(2,5,8::bigint);
SELECT istore_seed(2,5,NULL::bigint);
SELECT istore_seed(2,5,0::bigint);
SELECT istore_seed(2,2,8::bigint);
SELECT istore_seed(2,0,8::bigint);
ROLLBACK;
BEGIN;
-- bigistore functions should throw an error if negativ seed span;
-- ./spec/istore/functions_plain_spec.rb:289;
CREATE EXTENSION istore;
SELECT istore_seed(-2,0,8);
ROLLBACK;
BEGIN;
-- bigistore functions should merge istores by larger keys;
-- ./spec/istore/functions_plain_spec.rb:293;
CREATE EXTENSION istore;
SELECT istore_val_larger('1=>1,2=>1,3=>3'::bigistore, '1=>2,3=>1,4=>1');
ROLLBACK;
BEGIN;
-- bigistore functions should merge istores by smaller keys;
-- ./spec/istore/functions_plain_spec.rb:298;
CREATE EXTENSION istore;
SELECT istore_val_smaller('1=>1,2=>1,3=>3'::bigistore, '1=>2,3=>1,4=>1');
ROLLBACK;
BEGIN;
-- bigistore functions should return #{type} with maxed values;
-- ./spec/istore/functions_plain_spec.rb:303;
CREATE EXTENSION istore;
SELECT MAX(s) FROM (VALUES('1=>5, 2=>2, 3=>3'::bigistore),('1=>1, 2=>5, 3=>3'),('1=>1, 2=>4, 3=>5'))t(s);
ROLLBACK;
BEGIN;
-- bigistore functions should return #{type} with maxed values;
-- ./spec/istore/functions_plain_spec.rb:308;
CREATE EXTENSION istore;
SELECT MIN(s) FROM (VALUES('1=>5, 2=>2, 3=>3'::bigistore),('1=>1, 2=>5, 3=>3'),('1=>1, 2=>4, 3=>5'))t(s);
ROLLBACK;
BEGIN;
-- bigistore functions should return keys as array;
-- ./spec/istore/functions_plain_spec.rb:313;
CREATE EXTENSION istore;
SELECT akeys('-5=>10, 0=>-5, 5=>0'::bigistore);
SELECT akeys(''::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should return values as array;
-- ./spec/istore/functions_plain_spec.rb:318;
CREATE EXTENSION istore;
SELECT avals('-5=>10, 0=>-5, 5=>0'::bigistore);
SELECT avals(''::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should return keys as set;
-- ./spec/istore/functions_plain_spec.rb:322;
CREATE EXTENSION istore;
SELECT skeys('-5=>10, 0=>-5, 5=>0'::bigistore);
SELECT skeys(''::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should return values set array;
-- ./spec/istore/functions_plain_spec.rb:330;
CREATE EXTENSION istore;
SELECT svals('-5=>10, 0=>-5, 5=>0'::bigistore);
SELECT svals(''::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should sum up istores;
-- ./spec/istore/functions_plain_spec.rb:338;
CREATE EXTENSION istore;
SELECT sum_up('10=>5, 15=>10'::istore);
ROLLBACK;
BEGIN;
-- bigistore functions should sum up istores with big numbers;
-- ./spec/istore/functions_plain_spec.rb:342;
CREATE EXTENSION istore;
SELECT sum_up('10=>2000000000, 15=>1000000000'::istore);
ROLLBACK;
BEGIN;
-- bigistore functions should sum up bigistores;
-- ./spec/istore/functions_plain_spec.rb:346;
CREATE EXTENSION istore;
SELECT sum_up('10=>5, 15=>10'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should sum up istores with negative values;
-- ./spec/istore/functions_plain_spec.rb:350;
CREATE EXTENSION istore;
SELECT sum_up('10=>5, 15=>-10'::istore);
ROLLBACK;
BEGIN;
-- bigistore functions should sum up bigistores with negative values;
-- ./spec/istore/functions_plain_spec.rb:354;
CREATE EXTENSION istore;
SELECT sum_up('10=>5, 15=>-10'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should return length of empty istores;
-- ./spec/istore/functions_plain_spec.rb:358;
CREATE EXTENSION istore;
SELECT istore_length(bigistore(ARRAY[]::integer[],ARRAY[]::integer[]));
ROLLBACK;
BEGIN;
-- bigistore functions should return length of non-empty istores;
-- ./spec/istore/functions_plain_spec.rb:362;
CREATE EXTENSION istore;
SELECT istore_length(bigistore(ARRAY[1],ARRAY[1]));
SELECT istore_length(bigistore(ARRAY[1,2,3],ARRAY[1,2,3]));
SELECT istore_length('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should convert istore to json;
-- ./spec/istore/functions_plain_spec.rb:368;
CREATE EXTENSION istore;
SELECT istore_to_json('5=>50, 7=>70, 9=>90'::bigistore);
SELECT istore_to_json('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should convert istore to array;
-- ./spec/istore/functions_plain_spec.rb:375;
CREATE EXTENSION istore;
SELECT istore_to_array('5=>50, 7=>70, 9=>90'::bigistore);
SELECT istore_to_array('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore);
SELECT istore_to_array(''::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should convert istore to matrix;
-- ./spec/istore/functions_plain_spec.rb:384;
CREATE EXTENSION istore;
SELECT istore_to_matrix('5=>50, 7=>70, 9=>90'::bigistore);
SELECT istore_to_matrix('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should be able to find the smallest key;
-- ./spec/istore/functions_plain_spec.rb:467;
CREATE EXTENSION istore;
SELECT min_key(''::bigistore);
SELECT min_key('1=>1'::bigistore);
SELECT min_key('1=>1, 2=>1'::bigistore);
SELECT min_key('0=>2, 1=>2, 3=>0 ,2=>2'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions should be able to find the biggest key;
-- ./spec/istore/functions_plain_spec.rb:474;
CREATE EXTENSION istore;
SELECT max_key(''::bigistore);
SELECT max_key('1=>1'::bigistore);
SELECT max_key('1=>1, 2=>1'::bigistore);
SELECT max_key('0=>2, 1=>2, 3=>0 ,2=>2'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions slice should return a partial istore;
-- ./spec/istore/functions_plain_spec.rb:392;
CREATE EXTENSION istore;
SELECT slice('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::bigistore, ARRAY[3,5,1,9,11]);
SELECT slice('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, ARRAY[10,0]);
ROLLBACK;
BEGIN;
-- bigistore functions slice should return null if no key match;
-- ./spec/istore/functions_plain_spec.rb:399;
CREATE EXTENSION istore;
SELECT slice('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::bigistore, ARRAY[30,50,10,90]);
ROLLBACK;
BEGIN;
-- bigistore functions slice_array should return a values from istore;
-- ./spec/istore/functions_plain_spec.rb:405;
CREATE EXTENSION istore;
SELECT slice_array('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::bigistore, ARRAY[3,5,1,9,11]);
SELECT slice_array('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, ARRAY[10,0]);
ROLLBACK;
BEGIN;
-- bigistore functions slice_array should return null array if no key match;
-- ./spec/istore/functions_plain_spec.rb:412;
CREATE EXTENSION istore;
SELECT slice_array('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::bigistore, ARRAY[30,50,10,90]);
ROLLBACK;
BEGIN;
-- bigistore functions delete should delete a key from istore;
-- ./spec/istore/functions_plain_spec.rb:419;
CREATE EXTENSION istore;
SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::bigistore,3);
SELECT delete('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, 10);
ROLLBACK;
BEGIN;
-- bigistore functions delete should return istore if key unmatched;
-- ./spec/istore/functions_plain_spec.rb:426;
CREATE EXTENSION istore;
SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::bigistore,6);
ROLLBACK;
BEGIN;
-- bigistore functions delete should delete multiple keys from istore;
-- ./spec/istore/functions_plain_spec.rb:431;
CREATE EXTENSION istore;
SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::bigistore,ARRAY[7,8,2,5,4]);
SELECT delete('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, ARRAY[0,10,-10]);
ROLLBACK;
BEGIN;
-- bigistore functions delete should return istore if keys are unmatched;
-- ./spec/istore/functions_plain_spec.rb:438;
CREATE EXTENSION istore;
SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::bigistore,ARRAY[8,6]);
ROLLBACK;
BEGIN;
-- bigistore functions delete should delete istore from istore;
-- ./spec/istore/functions_plain_spec.rb:443;
CREATE EXTENSION istore;
SELECT delete('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, '0=>5, 10=>100');
ROLLBACK;
BEGIN;
-- bigistore functions existence should check presence of a key;
-- ./spec/istore/functions_plain_spec.rb:450;
CREATE EXTENSION istore;
SELECT exist('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, 10);
SELECT exist('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, 25);
ROLLBACK;
BEGIN;
-- bigistore functions existence should check presence of any key;
-- ./spec/istore/functions_plain_spec.rb:454;
CREATE EXTENSION istore;
SELECT exists_any('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, Array[10,0]);
SELECT exists_any('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, Array[27,25]);
SELECT exists_any('1=>4,2=>5'::bigistore, ARRAY[]::int[]);;
ROLLBACK;
BEGIN;
-- bigistore functions existence should check presence of all key;
-- ./spec/istore/functions_plain_spec.rb:459;
CREATE EXTENSION istore;
SELECT exists_all('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, Array[10,0]);
SELECT exists_all('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, Array[10,25]);
SELECT exists_all('1=>4,2=>5'::bigistore, ARRAY[1,3]);;
SELECT exists_all('1=>4,2=>5'::bigistore, ARRAY[]::int[]);;
ROLLBACK;
BEGIN;
-- bigistore functions concat should concat two istores;
-- ./spec/istore/functions_plain_spec.rb:482;
CREATE EXTENSION istore;
SELECT concat('1=>4, 2=>5'::bigistore, '3=>4, 2=>7'::bigistore);
SELECT concat('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, '-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore);
ROLLBACK;
BEGIN;
-- bigistore functions concat should concat empty istores;
-- ./spec/istore/functions_plain_spec.rb:489;
CREATE EXTENSION istore;
SELECT concat('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore, ''::bigistore);
SELECT concat(''::bigistore, '-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore);
SELECT concat(''::bigistore, ''::bigistore);
ROLLBACK;
BEGIN;
-- istore functions should find keys with exists;
-- ./spec/istore/functions_plain_spec.rb:10;
CREATE EXTENSION istore;
SELECT exist('1=>1'::istore, 1);
SELECT exist('1=>1'::istore, 2);
SELECT exist('1=>1, -1=>0'::istore, 2);
SELECT exist('1=>1, -1=>0'::istore, -1);
ROLLBACK;
BEGIN;
-- istore functions should fetchvals;
-- ./spec/istore/functions_plain_spec.rb:17;
CREATE EXTENSION istore;
SELECT fetchval('1=>1'::istore, 1);
SELECT fetchval('2=>1'::istore, 1);
SELECT fetchval('1=>1, 1=>1'::istore, 1);
SELECT fetchval('1=>1, 1=>1'::istore, 2);
ROLLBACK;
BEGIN;
-- istore functions should return set of ints;
-- ./spec/istore/functions_plain_spec.rb:24;
CREATE EXTENSION istore;
SELECT * FROM each('1=>1'::istore);
SELECT * FROM each('5=>11, 4=>8'::istore);
SELECT * FROM each('5=>-411, 4=>8'::istore);
SELECT value + 100 FROM each('5=>-411, 4=>8'::istore);
SELECT * FROM each('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore);
SELECT * FROM each(NULL::istore);
ROLLBACK;
BEGIN;
-- istore functions should compact istores;
-- ./spec/istore/functions_plain_spec.rb:49;
CREATE EXTENSION istore;
SELECT compact('0=>2, 1=>2, 3=>0 ,2=>2'::istore);
ROLLBACK;
BEGIN;
-- istore functions should add istores;
-- ./spec/istore/functions_plain_spec.rb:54;
CREATE EXTENSION istore;
SELECT add('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore);
SELECT add('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore);
SELECT add('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT add('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT add('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT add('-1=>-1, 2=>1'::istore, 1);
SELECT add('-1=>-1, 2=>1'::istore, -1);
SELECT add('-1=>-1, 2=>1'::istore, 0);
SELECT add(istore(Array[]::integer[], Array[]::integer[]), '1=>0'::istore);;
ROLLBACK;
BEGIN;
-- istore functions should substract istores;
-- ./spec/istore/functions_plain_spec.rb:75;
CREATE EXTENSION istore;
SELECT subtract('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore);
SELECT subtract('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore);
SELECT subtract('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT subtract('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT subtract('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT subtract('-1=>-1, 2=>1'::istore, 1);
SELECT subtract('-1=>-1, 2=>1'::istore, -1);
SELECT subtract('-1=>-1, 2=>1'::istore, 0);
SELECT subtract(istore(Array[]::integer[], Array[]::integer[]), '1=>0'::istore);;
ROLLBACK;
BEGIN;
-- istore functions should multiply istores;
-- ./spec/istore/functions_plain_spec.rb:96;
CREATE EXTENSION istore;
SELECT multiply('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore);
SELECT multiply('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore);
SELECT multiply('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT multiply('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT multiply('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT multiply('-1=>-1, 2=>1'::istore, 1);
SELECT multiply('-1=>-1, 2=>1'::istore, -1);
SELECT multiply('-1=>-1, 2=>1'::istore, 0);
ROLLBACK;
BEGIN;
-- istore functions should divide istores;
-- ./spec/istore/functions_plain_spec.rb:115;
CREATE EXTENSION istore;
SELECT divide('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore);
SELECT divide('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore);
SELECT divide('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT divide('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT divide('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT divide('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore);
SELECT divide('1=>0, 2=>1'::istore, '1=>-1, 2=>1'::istore);
SELECT divide('1=>1, 2=>1'::istore, '1=>-1, 2=>1, 3=>0'::istore);
SELECT divide('1=>1, 2=>1'::istore, '3=>0'::istore);
SELECT divide('-1=>-1, 2=>1'::istore, -1);
ROLLBACK;
BEGIN;
-- istore functions should raise division by zero error;
-- ./spec/istore/functions_plain_spec.rb:137;
CREATE EXTENSION istore;
SELECT divide('-1=>-1, 2=>1'::istore, 0);
ROLLBACK;
BEGIN;
-- istore functions should raise division by zero error;
-- ./spec/istore/functions_plain_spec.rb:141;
CREATE EXTENSION istore;
SELECT divide('-1=>-1, 2=>1'::istore, '2=>0');
ROLLBACK;
BEGIN;
-- istore functions should generate #{type} from array;
-- ./spec/istore/functions_plain_spec.rb:145;
CREATE EXTENSION istore;
SELECT istore(ARRAY[1]);
SELECT istore(ARRAY[1,1,1,1]);
SELECT istore(NULL);
SELECT istore(ARRAY[1,2,3,4]);
SELECT istore(ARRAY[1,2,3,4,1,2,3,4]);
SELECT istore(ARRAY[1,2,3,4,1,2,3,NULL]);
SELECT istore(ARRAY[NULL,2,3,4,1,2,3,4]);
SELECT istore(ARRAY[NULL,2,3,4,1,2,3,NULL]);
SELECT istore(ARRAY[1,2,3,NULL,1,NULL,3,4,1,2,3]);
SELECT istore(ARRAY[NULL,NULL,NULL,NULL]::integer[]);
SELECT istore(ARRAY[]::integer[]);
ROLLBACK;
BEGIN;
-- istore functions should sum up istores;
-- ./spec/istore/functions_plain_spec.rb:167;
CREATE EXTENSION istore;
SELECT sum_up('1=>1'::istore);
SELECT sum_up(NULL::istore);
SELECT sum_up('1=>1, 2=>1'::istore);
SELECT sum_up('1=>1, 5=>1, 3=> 4'::istore, 3);
SELECT sum_up('1=>1 ,2=>-1, 1=>1'::istore);
ROLLBACK;
BEGIN;
-- istore functions should sum istores from table;
-- ./spec/istore/functions_plain_spec.rb:175;
CREATE EXTENSION istore;
CREATE TABLE test (a istore);
INSERT INTO test VALUES('1=>1'),('2=>1'), ('3=>1');
SELECT SUM(a) FROM test;
ROLLBACK;
BEGIN;
-- istore functions should sum istores from table;
-- ./spec/istore/functions_plain_spec.rb:182;
CREATE EXTENSION istore;
CREATE TABLE test (a istore);
INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>3');
SELECT SUM(a) FROM test;
ROLLBACK;
BEGIN;
-- istore functions should sum istores from table;
-- ./spec/istore/functions_plain_spec.rb:189;
CREATE EXTENSION istore;
CREATE TABLE test (a istore);
INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>0');
SELECT SUM(a) FROM test;
ROLLBACK;
BEGIN;
-- istore functions should return istores from arrays;
-- ./spec/istore/functions_plain_spec.rb:196;
CREATE EXTENSION istore;
SELECT istore(Array[5,3,4,5], Array[1,2,3,4]);
SELECT istore(Array[5,3,4,5], Array[1,2,3,4]);
SELECT istore(Array[5,3,4,5], Array[4000,2,4000,4]);
ROLLBACK;
BEGIN;
-- istore functions should fill gaps;
-- ./spec/istore/functions_plain_spec.rb:211;
CREATE EXTENSION istore;
SELECT fill_gaps('2=>17, 4=>3'::istore, 5, 0);
SELECT fill_gaps('2=>17, 4=>3'::istore, 5);
SELECT fill_gaps('2=>17, 4=>3'::istore, 3, 11);
SELECT fill_gaps('2=>17, 4=>3'::istore, 0, 0);
SELECT fill_gaps('2=>17'::istore, 3, NULL);
SELECT fill_gaps('2=>0, 3=>3'::istore, 3, 0);
SELECT fill_gaps(''::istore, 3, 0);
SELECT fill_gaps(''::istore, 3, 400);
SELECT fill_gaps(NULL::istore, 3, 0);
SELECT fill_gaps('2=>17, 4=>3'::istore, -5, 0);
ROLLBACK;
BEGIN;
-- istore functions should fill accumulate;
-- ./spec/istore/functions_plain_spec.rb:240;
CREATE EXTENSION istore;
SELECT accumulate('2=>17, 4=>3'::istore);
SELECT accumulate('2=>0, 4=>3'::istore);
SELECT accumulate('1=>3, 2=>0, 4=>3, 6=>2'::istore);
SELECT accumulate(''::istore);
SELECT accumulate('10=>5'::istore);
SELECT accumulate(NULL::istore);
SELECT accumulate('-20=> 5, -10=> 5'::istore);
SELECT accumulate('-5=> 5, 3=> 5'::istore);
ROLLBACK;
BEGIN;
-- istore functions should fill accumulate upto;
-- ./spec/istore/functions_plain_spec.rb:256;
CREATE EXTENSION istore;
SELECT accumulate('2=>17, 4=>3'::istore, 8);
SELECT accumulate('2=>0, 4=>3'::istore, 8);
SELECT accumulate('1=>3, 2=>0, 4=>3, 6=>2'::istore, 8);
SELECT accumulate(''::istore, 8);
SELECT accumulate('10=>5'::istore, 8);
SELECT accumulate('1=>5'::istore, 0);
SELECT accumulate(NULL::istore, 8);
SELECT accumulate('-20=> 5, -10=> 5'::istore, -8);
SELECT accumulate('-5=> 5, 3=> 5'::istore, 2);
ROLLBACK;
BEGIN;
-- istore functions should accumulate big numbers;
-- ./spec/istore/functions_plain_spec.rb:273;
CREATE EXTENSION istore;
SELECT accumulate('0=>20000000000, 1=>10000000000, 3=>10000000000'::bigistore, 4);
ROLLBACK;
BEGIN;
-- istore functions should seed an #{type} from integer;
-- ./spec/istore/functions_plain_spec.rb:278;
CREATE EXTENSION istore;
SELECT istore_seed(2,5,8::int);
SELECT istore_seed(2,5,NULL::int);
SELECT istore_seed(2,5,0::int);
SELECT istore_seed(2,2,8::int);
SELECT istore_seed(2,0,8::int);
ROLLBACK;
BEGIN;
-- istore functions should throw an error if negativ seed span;
-- ./spec/istore/functions_plain_spec.rb:289;
CREATE EXTENSION istore;
SELECT istore_seed(-2,0,8);
ROLLBACK;
BEGIN;
-- istore functions should merge istores by larger keys;
-- ./spec/istore/functions_plain_spec.rb:293;
CREATE EXTENSION istore;
SELECT istore_val_larger('1=>1,2=>1,3=>3'::istore, '1=>2,3=>1,4=>1');
ROLLBACK;
BEGIN;
-- istore functions should merge istores by smaller keys;
-- ./spec/istore/functions_plain_spec.rb:298;
CREATE EXTENSION istore;
SELECT istore_val_smaller('1=>1,2=>1,3=>3'::istore, '1=>2,3=>1,4=>1');
ROLLBACK;
BEGIN;
-- istore functions should return #{type} with maxed values;
-- ./spec/istore/functions_plain_spec.rb:303;
CREATE EXTENSION istore;
SELECT MAX(s) FROM (VALUES('1=>5, 2=>2, 3=>3'::istore),('1=>1, 2=>5, 3=>3'),('1=>1, 2=>4, 3=>5'))t(s);
ROLLBACK;
BEGIN;
-- istore functions should return #{type} with maxed values;
-- ./spec/istore/functions_plain_spec.rb:308;
CREATE EXTENSION istore;
SELECT MIN(s) FROM (VALUES('1=>5, 2=>2, 3=>3'::istore),('1=>1, 2=>5, 3=>3'),('1=>1, 2=>4, 3=>5'))t(s);
ROLLBACK;
BEGIN;
-- istore functions should return keys as array;
-- ./spec/istore/functions_plain_spec.rb:313;
CREATE EXTENSION istore;
SELECT akeys('-5=>10, 0=>-5, 5=>0'::istore);
SELECT akeys(''::istore);
ROLLBACK;
BEGIN;
-- istore functions should return values as array;
-- ./spec/istore/functions_plain_spec.rb:318;
CREATE EXTENSION istore;
SELECT avals('-5=>10, 0=>-5, 5=>0'::istore);
SELECT avals(''::istore);
ROLLBACK;
BEGIN;
-- istore functions should return keys as set;
-- ./spec/istore/functions_plain_spec.rb:322;
CREATE EXTENSION istore;
SELECT skeys('-5=>10, 0=>-5, 5=>0'::istore);
SELECT skeys(''::istore);
ROLLBACK;
BEGIN;
-- istore functions should return values set array;
-- ./spec/istore/functions_plain_spec.rb:330;
CREATE EXTENSION istore;
SELECT svals('-5=>10, 0=>-5, 5=>0'::istore);
SELECT svals(''::istore);
ROLLBACK;
BEGIN;
-- istore functions should sum up istores;
-- ./spec/istore/functions_plain_spec.rb:338;
CREATE EXTENSION istore;
SELECT sum_up('10=>5, 15=>10'::istore);
ROLLBACK;
BEGIN;
-- istore functions should sum up istores with big numbers;
-- ./spec/istore/functions_plain_spec.rb:342;
CREATE EXTENSION istore;
SELECT sum_up('10=>2000000000, 15=>1000000000'::istore);
ROLLBACK;
BEGIN;
-- istore functions should sum up bigistores;
-- ./spec/istore/functions_plain_spec.rb:346;
CREATE EXTENSION istore;
SELECT sum_up('10=>5, 15=>10'::bigistore);
ROLLBACK;
BEGIN;
-- istore functions should sum up istores with negative values;
-- ./spec/istore/functions_plain_spec.rb:350;
CREATE EXTENSION istore;
SELECT sum_up('10=>5, 15=>-10'::istore);
ROLLBACK;
BEGIN;
-- istore functions should sum up bigistores with negative values;
-- ./spec/istore/functions_plain_spec.rb:354;
CREATE EXTENSION istore;
SELECT sum_up('10=>5, 15=>-10'::bigistore);
ROLLBACK;
BEGIN;
-- istore functions should return length of empty istores;
-- ./spec/istore/functions_plain_spec.rb:358;
CREATE EXTENSION istore;
SELECT istore_length(istore(ARRAY[]::integer[],ARRAY[]::integer[]));
ROLLBACK;
BEGIN;
-- istore functions should return length of non-empty istores;
-- ./spec/istore/functions_plain_spec.rb:362;
CREATE EXTENSION istore;
SELECT istore_length(istore(ARRAY[1],ARRAY[1]));
SELECT istore_length(istore(ARRAY[1,2,3],ARRAY[1,2,3]));
SELECT istore_length('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore);
ROLLBACK;
BEGIN;
-- istore functions should convert istore to json;
-- ./spec/istore/functions_plain_spec.rb:368;
CREATE EXTENSION istore;
SELECT istore_to_json('5=>50, 7=>70, 9=>90'::istore);
SELECT istore_to_json('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore);
ROLLBACK;
BEGIN;
-- istore functions should convert istore to array;
-- ./spec/istore/functions_plain_spec.rb:375;
CREATE EXTENSION istore;
SELECT istore_to_array('5=>50, 7=>70, 9=>90'::istore);
SELECT istore_to_array('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore);
SELECT istore_to_array(''::istore);
ROLLBACK;
BEGIN;
-- istore functions should convert istore to matrix;
-- ./spec/istore/functions_plain_spec.rb:384;
CREATE EXTENSION istore;
SELECT istore_to_matrix('5=>50, 7=>70, 9=>90'::istore);
SELECT istore_to_matrix('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore);
ROLLBACK;
BEGIN;
-- istore functions should be able to find the smallest key;
-- ./spec/istore/functions_plain_spec.rb:467;
CREATE EXTENSION istore;
SELECT min_key(''::istore);
SELECT min_key('1=>1'::istore);
SELECT min_key('1=>1, 2=>1'::istore);
SELECT min_key('0=>2, 1=>2, 3=>0 ,2=>2'::istore);
ROLLBACK;
BEGIN;
-- istore functions should be able to find the biggest key;
-- ./spec/istore/functions_plain_spec.rb:474;
CREATE EXTENSION istore;
SELECT max_key(''::istore);
SELECT max_key('1=>1'::istore);
SELECT max_key('1=>1, 2=>1'::istore);
SELECT max_key('0=>2, 1=>2, 3=>0 ,2=>2'::istore);
ROLLBACK;
BEGIN;
-- istore functions slice should return a partial istore;
-- ./spec/istore/functions_plain_spec.rb:392;
CREATE EXTENSION istore;
SELECT slice('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::istore, ARRAY[3,5,1,9,11]);
SELECT slice('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, ARRAY[10,0]);
ROLLBACK;
BEGIN;
-- istore functions slice should return null if no key match;
-- ./spec/istore/functions_plain_spec.rb:399;
CREATE EXTENSION istore;
SELECT slice('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::istore, ARRAY[30,50,10,90]);
ROLLBACK;
BEGIN;
-- istore functions slice_array should return a values from istore;
-- ./spec/istore/functions_plain_spec.rb:405;
CREATE EXTENSION istore;
SELECT slice_array('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::istore, ARRAY[3,5,1,9,11]);
SELECT slice_array('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, ARRAY[10,0]);
ROLLBACK;
BEGIN;
-- istore functions slice_array should return null array if no key match;
-- ./spec/istore/functions_plain_spec.rb:412;
CREATE EXTENSION istore;
SELECT slice_array('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::istore, ARRAY[30,50,10,90]);
ROLLBACK;
BEGIN;
-- istore functions delete should delete a key from istore;
-- ./spec/istore/functions_plain_spec.rb:419;
CREATE EXTENSION istore;
SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::istore,3);
SELECT delete('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, 10);
ROLLBACK;
BEGIN;
-- istore functions delete should return istore if key unmatched;
-- ./spec/istore/functions_plain_spec.rb:426;
CREATE EXTENSION istore;
SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::istore,6);
ROLLBACK;
BEGIN;
-- istore functions delete should delete multiple keys from istore;
-- ./spec/istore/functions_plain_spec.rb:431;
CREATE EXTENSION istore;
SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::istore,ARRAY[7,8,2,5,4]);
SELECT delete('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, ARRAY[0,10,-10]);
ROLLBACK;
BEGIN;
-- istore functions delete should return istore if keys are unmatched;
-- ./spec/istore/functions_plain_spec.rb:438;
CREATE EXTENSION istore;
SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::istore,ARRAY[8,6]);
ROLLBACK;
BEGIN;
-- istore functions delete should delete istore from istore;
-- ./spec/istore/functions_plain_spec.rb:443;
CREATE EXTENSION istore;
SELECT delete('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, '0=>5, 10=>100');
ROLLBACK;
BEGIN;
-- istore functions existence should check presence of a key;
-- ./spec/istore/functions_plain_spec.rb:450;
CREATE EXTENSION istore;
SELECT exist('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, 10);
SELECT exist('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, 25);
ROLLBACK;
BEGIN;
-- istore functions existence should check presence of any key;
-- ./spec/istore/functions_plain_spec.rb:454;
CREATE EXTENSION istore;
SELECT exists_any('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, Array[10,0]);
SELECT exists_any('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, Array[27,25]);
SELECT exists_any('1=>4,2=>5'::istore, ARRAY[]::int[]);;
ROLLBACK;
BEGIN;
-- istore functions existence should check presence of all key;
-- ./spec/istore/functions_plain_spec.rb:459;
CREATE EXTENSION istore;
SELECT exists_all('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, Array[10,0]);
SELECT exists_all('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, Array[10,25]);
SELECT exists_all('1=>4,2=>5'::istore, ARRAY[1,3]);;
SELECT exists_all('1=>4,2=>5'::istore, ARRAY[]::int[]);;
ROLLBACK;
BEGIN;
-- istore functions concat should concat two istores;
-- ./spec/istore/functions_plain_spec.rb:482;
CREATE EXTENSION istore;
SELECT concat('1=>4, 2=>5'::istore, '3=>4, 2=>7'::istore);
SELECT concat('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, '-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore);
ROLLBACK;
BEGIN;
-- istore functions concat should concat empty istores;
-- ./spec/istore/functions_plain_spec.rb:489;
CREATE EXTENSION istore;
SELECT concat('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore, ''::istore);
SELECT concat(''::istore, '-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore);
SELECT concat(''::istore, ''::istore);
ROLLBACK;
