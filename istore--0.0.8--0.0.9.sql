----functions----
CREATE OR REPLACE FUNCTION is_val_smaller(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_val_smaller$function$;
----
CREATE OR REPLACE FUNCTION is_val_larger(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_val_larger$function$;
----aggregates----
CREATE AGGREGATE max(istore) (
  SFUNC = is_val_larger,
  STYPE = istore
);

----
CREATE AGGREGATE min(istore) (
  SFUNC = is_val_smaller,
  STYPE = istore
);
