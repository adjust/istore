----operators----
DROP OPERATOR IF EXISTS ?& (bigistore, _int4);
----
DROP OPERATOR IF EXISTS %# (NONE, bigistore);
----
DROP OPERATOR IF EXISTS %% (NONE, bigistore);
----
DROP OPERATOR IF EXISTS -> (bigistore, _int4);
----
DROP OPERATOR IF EXISTS -> (istore, _int4);
----
DROP OPERATOR IF EXISTS || (bigistore, bigistore);
----
DROP OPERATOR IF EXISTS ?| (bigistore, _int4);
----
DROP OPERATOR IF EXISTS %# (NONE, istore);
----
DROP OPERATOR IF EXISTS %% (NONE, istore);
----
DROP OPERATOR IF EXISTS || (istore, istore);
----
DROP OPERATOR IF EXISTS ?| (istore, _int4);
----
DROP OPERATOR IF EXISTS ?& (istore, _int4);
----functions----
DROP FUNCTION IF EXISTS concat(istore, istore);
----
DROP FUNCTION IF EXISTS max_key(istore);
----
DROP FUNCTION IF EXISTS min_key(istore);
----
DROP FUNCTION IF EXISTS delete(bigistore, bigistore);
----
DROP FUNCTION IF EXISTS exists_any(bigistore, integer[]);
----
DROP FUNCTION IF EXISTS exists_all(bigistore, integer[]);
----
DROP FUNCTION IF EXISTS delete(bigistore, integer[]);
----
DROP FUNCTION IF EXISTS delete(bigistore, integer);
----
DROP FUNCTION IF EXISTS slice_array(bigistore, integer[]);
----
DROP FUNCTION IF EXISTS slice(bigistore, integer[]);
----
DROP FUNCTION IF EXISTS istore_to_matrix(bigistore);
----
DROP FUNCTION IF EXISTS istore_to_array(bigistore);
----
DROP FUNCTION IF EXISTS concat(bigistore, bigistore);
----
DROP FUNCTION IF EXISTS max_key(bigistore);
----
DROP FUNCTION IF EXISTS min_key(bigistore);
----
DROP FUNCTION IF EXISTS delete(istore, istore);
----
DROP FUNCTION IF EXISTS exists_any(istore, integer[]);
----
DROP FUNCTION IF EXISTS exists_all(istore, integer[]);
----
DROP FUNCTION IF EXISTS delete(istore, integer[]);
----
DROP FUNCTION IF EXISTS delete(istore, integer);
----
DROP FUNCTION IF EXISTS slice_array(istore, integer[]);
----
DROP FUNCTION IF EXISTS slice(istore, integer[]);
----
DROP FUNCTION IF EXISTS istore_to_matrix(istore);
----
DROP FUNCTION IF EXISTS istore_to_array(istore);
