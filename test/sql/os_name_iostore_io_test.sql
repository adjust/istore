BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:8;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT 'android=>1,android=>2'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:14;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT '"android"=>"1", "android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:20;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT '"android"=>"1", "ios"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:26;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1","android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:32;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT ' "ios"=>"+1","android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:38;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=> "+1","android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:44;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1" ,"android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:50;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1", "android"=>"2"'::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:56;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1","android"=>"2" '::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;
BEGIN;
-- os_name_iostore_io should persist os_name_iostores;
-- ./spec/os_name_iostore_io_spec.rb:62;
CREATE EXTENSION istore;
CREATE TABLE os_name_istore_io AS SELECT 'ios=>+1,android=>2 '::os_name_istore;
SELECT * FROM os_name_istore_io;
ROLLBACK;