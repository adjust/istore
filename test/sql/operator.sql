SELECT '1=>1, -1=>0'::istore -> -1;
SELECT '1=>1, -1=>3'::istore -> -1;

SELECT '1=>1, -1=>3'::istore ? -1;
SELECT '1=>1, -1=>3'::istore ? 5;

SELECT '1=>1, -1=>3'::istore + '1=>1'::istore;
SELECT '1=>1, -1=>3'::istore + '-1=>-1'::istore;
SELECT '1=>1, -1=>3'::istore + '1=>-1'::istore;

SELECT '1=>1, -1=>3'::istore - '1=>1'::istore;
SELECT '1=>1, -1=>3'::istore - '-1=>-1'::istore;
SELECT '1=>1, -1=>3'::istore - '1=>-1'::istore;

SELECT '1=>3, 2=>2'::istore * '1=>2, 3=>5'::istore;
SELECT '-1=>3, 2=>2'::istore * '-1=>2, 3=>5'::istore;
SELECT '-1=>3, 2=>2'::istore * '-1=>-2, 3=>5'::istore;
