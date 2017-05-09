----aggregates----
DROP AGGREGATE IF EXISTS isagg (key integer, value bigint);
----
DROP AGGREGATE IF EXISTS isagg (key integer, value integer);
----functions----
DROP FUNCTION IF EXISTS bigistore_avl_finalfn(internal);
----
DROP FUNCTION IF EXISTS bigistore_avl_transfn(internal, integer, bigint);
----
DROP FUNCTION IF EXISTS istore_avl_finalfn(internal);
----
DROP FUNCTION IF EXISTS istore_avl_transfn(internal, integer, integer);
