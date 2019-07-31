CREATE FUNCTION row_to_istore(record)
    RETURNS istore
    AS 'istore', 'row_to_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION row_to_bigistore(record)
    RETURNS bigistore
    AS 'istore', 'row_to_bigistore'
    LANGUAGE C IMMUTABLE STRICT;
