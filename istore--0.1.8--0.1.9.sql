CREATE FUNCTION istore_in_range(istore, int, int)
    RETURNS boolean
    AS 'istore', 'istore_in_range'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_less_than(istore, int)
    RETURNS boolean
    AS 'istore', 'istore_less_than'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_less_than_or_equal(istore, int)
    RETURNS boolean
    AS 'istore', 'istore_less_than_or_equal'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_greater_than(istore, int)
    RETURNS boolean
    AS 'istore', 'istore_greater_than'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_greater_than_or_equal(istore, int)
    RETURNS boolean
    AS 'istore', 'istore_greater_than_or_equal'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_floor(istore, int)
    RETURNS istore
    AS 'istore', 'istore_floor'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_ceiling(istore, int)
    RETURNS istore
    AS 'istore', 'istore_ceiling'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_in_range(bigistore, bigint, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_in_range'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_less_than(bigistore, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_less_than'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_less_than_or_equal(bigistore, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_less_than_or_equal'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_greater_than(bigistore, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_greater_than'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_greater_than_or_equal(bigistore, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_greater_than_or_equal'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_floor(bigistore, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_floor'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_ceiling(bigistore, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_ceiling'
    LANGUAGE C IMMUTABLE STRICT;
