--require types
--require istore
--require bigistore
--require casts

DO $$
DECLARE version_num integer;
BEGIN
  SELECT current_setting('server_version_num') INTO STRICT version_num;
  IF version_num > 90600 THEN
    EXECUTE $E$ ALTER FUNCTION istore_in(cstring) PARALLEL UNSAFE                                                       $E$;
    EXECUTE $E$ ALTER FUNCTION istore_out(istore) PARALLEL UNSAFE                                                       $E$;
    EXECUTE $E$ ALTER FUNCTION istore_send(istore) PARALLEL UNSAFE                                                      $E$;
    EXECUTE $E$ ALTER FUNCTION istore_recv(internal) PARALLEL UNSAFE                                                    $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore_in(cstring) PARALLEL UNSAFE                                                    $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore_out(bigistore) PARALLEL UNSAFE                                                 $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore_send(bigistore) PARALLEL UNSAFE                                                $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore_recv(internal) PARALLEL UNSAFE                                                 $E$;
    EXECUTE $E$ ALTER FUNCTION exist(istore, integer) PARALLEL UNSAFE                                                   $E$;
    EXECUTE $E$ ALTER FUNCTION fetchval(istore, integer) PARALLEL UNSAFE                                                $E$;
    EXECUTE $E$ ALTER FUNCTION each(istore) PARALLEL UNSAFE                                                             $E$;
    EXECUTE $E$ ALTER FUNCTION min_key(istore) PARALLEL UNSAFE                                                          $E$;
    EXECUTE $E$ ALTER FUNCTION max_key(istore) PARALLEL UNSAFE                                                          $E$;
    EXECUTE $E$ ALTER FUNCTION compact(istore) PARALLEL UNSAFE                                                          $E$;
    EXECUTE $E$ ALTER FUNCTION add(istore, istore) PARALLEL UNSAFE                                                      $E$;
    EXECUTE $E$ ALTER FUNCTION add(istore, integer) PARALLEL UNSAFE                                                     $E$;
    EXECUTE $E$ ALTER FUNCTION subtract(istore, istore) PARALLEL UNSAFE                                                 $E$;
    EXECUTE $E$ ALTER FUNCTION subtract(istore, integer) PARALLEL UNSAFE                                                $E$;
    EXECUTE $E$ ALTER FUNCTION multiply(istore, istore) PARALLEL UNSAFE                                                 $E$;
    EXECUTE $E$ ALTER FUNCTION multiply(istore, integer) PARALLEL UNSAFE                                                $E$;
    EXECUTE $E$ ALTER FUNCTION divide(istore, istore) PARALLEL UNSAFE                                                   $E$;
    EXECUTE $E$ ALTER FUNCTION divide(istore, integer) PARALLEL UNSAFE                                                  $E$;
    EXECUTE $E$ ALTER FUNCTION concat(istore, istore) PARALLEL UNSAFE                                                   $E$;
    EXECUTE $E$ ALTER FUNCTION istore(integer[]) PARALLEL UNSAFE                                                        $E$;
    EXECUTE $E$ ALTER FUNCTION sum_up(istore) PARALLEL UNSAFE                                                           $E$;
    EXECUTE $E$ ALTER FUNCTION sum_up(istore, integer) PARALLEL UNSAFE                                                  $E$;
    EXECUTE $E$ ALTER FUNCTION istore(integer[], integer[]) PARALLEL UNSAFE                                             $E$;
    EXECUTE $E$ ALTER FUNCTION fill_gaps(istore, integer, integer) PARALLEL UNSAFE                                      $E$;
    EXECUTE $E$ ALTER FUNCTION accumulate(istore) PARALLEL UNSAFE                                                       $E$;
    EXECUTE $E$ ALTER FUNCTION accumulate(istore, integer) PARALLEL UNSAFE                                              $E$;
    EXECUTE $E$ ALTER FUNCTION istore_seed(integer, integer, integer) PARALLEL UNSAFE                                   $E$;
    EXECUTE $E$ ALTER FUNCTION istore_val_larger(istore, istore) PARALLEL UNSAFE                                        $E$;
    EXECUTE $E$ ALTER FUNCTION istore_val_smaller(istore, istore) PARALLEL UNSAFE                                       $E$;
    EXECUTE $E$ ALTER FUNCTION akeys(istore) PARALLEL UNSAFE                                                            $E$;
    EXECUTE $E$ ALTER FUNCTION avals(istore) PARALLEL UNSAFE                                                            $E$;
    EXECUTE $E$ ALTER FUNCTION skeys(istore) PARALLEL UNSAFE                                                            $E$;
    EXECUTE $E$ ALTER FUNCTION svals(istore) PARALLEL UNSAFE                                                            $E$;
    EXECUTE $E$ ALTER FUNCTION istore_sum_transfn(internal, istore) PARALLEL UNSAFE                                     $E$;
    EXECUTE $E$ ALTER FUNCTION istore_min_transfn(internal, istore) PARALLEL UNSAFE                                     $E$;
    EXECUTE $E$ ALTER FUNCTION istore_max_transfn(internal, istore) PARALLEL UNSAFE                                     $E$;
    EXECUTE $E$ ALTER FUNCTION istore_agg_finalfn_pairs(internal) PARALLEL UNSAFE                                       $E$;
    EXECUTE $E$ ALTER FUNCTION istore_to_json(istore) PARALLEL UNSAFE                                                   $E$;
    EXECUTE $E$ ALTER FUNCTION istore_to_array(istore) PARALLEL UNSAFE                                                  $E$;
    EXECUTE $E$ ALTER FUNCTION istore_to_matrix(istore) PARALLEL UNSAFE                                                 $E$;
    EXECUTE $E$ ALTER FUNCTION slice(istore, integer[]) PARALLEL UNSAFE                                                 $E$;
    EXECUTE $E$ ALTER FUNCTION slice_array(istore, integer[]) PARALLEL UNSAFE                                           $E$;
    EXECUTE $E$ ALTER FUNCTION clamp_below(istore,int) PARALLEL UNSAFE                                                  $E$;
    EXECUTE $E$ ALTER FUNCTION clamp_above(istore,int) PARALLEL UNSAFE                                                  $E$;
    EXECUTE $E$ ALTER FUNCTION delete(istore,int) PARALLEL UNSAFE                                                       $E$;
    EXECUTE $E$ ALTER FUNCTION delete(istore,int[]) PARALLEL UNSAFE                                                     $E$;
    EXECUTE $E$ ALTER FUNCTION exists_all(istore,integer[]) PARALLEL UNSAFE                                             $E$;
    EXECUTE $E$ ALTER FUNCTION exists_any(istore,integer[]) PARALLEL UNSAFE                                             $E$;
    EXECUTE $E$ ALTER FUNCTION delete(istore, istore) PARALLEL UNSAFE                                                   $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore_agg_finalfn(internal) PARALLEL UNSAFE                                          $E$;
    EXECUTE $E$ ALTER FUNCTION istore_avl_transfn(internal, int, int) PARALLEL UNSAFE                                   $E$;
    EXECUTE $E$ ALTER FUNCTION istore_avl_finalfn(internal) PARALLEL UNSAFE                                             $E$;
    EXECUTE $E$ ALTER FUNCTION istore_length(istore) PARALLEL UNSAFE                                                    $E$;
    EXECUTE $E$ ALTER FUNCTION gin_extract_istore_key(internal, internal) PARALLEL UNSAFE                               $E$;
    EXECUTE $E$ ALTER FUNCTION gin_extract_istore_key_query(internal, internal, int2, internal, internal) PARALLEL UNSAFE     $E$;
    EXECUTE $E$ ALTER FUNCTION gin_consistent_istore_key(internal, int2, internal, int4, internal, internal) PARALLEL UNSAFE  $E$;
    EXECUTE $E$ ALTER FUNCTION istore(bigistore) PARALLEL UNSAFE                                                        $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore(istore) PARALLEL UNSAFE                                                        $E$;
    EXECUTE $E$ ALTER FUNCTION exist(bigistore, integer) PARALLEL UNSAFE                                                $E$;
    EXECUTE $E$ ALTER FUNCTION fetchval(bigistore, integer) PARALLEL UNSAFE                                             $E$;
    EXECUTE $E$ ALTER FUNCTION each(is bigistore) PARALLEL UNSAFE                                                       $E$;
    EXECUTE $E$ ALTER FUNCTION min_key(bigistore) PARALLEL UNSAFE                                                       $E$;
    EXECUTE $E$ ALTER FUNCTION max_key(bigistore) PARALLEL UNSAFE                                                       $E$;
    EXECUTE $E$ ALTER FUNCTION compact(bigistore) PARALLEL UNSAFE                                                       $E$;
    EXECUTE $E$ ALTER FUNCTION add(bigistore, bigistore) PARALLEL UNSAFE                                                $E$;
    EXECUTE $E$ ALTER FUNCTION add(bigistore, bigint) PARALLEL UNSAFE                                                   $E$;
    EXECUTE $E$ ALTER FUNCTION subtract(bigistore, bigistore) PARALLEL UNSAFE                                           $E$;
    EXECUTE $E$ ALTER FUNCTION subtract(bigistore, bigint) PARALLEL UNSAFE                                              $E$;
    EXECUTE $E$ ALTER FUNCTION multiply(bigistore, bigistore) PARALLEL UNSAFE                                           $E$;
    EXECUTE $E$ ALTER FUNCTION multiply(bigistore, bigint) PARALLEL UNSAFE                                              $E$;
    EXECUTE $E$ ALTER FUNCTION divide(bigistore, bigistore) PARALLEL UNSAFE                                             $E$;
    EXECUTE $E$ ALTER FUNCTION divide(bigistore, bigint) PARALLEL UNSAFE                                                $E$;
    EXECUTE $E$ ALTER FUNCTION concat(bigistore, bigistore) PARALLEL UNSAFE                                             $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore(integer[]) PARALLEL UNSAFE                                                     $E$;
    EXECUTE $E$ ALTER FUNCTION sum_up(bigistore) PARALLEL UNSAFE                                                        $E$;
    EXECUTE $E$ ALTER FUNCTION sum_up(bigistore, integer) PARALLEL UNSAFE                                               $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore(integer[], integer[]) PARALLEL UNSAFE                                          $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore(integer[], bigint[]) PARALLEL UNSAFE                                           $E$;
    EXECUTE $E$ ALTER FUNCTION istore(integer[], bigint[]) PARALLEL UNSAFE                                              $E$;
    EXECUTE $E$ ALTER FUNCTION fill_gaps(bigistore, integer, bigint) PARALLEL UNSAFE                                    $E$;
    EXECUTE $E$ ALTER FUNCTION accumulate(bigistore) PARALLEL UNSAFE                                                    $E$;
    EXECUTE $E$ ALTER FUNCTION accumulate(bigistore, integer) PARALLEL UNSAFE                                           $E$;
    EXECUTE $E$ ALTER FUNCTION istore_seed(integer, integer, bigint) PARALLEL UNSAFE                                    $E$;
    EXECUTE $E$ ALTER FUNCTION istore_val_larger(bigistore, bigistore) PARALLEL UNSAFE                                  $E$;
    EXECUTE $E$ ALTER FUNCTION istore_val_smaller(bigistore, bigistore) PARALLEL UNSAFE                                 $E$;
    EXECUTE $E$ ALTER FUNCTION akeys(bigistore) PARALLEL UNSAFE                                                         $E$;
    EXECUTE $E$ ALTER FUNCTION avals(bigistore) PARALLEL UNSAFE                                                         $E$;
    EXECUTE $E$ ALTER FUNCTION skeys(bigistore) PARALLEL UNSAFE                                                         $E$;
    EXECUTE $E$ ALTER FUNCTION svals(bigistore) PARALLEL UNSAFE                                                         $E$;
    EXECUTE $E$ ALTER FUNCTION istore_length(bigistore) PARALLEL UNSAFE                                                 $E$;
    EXECUTE $E$ ALTER FUNCTION istore_to_json(bigistore) PARALLEL UNSAFE                                                $E$;
    EXECUTE $E$ ALTER FUNCTION istore_to_array(bigistore) PARALLEL UNSAFE                                               $E$;
    EXECUTE $E$ ALTER FUNCTION istore_to_matrix(bigistore) PARALLEL UNSAFE                                              $E$;
    EXECUTE $E$ ALTER FUNCTION slice(bigistore, integer[]) PARALLEL UNSAFE                                              $E$;
    EXECUTE $E$ ALTER FUNCTION slice_array(bigistore, integer[]) PARALLEL UNSAFE                                        $E$;
    EXECUTE $E$ ALTER FUNCTION clamp_below(bigistore,int) PARALLEL UNSAFE                                               $E$;
    EXECUTE $E$ ALTER FUNCTION clamp_above(bigistore,int) PARALLEL UNSAFE                                               $E$;
    EXECUTE $E$ ALTER FUNCTION delete(bigistore,int) PARALLEL UNSAFE                                                    $E$;
    EXECUTE $E$ ALTER FUNCTION delete(bigistore,int[]) PARALLEL UNSAFE                                                  $E$;
    EXECUTE $E$ ALTER FUNCTION exists_all(bigistore,integer[]) PARALLEL UNSAFE                                          $E$;
    EXECUTE $E$ ALTER FUNCTION exists_any(bigistore,integer[]) PARALLEL UNSAFE                                          $E$;
    EXECUTE $E$ ALTER FUNCTION delete(bigistore,bigistore) PARALLEL UNSAFE                                              $E$;
    EXECUTE $E$ ALTER FUNCTION istore_sum_transfn(internal, bigistore) PARALLEL UNSAFE                                  $E$;
    EXECUTE $E$ ALTER FUNCTION istore_min_transfn(internal, bigistore) PARALLEL UNSAFE                                  $E$;
    EXECUTE $E$ ALTER FUNCTION istore_max_transfn(internal, bigistore) PARALLEL UNSAFE                                  $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore_avl_transfn(internal, int, bigint) PARALLEL UNSAFE                             $E$;
    EXECUTE $E$ ALTER FUNCTION bigistore_avl_finalfn(internal) PARALLEL UNSAFE                                          $E$;

    EXECUTE $E$ DROP AGGREGATE SUM (istore) $E$;
    EXECUTE $E$ DROP AGGREGATE MIN (istore) $E$;
    EXECUTE $E$ DROP AGGREGATE MAX (istore) $E$;
    EXECUTE $E$ DROP AGGREGATE SUM (bigistore) $E$;
    EXECUTE $E$ DROP AGGREGATE MIN (bigistore) $E$;
    EXECUTE $E$ DROP AGGREGATE MAX (bigistore) $E$;

    EXECUTE $E$ DROP FUNCTION istore_agg_sum_combine(internal, internal) $E$;
    EXECUTE $E$ DROP FUNCTION istore_agg_max_combine(internal, internal) $E$;
    EXECUTE $E$ DROP FUNCTION istore_agg_min_combine(internal, internal) $E$;
    EXECUTE $E$ DROP FUNCTION istore_agg_serial(internal) $E$;
    EXECUTE $E$ DROP FUNCTION istore_agg_deserial(bytea, internal) $E$;

    EXECUTE $E$ CREATE AGGREGATE SUM (istore) (
        sfunc = istore_sum_transfn,
        stype = internal,
        finalfunc = bigistore_agg_finalfn,
        parallel = UNSAFE
    ) $E$ ;

    EXECUTE $E$ CREATE AGGREGATE MIN (istore) (
        sfunc = istore_min_transfn,
        stype = internal,
        finalfunc = istore_agg_finalfn_pairs,
        parallel = UNSAFE
    ) $E$ ;

    EXECUTE $E$ CREATE AGGREGATE MAX (istore) (
        sfunc = istore_max_transfn,
        stype = internal,
        finalfunc = istore_agg_finalfn_pairs,
        parallel = UNSAFE
    ) $E$ ;

    EXECUTE $E$ CREATE AGGREGATE SUM (bigistore) (
        sfunc = istore_sum_transfn,
        stype = internal,
        finalfunc = bigistore_agg_finalfn,
        parallel = UNSAFE
    )  $E$;

    EXECUTE $E$ CREATE AGGREGATE MIN (bigistore) (
        sfunc = istore_min_transfn,
        stype = internal,
        finalfunc = bigistore_agg_finalfn,
        parallel = UNSAFE
    )  $E$;

    EXECUTE $E$ CREATE AGGREGATE MAX (bigistore) (
        sfunc = istore_max_transfn,
        stype = internal,
        finalfunc = bigistore_agg_finalfn,
        parallel = UNSAFE
    )  $E$;
  END IF;
END;
$$;

