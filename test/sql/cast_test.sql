SELECT '1=>1, -1=>-1'::istore::bigistore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '1=>1, -1=>-1'::bigistore::istore;
ROLLBACK;
BEGIN;
CREATE EXTENSION istore;
SELECT '1=>1, -1=>3000000000'::bigistore::istore;
ROLLBACK;
