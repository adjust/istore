----aggregates----
DROP AGGREGATE IF EXISTS isagg (integer, bigint);
----
DROP AGGREGATE IF EXISTS isagg (integer, integer);
----functions----
DROP FUNCTION IF EXISTS bigistore_avl_finalfn(internal);
----
DROP FUNCTION IF EXISTS bigistore_avl_transfn(internal, integer, bigint);
----
DROP FUNCTION IF EXISTS istore_avl_finalfn(internal);
----
DROP FUNCTION IF EXISTS istore_avl_transfn(internal, integer, integer);
