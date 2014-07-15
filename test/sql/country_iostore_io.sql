BEGIN;
CREATE TABLE country_istore_io AS SELECT 'de=>1,de=>2'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"de"=>"1","de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"de"=>"1","zz"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"zz"=>"+1","de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT ' "zz"=>"+1","de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"zz"=> "+1","de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"zz"=>"+1" ,"de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"zz"=>"+1", "de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"zz"=>"+1","de"=>"2" '::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT 'zz=>+1,de=>2 '::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;
