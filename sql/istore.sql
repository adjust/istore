CREATE TYPE istore;

CREATE FUNCTION istore_in(cstring)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_out(istore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE istore (
    INPUT = istore_in,
    OUTPUT = istore_out
);

CREATE TYPE device_istore;

CREATE FUNCTION device_istore_in(cstring)
    RETURNS device_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_out(device_istore)
    RETURNS cstring
    AS '$libdir/istore.so', 'istore_out'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE device_istore (
    INPUT = device_istore_in,
    OUTPUT = device_istore_out
);

CREATE FUNCTION device_istore_to_istore(device_istore)
    RETURNS istore
    AS '$libdir/istore.so', 'type_istore_to_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (device_istore AS istore)
    WITH FUNCTION device_istore_to_istore(device_istore) AS IMPLICIT;

CREATE FUNCTION istore_to_device_istore(istore)
    RETURNS device_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (istore AS device_istore)
    WITH FUNCTION istore_to_device_istore(istore) AS IMPLICIT;

CREATE TYPE country_istore;

CREATE FUNCTION country_istore_in(cstring)
    RETURNS country_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_out(country_istore)
    RETURNS cstring
    AS '$libdir/istore.so', 'istore_out'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE country_istore (
    INPUT = country_istore_in,
    OUTPUT = country_istore_out
);

CREATE FUNCTION country_istore_to_istore(country_istore)
    RETURNS istore
    AS '$libdir/istore.so', 'type_istore_to_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (country_istore AS istore)
    WITH FUNCTION country_istore_to_istore(country_istore) AS IMPLICIT;

CREATE FUNCTION istore_to_country_istore(istore)
    RETURNS country_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (istore AS country_istore)
    WITH FUNCTION istore_to_country_istore(istore) AS IMPLICIT;

CREATE TYPE os_name_istore;

CREATE FUNCTION os_name_istore_in(cstring)
    RETURNS os_name_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_out(os_name_istore)
    RETURNS cstring
    AS '$libdir/istore.so', 'istore_out'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE os_name_istore (
    INPUT = os_name_istore_in,
    OUTPUT = os_name_istore_out
);

CREATE FUNCTION os_name_istore_to_istore(os_name_istore)
    RETURNS istore
    AS '$libdir/istore.so', 'type_istore_to_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (os_name_istore AS istore)
    WITH FUNCTION os_name_istore_to_istore(os_name_istore) AS IMPLICIT;

CREATE FUNCTION istore_to_os_name_istore(istore)
    RETURNS os_name_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (istore AS os_name_istore)
    WITH FUNCTION istore_to_os_name_istore(istore) AS IMPLICIT;

CREATE FUNCTION exist(istore, integer)
    RETURNS boolean
    AS '$libdir/istore.so', 'is_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(istore, integer)
    RETURNS bigint
    AS '$libdir/istore.so', 'is_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'is_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'is_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'is_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'is_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'is_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'is_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_from_array(integer[])
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_agg(istore[])
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_agg_finalfn(internal)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_sum_up(istore)
    RETURNS bigint
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_array_add(integer[], integer[])
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE SUM (
    sfunc = array_agg_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn
);

