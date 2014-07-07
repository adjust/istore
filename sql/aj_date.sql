CREATE TYPE aj_date;

CREATE FUNCTION aj_date_in(cstring)
    RETURNS aj_date
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_out(aj_date)
    RETURNS cstring
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE aj_date (
    internallength = 2,
    input = aj_date_in,
    output = aj_date_out,
    alignment = smallint
);

CREATE FUNCTION aj_date_lt(aj_date,aj_date) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_le(aj_date,aj_date) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_eq(aj_date,aj_date) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_ge(aj_date,aj_date) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_gt(aj_date,aj_date) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_to_date(aj_date) RETURNS date
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION date_to_aj_date(date) RETURNS aj_date
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_add(aj_date, integer) RETURNS aj_date
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_add(integer, aj_date) RETURNS aj_date
    AS 'SELECT aj_date_add($2, $1);'
    LANGUAGE SQL IMMUTABLE STRICT;

CREATE FUNCTION aj_date_subtract(aj_date, integer) RETURNS aj_date
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_date_diff(aj_date, aj_date) RETURNS integer
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR + (
    leftarg    = aj_date,
    rightarg   = integer,
    procedure  = aj_date_add,
    commutator = +
);

CREATE OPERATOR + (
    leftarg   = integer,
    rightarg    = aj_date,
    procedure  = aj_date_add,
    commutator = +
);

CREATE OPERATOR - (
    leftarg    = aj_date,
    rightarg   = integer,
    procedure  = aj_date_subtract
);

CREATE OPERATOR - (
    leftarg    = aj_date,
    rightarg   = aj_date,
    procedure  = aj_date_diff
);

CREATE OPERATOR < (
    leftarg = aj_date, rightarg = aj_date, procedure = aj_date_lt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR <= (
    leftarg = aj_date, rightarg = aj_date, procedure = aj_date_le,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR = (
    leftarg = aj_date, rightarg = aj_date, procedure = aj_date_eq,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR >= (
    leftarg = aj_date, rightarg = aj_date, procedure = aj_date_ge,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR > (
    leftarg = aj_date, rightarg = aj_date, procedure = aj_date_gt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE FUNCTION aj_date_cmp(aj_date,aj_date) RETURNS int4
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS aj_date_ops
    DEFAULT FOR TYPE aj_date USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       aj_date_cmp(aj_date,aj_date);

CREATE CAST (aj_date AS date)
    WITH FUNCTION aj_date_to_date(aj_date) AS IMPLICIT;

CREATE CAST (date AS aj_date)
    WITH FUNCTION date_to_aj_date(date) AS IMPLICIT;
