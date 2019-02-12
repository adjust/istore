CREATE FUNCTION mjoin(VARIADIC istores bigistore[])
RETURNS SETOF record
AS 'istore','mjoin'
LANGUAGE C STRICT IMMUTABLE;
