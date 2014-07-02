BEGIN;
CREATE TABLE istore_io AS SELECT '1=>1,1=>2'::istore;
SELECT * FROM istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE istore_io AS SELECT '"1"=>"1","1"=>"2"'::istore;
SELECT * FROM istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE istore_io AS SELECT '"1"=>"1","-1"=>"2"'::istore;
SELECT * FROM istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE istore_io AS SELECT '"-1"=>"+1","1"=>"2"'::istore;
SELECT * FROM istore_io;
ROLLBACK;
