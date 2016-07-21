CREATE OR REPLACE FUNCTION bigistore_agg_finalfn(internal)
    RETURNS bigistore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION istore_agg_finalfn(internal)
    RETURNS istore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

----aggregates----
DROP AGGREGATE IF EXISTS MIN (istore);
CREATE AGGREGATE MIN(istore) (
    sfunc = istore_val_smaller,
    stype = istore
);

----
DROP AGGREGATE IF EXISTS MAX (istore);
CREATE AGGREGATE MAX(istore) (
    sfunc = istore_val_larger,
    stype = istore
);

----
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

----
DROP AGGREGATE IF EXISTS MIN (bigistore);
CREATE AGGREGATE MIN(bigistore) (
    sfunc = istore_val_smaller,
    stype = bigistore
);

----functions----
DROP FUNCTION IF EXISTS istore_sum_transfn(internal, bigistore);

----
DROP AGGREGATE IF EXISTS MAX (bigistore);
CREATE AGGREGATE MAX(bigistore) (
    sfunc = istore_val_larger,
    stype = bigistore
);

----
DROP FUNCTION IF EXISTS istore_sum_transfn(internal, istore);

----
DROP FUNCTION IF EXISTS istore_max_transfn(internal, bigistore);

----
DROP FUNCTION IF EXISTS istore_min_transfn(internal, bigistore);

----
DROP FUNCTION IF EXISTS istore_max_transfn(internal, istore);

----
DROP FUNCTION IF EXISTS istore_min_transfn(internal, istore)
