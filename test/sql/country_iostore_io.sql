BEGIN;
CREATE TABLE country_istore_io AS SELECT 'de=>1,de=>2'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"de"=>"1","de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"de"=>"1","en"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"en"=>"+1","de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT ' "en"=>"+1","de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"en"=> "+1","de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"en"=>"+1" ,"de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"en"=>"+1", "de"=>"2"'::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT '"en"=>"+1","de"=>"2" '::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;

BEGIN;
CREATE TABLE country_istore_io AS SELECT 'en=>+1,de=>2 '::country_istore;
SELECT * FROM country_istore_io;
ROLLBACK;
