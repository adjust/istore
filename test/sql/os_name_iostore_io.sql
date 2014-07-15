BEGIN;
CREATE TABLE os_name_istore_io AS SELECT 'android=>1,android=>2'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT '"android"=>"1","android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT '"android"=>"1","ios"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1","android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT ' "ios"=>"+1","android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=> "+1","android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1" ,"android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1", "android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1","android"=>"2" '::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE os_name_istore_io AS SELECT 'ios=>+1,android=>2 '::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
