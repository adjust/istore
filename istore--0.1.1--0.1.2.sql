-- We can't replace the fetchval function without dropping -> operator
DROP OPERATOR -> (bigistore, integer);
DROP FUNCTION IF EXISTS fetchval(bigistore, integer);
CREATE OR REPLACE FUNCTION fetchval(bigistore, integer)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_fetchval$function$;
CREATE OPERATOR -> (
    leftarg   = bigistore,
    rightarg  = integer,
    procedure = fetchval
);
