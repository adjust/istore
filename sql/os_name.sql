CREATE TYPE os_name;

CREATE FUNCTION os_name_in(cstring)
    RETURNS os_name
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_out(os_name)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE os_name (
    internallength = 1,
    input = os_name_in,
    output = os_name_out,
    alignment = char
);

CREATE FUNCTION os_name_lt(os_name,os_name) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_le(os_name,os_name) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_eq(os_name,os_name) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_ge(os_name,os_name) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_gt(os_name,os_name) RETURNS bool
    AS '$libdir/istore.so'
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
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS os_name_ops
    DEFAULT FOR TYPE os_name USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       os_name_cmp(os_name,os_name);

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

CREATE FUNCTION exist(os_name_istore, cstring)
    RETURNS boolean
    AS '$libdir/istore.so', 'is_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(os_name_istore, cstring)
    RETURNS bigint
    AS '$libdir/istore.so', 'is_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(os_name_istore, os_name_istore)
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'is_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(os_name_istore, integer)
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'is_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(os_name_istore, os_name_istore)
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'is_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(os_name_istore, integer)
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'is_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(os_name_istore, os_name_istore)
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'is_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(os_name_istore, integer)
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'is_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_from_array(text[])
    RETURNS os_name_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_from_array(os_name[])
    RETURNS os_name_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_agg(os_name_istore[])
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'istore_agg'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_agg_finalfn(internal)
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'istore_agg_finalfn'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_sum_up(os_name_istore)
    RETURNS bigint
    AS '$libdir/istore.so', 'istore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

--CREATE FUNCTION os_name_istore_array_add(integer[], integer[])
--    RETURNS os_name_istore
--    AS '$libdir/istore.so'
--    LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE SUM (
    sfunc = array_agg_transfn,
    basetype = os_name_istore,
    stype = internal,
    finalfunc = os_name_istore_agg_finalfn
);

CREATE OPERATOR -> (
    leftarg   = os_name_istore,
    rightarg  = cstring,
    procedure = fetchval
);

CREATE OPERATOR ? (
    leftarg   = os_name_istore,
    rightarg  = cstring,
    procedure = exist
);

CREATE OPERATOR + (
    leftarg   = os_name_istore,
    rightarg  = os_name_istore,
    procedure = add
);

CREATE OPERATOR + (
    leftarg   = os_name_istore,
    rightarg  = integer,
    procedure = add
);

CREATE OPERATOR - (
    leftarg   = os_name_istore,
    rightarg  = os_name_istore,
    procedure = subtract
);

CREATE OPERATOR - (
    leftarg   = os_name_istore,
    rightarg  = integer,
    procedure = subtract
);

CREATE OPERATOR * (
    leftarg   = os_name_istore,
    rightarg  = os_name_istore,
    procedure = multiply
);

CREATE OPERATOR * (
    leftarg   = os_name_istore,
    rightarg  = integer,
    procedure = multiply
);
