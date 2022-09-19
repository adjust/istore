CREATE FUNCTION max_value(istore)
    RETURNS integer
    AS 'istore', 'istore_max_value'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION max_value(bigistore)
    RETURNS bigint
    AS 'istore', 'bigistore_max_value'
    LANGUAGE C IMMUTABLE STRICT;
