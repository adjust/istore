----functions----
DROP FUNCTION IF EXISTS join(a bigistore, b bigistore, c bigistore, d bigistore, e bigistore, OUT key integer, OUT value1 bigint, OUT value2 bigint, OUT value3 bigint, OUT value4 bigint, OUT value5 bigint);
----
DROP FUNCTION IF EXISTS join(a bigistore, b bigistore, c bigistore, d bigistore, OUT key integer, OUT value1 bigint, OUT value2 bigint, OUT value3 bigint, OUT value4 bigint);
----
DROP FUNCTION IF EXISTS join(a bigistore, b bigistore, c bigistore, OUT key integer, OUT value1 bigint, OUT value2 bigint, OUT value3 bigint);
----
DROP FUNCTION IF EXISTS join(a bigistore, b bigistore, OUT key integer, OUT value1 bigint, OUT value2 bigint);
