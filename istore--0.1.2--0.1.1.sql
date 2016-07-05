CREATE OR REPLACE FUNCTION bigistore_agg_finalfn(internal)
    RETURNS bigistore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION istore_agg_finalfn(internal)
    RETURNS bigistore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

----aggregates----
DROP AGGREGATE IF EXISTS sum (bigistore);
CREATE AGGREGATE sum(bigistore) (
  SFUNC = array_agg_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
);


----
DROP AGGREGATE IF EXISTS sum (istore);
CREATE AGGREGATE sum(istore) (
  SFUNC = array_agg_transfn,
  STYPE = internal,
  FINALFUNC = istore_agg_finalfn
);


----functions----
DROP FUNCTION IF EXISTS istore_sum_transfn(internal, bigistore);
----
DROP FUNCTION IF EXISTS istore_sum_finalfn(internal);
----
DROP FUNCTION IF EXISTS istore_sum_transfn(internal, istore);
