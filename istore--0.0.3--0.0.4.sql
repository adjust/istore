----functions----
CREATE OR REPLACE FUNCTION istore_array_add(country[], integer[])
 RETURNS country_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$country_istore_array_add$function$;
----
CREATE OR REPLACE FUNCTION istore_array_add(device_type[], integer[])
 RETURNS device_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$device_type_istore_array_add$function$;
----
CREATE OR REPLACE FUNCTION istore_array_add(os_name[], integer[])
 RETURNS os_name_istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$os_name_istore_array_add$function$;
