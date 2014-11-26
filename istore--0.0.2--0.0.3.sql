----functions----
CREATE OR REPLACE FUNCTION divide(country_istore, bigint)
 RETURNS country_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide_int8$function$;
----
CREATE OR REPLACE FUNCTION divide(country_istore, integer)
 RETURNS country_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide_integer$function$;
----
CREATE OR REPLACE FUNCTION divide(country_istore, country_istore)
 RETURNS country_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide$function$;
----
CREATE OR REPLACE FUNCTION fill_gaps(istore, integer, bigint DEFAULT 0)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE
AS '$libdir/istore.so', $function$istore_fill_gaps$function$;
----
CREATE OR REPLACE FUNCTION istore(integer[], integer[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$istore_array_add$function$;
----
CREATE OR REPLACE FUNCTION istore(integer[], bigint[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$istore_array_add$function$;
----
CREATE OR REPLACE FUNCTION divide(istore, bigint)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide_int8$function$;
----
CREATE OR REPLACE FUNCTION divide(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide_integer$function$;
----
CREATE OR REPLACE FUNCTION divide(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide$function$;
----
CREATE OR REPLACE FUNCTION each("is" istore, OUT key integer, OUT value bigint)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$istore_each$function$;
----
CREATE OR REPLACE FUNCTION divide(device_istore, bigint)
 RETURNS device_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide_int8$function$;
----
CREATE OR REPLACE FUNCTION divide(device_istore, integer)
 RETURNS device_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide_integer$function$;
----
CREATE OR REPLACE FUNCTION divide(device_istore, device_istore)
 RETURNS device_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide$function$;
----
CREATE OR REPLACE FUNCTION divide(os_name_istore, bigint)
 RETURNS os_name_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide_int8$function$;
----
CREATE OR REPLACE FUNCTION divide(os_name_istore, integer)
 RETURNS os_name_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide_integer$function$;
----
CREATE OR REPLACE FUNCTION divide(os_name_istore, os_name_istore)
 RETURNS os_name_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$is_divide$function$;
----operators----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = istore,
  RIGHTARG = int4
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = istore,
  RIGHTARG = istore
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = istore,
  RIGHTARG = int8
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = device_istore,
  RIGHTARG = int8
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = device_istore,
  RIGHTARG = int4
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = device_istore,
  RIGHTARG = device_istore
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = country_istore,
  RIGHTARG = int8
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = country_istore,
  RIGHTARG = int4
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = os_name_istore,
  RIGHTARG = int8
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = os_name_istore,
  RIGHTARG = int4
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = os_name_istore,
  RIGHTARG = os_name_istore
);

----
CREATE OPERATOR / (
  PROCEDURE = public.divide,
  LEFTARG = country_istore,
  RIGHTARG = country_istore
);
