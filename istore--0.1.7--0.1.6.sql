
----functions----
CREATE OR REPLACE FUNCTION istore_sum_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', 'bigistore_sum_transfn';
----
CREATE OR REPLACE FUNCTION istore_min_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', 'bigistore_min_transfn';
----
CREATE OR REPLACE FUNCTION istore_max_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', 'bigistore_max_transfn';


----
DROP AGGREGATE IF EXISTS sum (bigistore);
CREATE AGGREGATE sum(bigistore) (
  SFUNC = istore_sum_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
);


----
DROP AGGREGATE IF EXISTS min (bigistore);
CREATE AGGREGATE min(bigistore) (
  SFUNC = istore_min_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
);


----
DROP AGGREGATE IF EXISTS max (bigistore);
CREATE AGGREGATE max(bigistore) (
  SFUNC = istore_max_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
);


----
DROP FUNCTION IF EXISTS bigistore_sum_transfn(internal, bigistore);
----
DROP FUNCTION IF EXISTS bigistore_min_transfn(internal, bigistore);
----
DROP FUNCTION IF EXISTS bigistore_max_transfn(internal, bigistore);
