BEGIN;
CREATE TABLE device_istore_io AS SELECT 'bot=>1,mac=>2'::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT '"bot"=>"1","bot"=>"2"'::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT '"bot"=>"1","mac"=>"2"'::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT '"mac"=>"+1","bot"=>"2"'::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT ' "mac"=>"+1","bot"=>"2"'::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT '"mac"=> "+1","bot"=>"2"'::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT '"mac"=>"+1" ,"bot"=>"2"'::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT '"mac"=>"+1", "bot"=>"2"'::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT '"mac"=>"+1","bot"=>"2" '::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE device_istore_io AS SELECT '"mac"=>"+1","bot"=>"2" '::device_istore;
SELECT * FROM device_istore_io;
ROLLBACK;
