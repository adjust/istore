CREATE TABLE istore_io AS SELECT '-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore;
SELECT * FROM istore_io;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE istore_io AS SELECT '"-1"=>"+1","1"=>"2"'::bigistore;
SELECT * FROM istore_io;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE istore_io AS SELECT ' "-1"=>"+1","1"=>"2"'::bigistore;
SELECT * FROM istore_io;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE istore_io AS SELECT ''::bigistore;
SELECT * FROM istore_io;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT istore_to_json('-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'::bigistore);
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 1=>foo, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 1=>5foo, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 1=>18446744073709551612, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 1=>-18446744073709551614, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 54foo=>5, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, foo=>5, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 4000000000=>5, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, -4000000000=>5, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 10=5, 5=>17'::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE istore_io AS SELECT '-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore;
SELECT * FROM istore_io;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE istore_io AS SELECT '"-1"=>"+1","1"=>"2"'::istore;
SELECT * FROM istore_io;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE istore_io AS SELECT ' "-1"=>"+1","1"=>"2"'::istore;
SELECT * FROM istore_io;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
CREATE TABLE istore_io AS SELECT ''::istore;
SELECT * FROM istore_io;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT istore_to_json('-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'::istore);
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 1=>foo, 5=>17'::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 1=>5foo, 5=>17'::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 1=>4294967294, 5=>17'::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 1=>-4294967294, 5=>17'::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 54foo=>5, 5=>17'::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, foo=>5, 5=>17'::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 4000000000=>5, 5=>17'::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, -4000000000=>5, 5=>17'::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '2=>4, 10=5, 5=>17'::istore;
ROLLBACK;
