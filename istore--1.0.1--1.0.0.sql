----operators----
DROP OPERATOR IF EXISTS = (bigistore, bigistore);
----
DROP OPERATOR IF EXISTS <> (bigistore, bigistore);
----
DROP OPERATOR IF EXISTS <> (istore, istore);
----
DROP OPERATOR IF EXISTS = (istore, istore);
----functions----
DROP FUNCTION IF EXISTS istore_eq(istore, istore);
----
DROP FUNCTION IF EXISTS istore_ne(istore, istore);
----
DROP FUNCTION IF EXISTS bigistore_ne(bigistore, bigistore);
----
DROP FUNCTION IF EXISTS bigistore_eq(bigistore, bigistore);
