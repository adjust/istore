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
