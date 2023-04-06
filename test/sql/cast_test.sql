-- casts should cast from istore to bigistore;
SELECT '1=>1, -1=>-1'::istore::bigistore;
-- casts should cast from bigistore to istore;
SELECT '1=>1, -1=>-1'::bigistore::istore;
-- casts should fail cast from bigistore to istore if any value is to big;
SELECT '1=>1, -1=>3000000000'::bigistore::istore;
