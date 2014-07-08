
CREATE TYPE country;

CREATE FUNCTION country_in(cstring)
    RETURNS country
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_out(country)
    RETURNS cstring
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE country (
    internallength = 1,
    input = country_in,
    output = country_out,
    alignment = char
);

CREATE FUNCTION country_lt(country,country) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_le(country,country) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_eq(country,country) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_ge(country,country) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_gt(country,country) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
    leftarg = country, rightarg = country, procedure = country_lt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR <= (
    leftarg = country, rightarg = country, procedure = country_le,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR = (
    leftarg = country, rightarg = country, procedure = country_eq,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR >= (
    leftarg = country, rightarg = country, procedure = country_ge,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR > (
    leftarg = country, rightarg = country, procedure = country_gt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE FUNCTION country_cmp(country,country) RETURNS int4
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS country_ops
    DEFAULT FOR TYPE country USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       country_cmp(country,country);
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

CREATE TYPE os_name;

CREATE FUNCTION os_name_in(cstring)
    RETURNS os_name
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_out(os_name)
    RETURNS cstring
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE os_name (
    internallength = 1,
    input = os_name_in,
    output = os_name_out,
    alignment = char
);

CREATE FUNCTION os_name_lt(os_name,os_name) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_le(os_name,os_name) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_eq(os_name,os_name) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_ge(os_name,os_name) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_gt(os_name,os_name) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
    leftarg = os_name, rightarg = os_name, procedure = os_name_lt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR <= (
    leftarg = os_name, rightarg = os_name, procedure = os_name_le,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR = (
    leftarg = os_name, rightarg = os_name, procedure = os_name_eq,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR >= (
    leftarg = os_name, rightarg = os_name, procedure = os_name_ge,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR > (
    leftarg = os_name, rightarg = os_name, procedure = os_name_gt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE FUNCTION os_name_cmp(os_name,os_name) RETURNS int4
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS os_name_ops
    DEFAULT FOR TYPE os_name USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       os_name_cmp(os_name,os_name);
CREATE TYPE device_type;

CREATE FUNCTION device_type_in(cstring)
    RETURNS device_type
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_out(device_type)
    RETURNS cstring
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE device_type (
    internallength = 1,
    input = device_type_in,
    output = device_type_out,
    alignment = char
);

CREATE FUNCTION device_type_lt(device_type,device_type) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_le(device_type,device_type) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_eq(device_type,device_type) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_ge(device_type,device_type) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_gt(device_type,device_type) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
    leftarg = device_type, rightarg = device_type, procedure = device_type_lt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR <= (
    leftarg = device_type, rightarg = device_type, procedure = device_type_le,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR = (
    leftarg = device_type, rightarg = device_type, procedure = device_type_eq,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR >= (
    leftarg = device_type, rightarg = device_type, procedure = device_type_ge,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR > (
    leftarg = device_type, rightarg = device_type, procedure = device_type_gt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE FUNCTION device_type_cmp(device_type,device_type) RETURNS int4
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS device_type_ops
    DEFAULT FOR TYPE device_type USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       device_type_cmp(device_type,device_type);
CREATE OPERATOR -> (
    leftarg   = istore,
    rightarg  = integer,
    procedure = fetchval
);

CREATE OPERATOR ? (
    leftarg   = istore,
    rightarg  = integer,
    procedure = exist
);

CREATE OPERATOR + (
    leftarg   = istore,
    rightarg  = istore,
    procedure = add
);

CREATE OPERATOR + (
    leftarg   = istore,
    rightarg  = integer,
    procedure = add
);

CREATE OPERATOR - (
    leftarg   = istore,
    rightarg  = istore,
    procedure = subtract
);

CREATE OPERATOR - (
    leftarg   = istore,
    rightarg  = integer,
    procedure = subtract
);

CREATE OPERATOR * (
    leftarg   = istore,
    rightarg  = istore,
    procedure = multiply
);

CREATE OPERATOR * (
    leftarg   = istore,
    rightarg  = integer,
    procedure = multiply
);
