--source file sql/istore.sql
CREATE TYPE istore;

CREATE FUNCTION istore_in(cstring)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_out(istore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_send(istore)
    RETURNS bytea
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_recv(internal)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE istore (
    INPUT = istore_in,
    OUTPUT = istore_out,
    receive = istore_recv,
    send = istore_send
);

CREATE FUNCTION exist(istore, integer)
    RETURNS boolean
    AS '$libdir/istore.so', 'is_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(istore, integer)
    RETURNS bigint
    AS '$libdir/istore.so', 'is_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION each(IN is istore,
    OUT key int,
    OUT value bigint)
RETURNS SETOF record
AS '$libdir/istore.so','istore_each'
LANGUAGE C STRICT IMMUTABLE;

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

CREATE FUNCTION istore(integer[], bigint[])
    RETURNS istore
    AS '$libdir/istore.so', 'istore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore(integer[], integer[])
    RETURNS istore
    AS '$libdir/istore.so', 'istore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fill_gaps(istore, integer, bigint DEFAULT 0)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_fill_gaps'
    LANGUAGE C IMMUTABLE STRICT;



CREATE AGGREGATE SUM (
    sfunc = array_agg_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn
);

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
 
--source file sql/country.sql
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

CREATE FUNCTION country_neq(country,country) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_ge(country,country) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION country_gt(country,country) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION hashcountry(country) RETURNS integer
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
    leftarg = country, rightarg = country, procedure = country_lt,
    commutator = > , negator = >= ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR <= (
    leftarg = country, rightarg = country, procedure = country_le,
    commutator = >= , negator = > ,
    restrict = scalarltsel, join = scalarltjoinsel );

CREATE OPERATOR = (
    leftarg = country, rightarg = country, procedure = country_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel, HASHES, MERGES
);

CREATE OPERATOR <> (
    leftarg = country, rightarg = country, procedure = country_neq,
    commutator = <> , negator = = ,
    restrict = neqsel, join = neqjoinsel
);

CREATE OPERATOR >= (
    leftarg = country, rightarg = country, procedure = country_ge,
    commutator = <= , negator = < ,
    restrict = scalargtsel, join = scalargtjoinsel
);

CREATE OPERATOR > (
    leftarg = country, rightarg = country, procedure = country_gt,
    commutator = < , negator = <= ,
    restrict = scalargtsel, join = scalargtjoinsel
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

CREATE OPERATOR CLASS country_ops
    DEFAULT FOR TYPE country USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hashcountry(country);

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
 
--source file sql/os_name.sql
CREATE TYPE os_name;

CREATE FUNCTION os_name_in(cstring)
    RETURNS os_name
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_out(os_name)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_recv(internal)
    RETURNS os_name
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_send(os_name)
    RETURNS bytea
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE os_name (
    internallength = 1,
    input = os_name_in,
    output = os_name_out,
    receive = os_name_recv,
    send = os_name_send,
    alignment = char,
    PASSEDBYVALUE
);

CREATE FUNCTION hashos_name(os_name) RETURNS integer
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_lt(os_name,os_name) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_le(os_name,os_name) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_eq(os_name,os_name) RETURNS bool
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_neq(os_name,os_name) RETURNS bool
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
    commutator = >= , negator = > ,
    restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR = (
    leftarg = os_name, rightarg = os_name, procedure = os_name_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel, HASHES, MERGES
);

CREATE OPERATOR <> (
    leftarg = os_name, rightarg = os_name, procedure = os_name_neq,
    commutator = <> , negator = = ,
    restrict = neqsel, join = neqjoinsel
);

CREATE OPERATOR >= (
    leftarg = os_name, rightarg = os_name, procedure = os_name_ge,
    commutator = <= , negator = < ,
    restrict = scalargtsel, join = scalargtjoinsel
);

CREATE OPERATOR > (
    leftarg = os_name, rightarg = os_name, procedure = os_name_gt,
    commutator = < , negator = <= ,
    restrict = scalargtsel, join = scalargtjoinsel
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

CREATE OPERATOR CLASS os_name_ops
    DEFAULT FOR TYPE os_name USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hashos_name(os_name);

CREATE TYPE os_name_istore;

CREATE FUNCTION os_name_istore_in(cstring)
    RETURNS os_name_istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_out(os_name_istore)
    RETURNS cstring
    AS '$libdir/istore.so', 'istore_out'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_recv(internal)
    RETURNS os_name_istore
    AS '$libdir/istore.so', 'istore_recv'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION os_name_istore_send(os_name_istore)
    RETURNS bytea
    AS '$libdir/istore.so', 'istore_send'
    LANGUAGE C IMMUTABLE STRICT;


CREATE TYPE os_name_istore (
    INPUT = os_name_istore_in,
    OUTPUT = os_name_istore_out,
    receive = os_name_istore_recv,
    send = os_name_istore_send
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
 
--source file sql/device_type.sql
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

CREATE FUNCTION hashdevice_type(device_type) RETURNS integer
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

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
    restrict = eqsel, join = eqjoinsel, HASHES, MERGES
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

CREATE OPERATOR CLASS device_type_ops
    DEFAULT FOR TYPE device_type USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hashdevice_type(device_type);


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
    sfunc = array_agg_transfn,
    basetype = device_istore,
    stype = internal,
    finalfunc = device_istore_agg_finalfn
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
 
--source file sql/cistore.sql
CREATE TYPE cistore;

CREATE FUNCTION cistore_in(cstring)
    RETURNS cistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION cistore_out(cistore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE cistore (
    INPUT = cistore_in,
    OUTPUT = cistore_out
);

CREATE FUNCTION cistore(country, device_type, os_name, bigint)
    RETURNS cistore
    AS '$libdir/istore.so', 'cistore_from_types'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION cistore(country, device_type, os_name, smallint, bigint)
    RETURNS cistore
    AS '$libdir/istore.so', 'cistore_cohort_from_types'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(cistore, cistore)
    RETURNS cistore
    AS '$libdir/istore.so', 'is_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR + (
    leftarg   = cistore,
    rightarg  = cistore,
    procedure = add
);
 
