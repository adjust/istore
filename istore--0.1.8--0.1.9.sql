CREATE FUNCTION istore_sum_floor_transfn(internal, istore, int)
    RETURNS internal
    AS 'istore' ,'istore_sum_floor_transfn'
    LANGUAGE C IMMUTABLE;

CREATE AGGREGATE SUM_FLOOR(istore, int) (
    sfunc = istore_sum_floor_transfn,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

CREATE FUNCTION istore_sum_floor_transfn(internal, bigistore, bigint)
    RETURNS internal
    AS 'istore' ,'bigistore_sum_floor_transfn'
    LANGUAGE C IMMUTABLE;

CREATE AGGREGATE SUM_FLOOR(bigistore, bigint) (
    sfunc = istore_sum_floor_transfn,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

DO $$
DECLARE version_num integer;
BEGIN
  SELECT current_setting('server_version_num') INTO STRICT version_num;
  IF version_num > 90600 THEN
	EXECUTE $E$ ALTER FUNCTION istore_sum_floor_transfn(internal, istore, int) PARALLEL SAFE						  $E$;
	EXECUTE $E$ ALTER FUNCTION istore_sum_floor_transfn(internal, bigistore, bigint) PARALLEL SAFE					  $E$;
	EXECUTE $E$ DROP AGGREGATE SUM_FLOOR (istore, int) $E$;
	EXECUTE $E$ DROP AGGREGATE SUM_FLOOR (bigistore, bigint) $E$;

    EXECUTE $E$ CREATE AGGREGATE SUM_FLOOR (istore, int) (
        sfunc = istore_sum_floor_transfn,
        stype = internal,
        finalfunc = bigistore_agg_finalfn,
        combinefunc = istore_agg_sum_combine,
        serialfunc = istore_agg_serial,
        deserialfunc = istore_agg_deserial,
        parallel = SAFE
    ) $E$ ;

    EXECUTE $E$ CREATE AGGREGATE SUM_FLOOR (bigistore, bigint) (
        sfunc = istore_sum_floor_transfn,
        stype = internal,
        finalfunc = bigistore_agg_finalfn,
        combinefunc = istore_agg_sum_combine,
        serialfunc = istore_agg_serial,
        deserialfunc = istore_agg_deserial,
        parallel = SAFE
    )  $E$;
  END IF;
END;
$$;
