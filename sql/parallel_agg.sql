CREATE FUNCTION istore_serial(internal)
    RETURNS bytea
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_deserial(bytea, internal)
    RETURNS internal
    AS 'istore', 'istore_deserial'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_sum_combine(internal, internal)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION istore_max_combine(internal, internal)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION istore_min_combine(internal, internal)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE PARALLEL SAFE;
