--require istore
CREATE TYPE country;

CREATE FUNCTION country_in(cstring)
    RETURNS country
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_out(country)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_recv(internal)
    RETURNS country
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_send(country)
    RETURNS bytea
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE country (
    internallength = 1,
    input = country_in,
    output = country_out,
    send = country_send,
    receive = country_recv,
    alignment = char,
    PASSEDBYVALUE
);

CREATE FUNCTION country_lt(country,country) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_le(country,country) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_eq(country,country) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_ge(country,country) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_gt(country,country) RETURNS bool
    AS '$libdir/istore.so'
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
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS country_ops
    DEFAULT FOR TYPE country USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       country_cmp(country,country);

CREATE TYPE country_istore;

CREATE FUNCTION country_istore_in(cstring)
    RETURNS country_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_out(country_istore)
    RETURNS cstring
    AS '$libdir/istore.so', 'istore_out'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_send(country_istore)
    RETURNS bytea
    AS '$libdir/istore.so', 'istore_send'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_recv(internal)
    RETURNS country_istore
    AS '$libdir/istore.so', 'istore_recv'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE country_istore (
    INPUT = country_istore_in,
    OUTPUT = country_istore_out,
    receive = country_istore_recv,
    send = country_istore_send
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

CREATE FUNCTION exist(country_istore, cstring)
    RETURNS boolean
    AS '$libdir/istore.so', 'is_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(country_istore, cstring)
    RETURNS bigint
    AS '$libdir/istore.so', 'is_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(country_istore, country_istore)
    RETURNS country_istore
    AS '$libdir/istore.so', 'is_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(country_istore, integer)
    RETURNS country_istore
    AS '$libdir/istore.so', 'is_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(country_istore, country_istore)
    RETURNS country_istore
    AS '$libdir/istore.so', 'is_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(country_istore, integer)
    RETURNS country_istore
    AS '$libdir/istore.so', 'is_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(country_istore, country_istore)
    RETURNS country_istore
    AS '$libdir/istore.so', 'is_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(country_istore, integer)
    RETURNS country_istore
    AS '$libdir/istore.so', 'is_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_from_array(text[])
    RETURNS country_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_from_array(country[])
    RETURNS country_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_agg(country_istore[])
    RETURNS country_istore
    AS '$libdir/istore.so', 'istore_agg'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_agg_finalfn(internal)
    RETURNS country_istore
    AS '$libdir/istore.so', 'istore_agg_finalfn'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_istore_sum_up(country_istore)
    RETURNS bigint
    AS '$libdir/istore.so', 'istore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

--CREATE FUNCTION country_istore_array_add(integer[], integer[])
--    RETURNS country_istore
--    AS '$libdir/istore.so'
--    LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE SUM (
    sfunc = array_agg_transfn,
    basetype = country_istore,
    stype = internal,
    finalfunc = country_istore_agg_finalfn
);

CREATE OPERATOR -> (
    leftarg   = country_istore,
    rightarg  = cstring,
    procedure = fetchval
);

CREATE OPERATOR ? (
    leftarg   = country_istore,
    rightarg  = cstring,
    procedure = exist
);

CREATE OPERATOR + (
    leftarg   = country_istore,
    rightarg  = country_istore,
    procedure = add
);

CREATE OPERATOR + (
    leftarg   = country_istore,
    rightarg  = integer,
    procedure = add
);

CREATE OPERATOR - (
    leftarg   = country_istore,
    rightarg  = country_istore,
    procedure = subtract
);

CREATE OPERATOR - (
    leftarg   = country_istore,
    rightarg  = integer,
    procedure = subtract
);

CREATE OPERATOR * (
    leftarg   = country_istore,
    rightarg  = country_istore,
    procedure = multiply
);

CREATE OPERATOR * (
    leftarg   = country_istore,
    rightarg  = integer,
    procedure = multiply
);
