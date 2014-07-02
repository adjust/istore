SELECT exist('1=>1'::istore, 1);
SELECT exist('1=>1'::istore, 2);
SELECT exist('1=>1, -1=>0'::istore, 2);
SELECT exist('1=>1, -1=>0', -1);
