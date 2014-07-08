
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
