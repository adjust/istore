CREATE TYPE aj_time;

CREATE FUNCTION aj_time_in(cstring)
    RETURNS aj_time
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_time_out(aj_time)
    RETURNS cstring
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE aj_time (
    internallength = 4,
    input = aj_time_in,
    output = aj_time_out,
    alignment = integer
);

CREATE FUNCTION aj_time_lt(aj_time,aj_time) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_time_le(aj_time,aj_time) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_time_eq(aj_time,aj_time) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_time_ge(aj_time,aj_time) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_time_gt(aj_time,aj_time) RETURNS bool
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_time_to_timestamp(aj_time) RETURNS timestamp
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION timestamp_to_aj_time(timestamp) RETURNS aj_time
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION aj_time_to_date(aj_time) RETURNS date
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION date_part(cstring, aj_time) RETURNS integer
    AS '$libdir/aj-types.so', 'aj_time_date_part'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
    leftarg = aj_time, rightarg = aj_time, procedure = aj_time_lt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR <= (
    leftarg = aj_time, rightarg = aj_time, procedure = aj_time_le,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR = (
    leftarg = aj_time, rightarg = aj_time, procedure = aj_time_eq,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR >= (
    leftarg = aj_time, rightarg = aj_time, procedure = aj_time_ge,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR > (
    leftarg = aj_time, rightarg = aj_time, procedure = aj_time_gt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE FUNCTION aj_time_cmp(aj_time,aj_time) RETURNS int4
    AS '$libdir/aj-types.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS aj_time_ops
    DEFAULT FOR TYPE aj_time USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       aj_time_cmp(aj_time,aj_time);

CREATE CAST (aj_time AS timestamp)
     WITH FUNCTION aj_time_to_timestamp(aj_time) AS IMPLICIT;

CREATE CAST (timestamp AS aj_time)
     WITH FUNCTION timestamp_to_aj_time(timestamp) AS IMPLICIT;

CREATE CAST (aj_time AS date)
     WITH FUNCTION aj_time_to_date(aj_time) AS IMPLICIT;
