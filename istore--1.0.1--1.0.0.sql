----operators----
DROP OPERATOR IF EXISTS = (bigistore, bigistore);
----
DROP OPERATOR IF EXISTS <> (bigistore, bigistore);
----
DROP OPERATOR IF EXISTS <> (istore, istore);
----
DROP OPERATOR IF EXISTS = (istore, istore);
----functions----

-- We can't replace the fetchval function without dropping -> operator
DROP OPERATOR -> (bigistore, integer);
DROP FUNCTION IF EXISTS fetchval(bigistore, integer);
CREATE OR REPLACE FUNCTION fetchval(bigistore, integer)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_fetchval$function$;
CREATE OPERATOR -> (
    leftarg   = bigistore,
    rightarg  = integer,
    procedure = fetchval
);

----
DROP FUNCTION IF EXISTS istore_eq(istore, istore);
----
DROP FUNCTION IF EXISTS istore_ne(istore, istore);
----
DROP FUNCTION IF EXISTS bigistore_ne(bigistore, bigistore);
----
DROP FUNCTION IF EXISTS bigistore_eq(bigistore, bigistore);
