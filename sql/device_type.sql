--require istore
CREATE TYPE device_type;

CREATE FUNCTION device_type_in(cstring)
    RETURNS device_type
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_out(device_type)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_recv(internal)
    RETURNS device_type
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_send(device_type)
    RETURNS bytea
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE device_type (
    internallength = 1,
    input = device_type_in,
    output = device_type_out,
    receive = device_type_recv,
    send = device_type_send,
    alignment = char,
    PASSEDBYVALUE
);

CREATE FUNCTION device_type_lt(device_type,device_type) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_le(device_type,device_type) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_eq(device_type,device_type) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_neq(device_type,device_type) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_ge(device_type,device_type) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_type_gt(device_type,device_type) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
    leftarg = device_type, rightarg = device_type, procedure = device_type_lt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR <= (
    leftarg = device_type, rightarg = device_type, procedure = device_type_le,
    commutator = >= , negator = > ,
    restrict = scalarltsel, join = scalarltjoinsel);

CREATE OPERATOR = (
    leftarg = device_type, rightarg = device_type, procedure = device_type_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel
);

CREATE OPERATOR <> (
    leftarg = device_type, rightarg = device_type, procedure = device_type_neq,
    commutator = <> , negator = = ,
    restrict = neqsel, join = neqjoinsel
);

CREATE OPERATOR >= (
    leftarg = device_type, rightarg = device_type, procedure = device_type_ge,
    commutator = <= , negator = < ,
    restrict = scalargtsel, join = scalargtjoinsel
);

CREATE OPERATOR > (
    leftarg = device_type, rightarg = device_type, procedure = device_type_gt,
    commutator = < , negator = <= ,
    restrict = scalargtsel, join = scalargtjoinsel
);

CREATE FUNCTION device_type_cmp(device_type,device_type) RETURNS int4
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS device_type_ops
    DEFAULT FOR TYPE device_type USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       device_type_cmp(device_type,device_type);
CREATE TYPE device_istore;

CREATE FUNCTION device_istore_in(cstring)
    RETURNS device_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_out(device_istore)
    RETURNS cstring
    AS '$libdir/istore.so', 'istore_out'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_recv(internal)
    RETURNS device_istore
    AS '$libdir/istore.so', 'istore_recv'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_send(device_istore)
    RETURNS bytea
    AS '$libdir/istore.so', 'istore_send'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE device_istore (
    INPUT = device_istore_in,
    OUTPUT = device_istore_out,
    receive = device_istore_recv,
    send = device_istore_send
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

CREATE FUNCTION exist(device_istore, cstring)
    RETURNS boolean
    AS '$libdir/istore.so', 'is_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(device_istore, cstring)
    RETURNS bigint
    AS '$libdir/istore.so', 'is_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(device_istore, device_istore)
    RETURNS device_istore
    AS '$libdir/istore.so', 'is_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(device_istore, integer)
    RETURNS device_istore
    AS '$libdir/istore.so', 'is_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(device_istore, device_istore)
    RETURNS device_istore
    AS '$libdir/istore.so', 'is_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(device_istore, integer)
    RETURNS device_istore
    AS '$libdir/istore.so', 'is_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(device_istore, device_istore)
    RETURNS device_istore
    AS '$libdir/istore.so', 'is_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(device_istore, integer)
    RETURNS device_istore
    AS '$libdir/istore.so', 'is_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_from_array(text[])
    RETURNS device_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_from_array(device_type[])
    RETURNS device_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_agg(device_istore[])
    RETURNS device_istore
    AS '$libdir/istore.so', 'istore_agg'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_agg_finalfn(internal)
    RETURNS device_istore
    AS '$libdir/istore.so', 'istore_agg_finalfn'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION device_istore_sum_up(device_istore)
    RETURNS bigint
    AS '$libdir/istore.so', 'istore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

--CREATE FUNCTION device_istore_array_add(integer[], integer[])
--    RETURNS device_istore
--    AS '$libdir/istore.so',
--    LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE SUM (
    sfunc = add,
    basetype = device_istore,
    stype = device_istore
);

CREATE OPERATOR -> (
    leftarg   = device_istore,
    rightarg  = cstring,
    procedure = fetchval
);

CREATE OPERATOR ? (
    leftarg   = device_istore,
    rightarg  = cstring,
    procedure = exist
);

CREATE OPERATOR + (
    leftarg   = device_istore,
    rightarg  = device_istore,
    procedure = add
);

CREATE OPERATOR + (
    leftarg   = device_istore,
    rightarg  = integer,
    procedure = add
);

CREATE OPERATOR - (
    leftarg   = device_istore,
    rightarg  = device_istore,
    procedure = subtract
);

CREATE OPERATOR - (
    leftarg   = device_istore,
    rightarg  = integer,
    procedure = subtract
);

CREATE OPERATOR * (
    leftarg   = device_istore,
    rightarg  = device_istore,
    procedure = multiply
);

CREATE OPERATOR * (
    leftarg   = device_istore,
    rightarg  = integer,
    procedure = multiply
);
