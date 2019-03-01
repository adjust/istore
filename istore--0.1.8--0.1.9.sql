CREATE FUNCTION join(VARIADIC istores bigistore[])
RETURNS SETOF record
AS 'istore','join'
LANGUAGE C STRICT IMMUTABLE;
