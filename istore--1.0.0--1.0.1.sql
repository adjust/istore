----functions----

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

----
CREATE OR REPLACE FUNCTION istore_eq(istore, istore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_eq$function$;
----
CREATE OR REPLACE FUNCTION istore_ne(istore, istore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_ne$function$;
----
CREATE OR REPLACE FUNCTION bigistore_ne(bigistore, bigistore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_ne$function$;
----
CREATE OR REPLACE FUNCTION bigistore_eq(bigistore, bigistore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_eq$function$;
----operators----
  CREATE OPERATOR = (
    PROCEDURE = bigistore_eq,
    LEFTARG = bigistore,
  RIGHTARG = bigistore,
  COMMUTATOR = =,
  NEGATOR = <>,
  RESTRICT = eqsel
  );

----
  CREATE OPERATOR <> (
    PROCEDURE = bigistore_ne,
    LEFTARG = bigistore,
  RIGHTARG = bigistore,
  COMMUTATOR = <>,
  NEGATOR = =,
  RESTRICT = neqsel
  );

----
  CREATE OPERATOR <> (
    PROCEDURE = istore_ne,
    LEFTARG = istore,
  RIGHTARG = istore,
  COMMUTATOR = <>,
  NEGATOR = =,
  RESTRICT = neqsel
  );

----
  CREATE OPERATOR = (
    PROCEDURE = istore_eq,
    LEFTARG = istore,
  RIGHTARG = istore,
  COMMUTATOR = =,
  NEGATOR = <>,
  RESTRICT = eqsel
  );
