CREATE OR REPLACE FUNCTION bigistore_sum_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', 'bigistore_sum_transfn';
----
CREATE OR REPLACE FUNCTION bigistore_min_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', 'bigistore_min_transfn';
----
CREATE OR REPLACE FUNCTION bigistore_max_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', 'bigistore_max_transfn';

----aggregates----
----
DROP AGGREGATE IF EXISTS sum (bigistore);
CREATE AGGREGATE sum(bigistore) (
  SFUNC = bigistore_sum_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
);


----
DROP AGGREGATE IF EXISTS min (bigistore);
CREATE AGGREGATE min(bigistore) (
  SFUNC = bigistore_min_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
);

----
DROP AGGREGATE IF EXISTS max (bigistore);
CREATE AGGREGATE max(bigistore) (
  SFUNC = bigistore_max_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
);

----functions----
DROP FUNCTION IF EXISTS istore_sum_transfn(internal, bigistore);
----
DROP FUNCTION IF EXISTS istore_min_transfn(internal, bigistore);
----
DROP FUNCTION IF EXISTS istore_max_transfn(internal, bigistore);
----
