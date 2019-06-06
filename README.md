[![Build Status](https://travis-ci.org/adjust/istore.svg?branch=master)](https://travis-ci.org/adjust/istore)

# istore

The idea of istore is to have an integer based hstore (thus the name) which
supports operators like + and aggregates like SUM.

The textual representation of an istore is the same as for hstore
e.g.

```
"-5"=>"-25", "0"=>"10", "5"=>"0", "100"=>"30"
```

On istore both keys and values are represented and stored as integer. The extension
comes with two types `istore` and `bigistore` the former having `int` and the
latter `bigint` as values, keys are `int` for both.

The use case an optimization for istore is an analytical workload.
Think of it as showing distributions of whatever can be represented as integer.

### Example

Say you have an event log table where you'd aggregate events with some id  and
segmentation by date.

```
CREATE TABLE event_log AS
SELECT
  d::date as date,
  j as segment,
  i as id, (random()*1000)::int as count,
  (random()*100000)::int as revenues
FROM
  generate_series(1,50) i,
  generate_series(1,1000) j,
  generate_series(current_date - 99, current_date, '1 day') d;
```

Using istore you would use the id as key and count / revenues as values.

```
CREATE TABLE istore_event_log AS
SELECT
  date,
  segment,
  istore(array_agg(id), array_agg(count)) as counts,
  istore(array_agg(id), array_agg(revenues)) as revenues
FROM event_log
GROUP BY date, segment;
```

To summarize the count for a specific `id` you would write

```
istore_test=# SELECT SUM(counts->35) from istore_event_log ;
    sum
----------
  50213687
(1 row)

Time: 29,032 ms
```

instead of

```
istore_test=# SELECT SUM(count) from event_log where id = 35;
    sum
----------
  50213687
(1 row)

Time: 374,806 ms
```

Where you can already see the performance benefit.

Which is mostly due to the reduced IO.

```
SELECT pg_size_pretty(pg_table_size('event_log')) as "without istore", pg_size_pretty(pg_table_size('istore_event_log')) as "with istore";
  without istore | with istore
----------------+-------------
  249 MB         | 87 MB
```

The following functions and operators apply to both `istore` and `bigistore` types.

### istore Operators

Operator              | Description                                                           | Example                                   | Result
---------             | -----------                                                           | -------                                   | ------
istore -> integer     | get value for key (NULL if not present)                               | '1=>4,2=>5'::istore -> 1                  | 4
istore -> integer[]   | get values or key (NULL if not present)                               | '1=>4,2=>5'::istore -> Array[1,3]         | {4,NULL}
istore ? integer      | does istore contain key?                                              | '1=>4,2=>5'::istore ? 2                   | t
istore ?& integer[]   | does istore contain all specified keys?                               | '1=>4,2=>5'::istore ?& ARRAY[1,3]         | f
istore ?\| integer[]  | does istore contain any of the specified keys?                        | '1=>4,2=>5'::istore ?\| ARRAY[1,3]        | t
istore \|\| istore    | concatenate istores                                                   | '1=>4, 2=>5'::istore \|\| '3=>4, 2=>7'    | "1"=>"4", "2"=>"7", "3"=>"4"
istore + istore       | add value of matching keys (missing key will be treated as 0)         | '1=>4,2=>5'::istore + '1=>4,3=>6'::istore | "1"=>"8", "2"=>"5", "3"=>"6"
istore + integer      | add right operant to all values                                       | '1=>4,2=>5'::istore + 3                   | "1"=>"7", "2"=>"8"
istore - istore       | subtract value of matching keys (missing key will be treated as 0)    | '1=>4,2=>5'::istore - '1=>4,3=>6'::istore | "1"=>"0", "2"=>"5", "3"=>"-6"
istore - integer      | subtract right operant to all values                                  | '1=>4,2=>5'::istore - 3                   | "1"=>"1", "2"=>"2"
istore * istore       | multiply value of matching keys (missing key will be ignored)         | '1=>4,2=>5'::istore * '1=>4,3=>6'::istore | "1"=>"16"
istore * integer      | multiply right operant to all values                                  | '1=>4,2=>5'::istore * 3                   | "1"=>"12", "2"=>"15"
istore / istore       | divide value of matching keys (missing key will be ignored)           | '1=>4,2=>5'::istore / '1=>4,3=>6'::istore | "1"=>"1"
istore / integer      | divide right operant to all values                                    | '1=>4,2=>5'::istore / 3                   | "1"=>"1", "2"=>"1"
%% istore             | convert istore to array of alternating keys and values                | %% '1=>4,2=>5'::istore                    | {1,4,2,5}
%# istore             | convert istore to two-dimensional key/value array                     | %# '1=>4,2=>5'::istore                    | {{1,4},{2,5}}

### istore Functions

Function                                      | Return type               | Description                                                                 | Example                                                         | Result
--------                                      | -----------               | -----------                                                                 | -------                                                         | ------
exist(istore, integer)                        | boolean                   | does istore contain key?                                                    | exist('1=>4,5=>10'::istore, 5)                                  | t
min_key(istore)                               | integer                   | get the smallest key from an istore (NULL if not present)                   | min_key('1=>4,5=>10'::istore)                                   | 1
max_key(istore)                               | integer                   | get the biggest key from an istore (NULL if not present)                    | max_key('1=>4,5=>10'::istore)                                   | 5
fetchval(istore, integer)                     | integer                   | get value for key (NULL if not present)                                     | fetchval('1=>4,5=>10'::istore, 5)                               | 10
akeys(istore)                                 | int[]                     | get istore's keys as an array                                               | akeys('1=>3,2=>4')                                              | {1,2}
avals(istore)                                 | int[]                     | get istore's values as an array                                             | avals('1=>3,2=>4')                                              | {3,4}
skeys(istore)                                 | setof int                 | get istore's keys as a set                                                  | skeys('1=>3,2=>4')                                              | 1<br/>2
svals(istore)                                 | setof int                 | get istore's values as a set                                                | svals('1=>3,2=>4')                                              | 3<br/>4
istore_to_json(istore)                        | json                      | get istore as a json value                                                  | istore_to_json('1=>4,3=>0,5=>10'::istore)                       | {"1": 4, "3": 0, "5": 10}
compact(istore)                               | istore                    | remove `0` value keys                                                       | compact('1=>4,3=>0,5=>10'::istore)                              | "1"=>"4", "5"=>"10"
add(istore, istore)                           | istore                    | add value of matching keys (missing key will be treated as 0)               | add('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)                   | "1"=>"8", "2"=>"5", "3"=>"6"
add(istore, integer)                          | istore                    | add right operant to all values                                             | add('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)                   | "1"=>"8", "2"=>"5", "3"=>"6"
subtract(istore, istore)                      | istore                    | subtract value of matching keys (missing key will be treated as 0)          | subtract('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)              | "1"=>"0", "2"=>"5", "3"=>"-6"
subtract(istore, integer)                     | istore                    | subtract right operant to all values                                        | subtract('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)              | "1"=>"0", "2"=>"5", "3"=>"-6"
multiply(istore, istore)                      | istore                    | multiply value of matching keys (missing key will be ignored)               | multiply('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)              | "1"=>"16"
multiply(istore, integer)                     | istore                    | multiply right operant to all values                                        | multiply('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)              | "1"=>"16"
divide(istore, istore)                        | istore                    | divide value of matching keys (missing key will be ignored)                 | divide('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)                | "1"=>"1"
divide(istore, integer)                       | istore                    | divide right operant to all values                                          | divide('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)                | "1"=>"1"
istore(integer[])                             | istore                    | construct an istore from an array by counting elements                      | istore(ARRAY[1,2,1,3,2,2])                                      | "1"=>"2", "2"=>"3", "3"=>"1"
sum_up(istore)                                | bigint                    | sum values of an istore                                                     | sum_up('1=>4,2=>5'::istore)                                     |  9
sum_up(istore, integer)                       | bigint                    | sum values of an istore up to a given key                                   | sum_up('1=>4,2=>5,3=>5'::istore,2)                              |  9
istore(integer[], integer[])                  | istore                    | construct an istore from separate key and value arrays                      | istore(ARRAY[1,2,3], ARRAY[4,5,6])                              | "1"=>"4", "2"=>"5", "3"=>"6"
fill_gaps(istore, integer, integer)           | istore                    | fill missing istore keys upto second parameter with third parameter         | fill_gaps('1=>4,3=>10'::istore,4,2)                             | "0"=>"2", "1"=>"4", "2"=>"2", "3"=>"10", "4"=>"2"
accumulate(istore)                            | istore                    | for each key calculate the rolling sum of values                            | accumulate('1=>4,3=>10'::istore)                                | "1"=>"4", "2"=>"4", "3"=>"14"
accumulate(istore, integer)                   | istore                    | for each key calculate the rolling sum of values upto second parameter      | accumulate('1=>4,3=>10'::istore, 4)                             | "1"=>"4", "2"=>"4", "3"=>"14", "4"=>"14"
istore_seed(integer, integer, integer)        | istore                    | create an istore from first to second parameter with third parameter value  | istore_seed(2, 4, 5)                                            | "2"=>"5", "3"=>"5", "4"=>"5"
istore_val_larger(istore, istore)             | istore                    | merge istores with larger values                                            | istore_val_larger('1=>4,2=>5'::istore, '1=>5,3=>6'::istore)     | "1"=>"5", "2"=>"5", "3"=>"6"
istore_val_smaller(istore, istore)            | istore                    | merge istores with smaller values                                           | istore_val_smaller('1=>4,2=>5'::istore, '1=>5,3=>6'::istore)    | "1"=>"4", "2"=>"5", "3"=>"6"
each(istore)                                  | setof(key int, value int) | get istore's keys and values as a set                                       | each('1=>4,5=>10'::istore)                                      | key \| value<br/> ----+-------<br/> 1 \|     4<br/> 5 \|    10
istore_to_json(istore)                        | integer[]                 | get istore's keys and values as json                                        | istore_to_json('1=>4,2=>5'::istore)                             |  {"1": 4, "2": 5}
istore_to_array(istore)                       | integer[]                 | get istore's keys and values as an array of alternating keys and values     | istore_to_array('1=>4,2=>5'::istore)                            |  {1,4,2,5}
istore_to_matrix(istore)                      | integer[]                 | get istore's keys and values as a two-dimensional array                     | istore_to_matrix('1=>4,2=>5'::istore)                           |  {{1,4},{2,5}}
slice(istore, integer[])                      | istore                    | extract a subset of an istore                                               | slice('1=>4,2=>5'::istore, ARRAY[2])                            |  "2"=>"5"
slice(istore, min integer, max integer)       | istore                    | extract a subset of an istore where keys are between min and max            | slice('1=>4,2=>5,3=>6,4=>7'::istore, 2, 3)                      |  "2"=>"5","3=>6"
slice_array(istore, integer[])                | integer[]                 | extract a subset of an istore                                               | slice_array('1=>4,2=>5'::istore, ARRAY[2])                      |  {5}
clamp_below(istore, integer)                  | istore                    | delete k/v pair up to a specified threshold and write their sum             | clamp_below('1=>4,2=>5,3=>6'::istore, 2)                        |  "2"=>"9","3"=>"6"
clamp_above(istore, integer)                  | istore                    | delete k/v pair down to a specified threshold and write their sum           | clamp_above('1=>4,2=>5,3=>6'::istore, 2)                        |  "1"=>"4","2"=>"11"
delete(istore, integer)                       | istore                    | delete pair with matching key                                               | delete('1=>4,2=>5'::istore, 2)                                  |  "1"=>"4"
delete(istore, integer[])                     | istore                    | delete pair with matching keys                                              | delete('1=>4,2=>5'::istore, ARRAY[2])                           |  "1"=>"4"
exists_all(istore, integer[])                 | boolean                   | does istore contain all specified keys?                                     | exists_all('1=>4,2=>5'::istore, ARRAY[2])                       |  t
exists_any(istore, integer[])                 | boolean                   | does istore contain any of the specified keys?                              | exists_any('1=>4,2=>5'::istore, ARRAY[2])                       |  t
delete(istore, istore)                        | istore                    | delete matching pairs                                                       | delete('1=>4,2=>5'::istore, '1=>3,2=>5')                        |  "1"=>"4"
concat(istore, istore)                        | istore                    | concat two istores                                                          | concat('1=>4, 2=>5'::istore, '3=>4, 2=>7'::istore)              |  "1"=>"4", "2"=>"7", "3"=>"4"
istore_in_range(istore, integer, integer)     | boolean                   | do istore values lie within the given (inclusive) range?                    | istore_in_range('-1=>2, 10=>17, 5=>44'::istore, 0, 44)          | t
istore_less_than(istore, integer)             | boolean                   | do istore values lie below the given value?                                 | istore_less_than('-1=>2, 10=>17, 5=>44'::istore, 44)            | f
istore_less_than_or_equal(istore, integer)    | boolean                   | do istore values lie below or equal to the given value?                     | istore_less_than_or_equal('-1=>2, 10=>17, 5=>44'::istore, 44)   | t
istore_greater_than(istore, integer)          | boolean                   | do istore values lie above the given value?                                 | istore_greater_than('-1=>2, 10=>17, 5=>44'::istore, 2)          | f
istore_greater_than_or_equa(istore, integer)  | boolean                   | do istore values lie above or equal to the given value?                     | istore_greater_than_or_equal('-1=>2, 10=>17, 5=>44'::istore, 2) | t
istore_floor(istore, integer)                 | istore                    | replace all values lower than the boundary with the boundary value          | istore_floor('-1=>2, 10=>17, 5=>44'::istore, 20)                | "-1"=>"20", "10"=>"20", "5"=>"44"
istore_ceiling(istore, integer)               | istore                    | replace all values greater than the boundary with the boundary value        | istore_ceiling('-1=>2, 10=>17, 5=>44'::istore, 20)              | "-1"=>"2", "10"=>"17", "5"=>"20"


### istore Aggregate Functions

Function        | Argument Type(s)    | Return Type           | Description
---------       | ----------------    | -----------           | -----------
sum(expression) | istore, bigistore   | bigistore             | sum of expression across all input values
min(expression) | istore, bigistore   | same as argument type | merge across all input values by selecting minimum keys value
max(expression) | istore, bigistore   | same as argument type | merge across all input values by selecting maximum keys value

### Indexes

istore has GIN index support for the ? operators For example:

```
CREATE INDEX hidx ON testistore USING GIN (i);
```

### Authors

Manuel Kniep <manuel@adjust.com>, Berlin, adjust GmbH, Germany

Robert Abraham <robert@adust.com>, Berlin, adjust GmbH, Germany

GIN index support by Emre Hasegeli <emre@hasegeli.com>, Hamburg, Germany
