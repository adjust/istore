# istore

The idea of istore is to have an integer based hstore (thus the name) which
supports operators like + and aggregates like SUM.

The textual representation of an istore is the same as for hstore
e.g.

    "-5"=>"-25", "0"=>"10", "5"=>"0", "100"=>"30"`

On istore both keys and values are represented and stored as integer. The extension
comes with two types `istore` and `bigistore` the former having `int` and the
latter `bigint` as values, keys are `int` for both.

The use case an optimization for istore is an analytical workload.
Think of it as showing distributions of whatever can be represented as integer.

### Example

Say you have an event log table where you'd aggregate events with some id  and
segmentation by date.

```pgsql
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

```pgsql
    CREATE TABLE event_log2 AS
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
    istore_test=# SELECT SUM(counts->35) from event_log2 ;
       sum
    ----------
     50213687
    (1 row)

    Time: 29,032 ms

instead of

    istore_test=# SELECT SUM(count) from event_log where id = 35;
       sum
    ----------
     50213687
    (1 row)

    Time: 374,806 ms
```

Where you can already see the performance benefit.

Which is mostly due to the reduce io.

```pgsql
    SELECT pg_size_pretty(pg_table_size('event_log')) as "without istore", pg_size_pretty(pg_table_size('event_log2')) as "with istore";
     without istore | with istore
    ----------------+-------------
     249 MB         | 87 MB
```

### istore Operators


Operator              | Description                                                           | Example                                   | Result
---------             | -----------                                                           | -------                                   | ------
istore -> integer     | get value for key (NULL if not present)                               | '1=>4,2=>5'::istore -> 1                  | 4
istore ? integer      | does istore contain key?                                              | '1=>4,2=>5'::istore ? 2                   | t
istore + istore       | add value of matching keys (missing key will be treated as 0)         | '1=>4,2=>5'::istore + '1=>4,3=>6'::istore | "1"=>"8", "2"=>"5", "3"=>"6"
istore + integer      | add right operant to all values                                       | '1=>4,2=>5'::istore + 3                   | "1"=>"7", "2"=>"8"
istore - istore       | subtract value of matching keys (missing key will be treated as 0)    | '1=>4,2=>5'::istore - '1=>4,3=>6'::istore | "1"=>"0", "2"=>"5", "3"=>"-6"
istore - integer      | subtract right operant to all values                                  | '1=>4,2=>5'::istore - 3                   | "1"=>"1", "2"=>"2"
istore * istore       | multiply value of matching keys (missing key will be ignored)         | '1=>4,2=>5'::istore * '1=>4,3=>6'::istore | "1"=>"16"
istore * integer      | multiply right operant to all values                                  | '1=>4,2=>5'::istore * 3                   | "1"=>"12", "2"=>"15"
istore / istore       | divide value of matching keys (missing key will be ignored)           | '1=>4,2=>5'::istore / '1=>4,3=>6'::istore | "1"=>"1"
istore / integer      | divide right operant to all values                                    | '1=>4,2=>5'::istore / 3                   | "1"=>"1", "2"=>"1"

### istore Functions

Function                                | Return type               | Description                                                                 | Example                                                       | Result
--------                                | -----------               | -----------                                                                 | -------                                                       | ------
exist(istore, integer)                  | boolean                   | does istore contain key?                                                    | exist('1=>4,5=>10'::istore, 5)                                | t
fetchval(istore, integer)               | integer                   | get value for key (NULL if not present)                                     | fetchval('1=>4,5=>10'::istore, 5)                             | 10
akeys(istore)                           | int[]                     | get istore's keys as an array                                               | akeys('1=>3,2=>4')                                            | {1,2}
avals(istore)                           | int[]                     | get istore's values as an array                                             | avals('1=>3,2=>4')                                            | {3,4}
skeys(istore)                           | setof int                 | get istore's keys as a set                                                  | skeys('1=>3,2=>4')                                            | 1<br/>2
svals(istore)                           | setof int                 | get istore's values as a set                                                | svals('1=>3,2=>4')                                            | 3<br/>4
istore_to_json(istore)                  | json                      | get istore as a json value                                                  | istore_to_json('1=>4,3=>0,5=>10'::istore)                     | {"1": 4, "3": 0, "5": 10}
compact(istore)                         | istore                    | remove `0` value keys                                                       | compact('1=>4,3=>0,5=>10'::istore)                            | "1"=>"4", "5"=>"10"
add(istore, istore)                     | istore                    | add value of matching keys (missing key will be treated as 0)               | add('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)                 | "1"=>"8", "2"=>"5", "3"=>"6"
add(istore, integer)                    | istore                    | add right operant to all values                                             | add('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)                 | "1"=>"8", "2"=>"5", "3"=>"6"
subtract(istore, istore)                | istore                    | subtract value of matching keys (missing key will be treated as 0)          | subtract('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)            | "1"=>"0", "2"=>"5", "3"=>"-6"
subtract(istore, integer)               | istore                    | subtract right operant to all values                                        | subtract('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)            | "1"=>"0", "2"=>"5", "3"=>"-6"
multiply(istore, istore)                | istore                    | multiply value of matching keys (missing key will be ignored)               | multiply('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)            | "1"=>"16"
multiply(istore, integer)               | istore                    | multiply right operant to all values                                        | multiply('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)            | "1"=>"16"
divide(istore, istore)                  | istore                    | divide value of matching keys (missing key will be ignored)                 | divide('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)              | "1"=>"1"
divide(istore, integer)                 | istore                    | divide right operant to all values                                          | divide('1=>4,2=>5'::istore, '1=>4,3=>6'::istore)              | "1"=>"1"
istore(integer[])                       | istore                    | construct an istore from an array by counting elements                      | istore(ARRAY[1,2,1,3,2,2])                                    | "1"=>"2", "2"=>"3", "3"=>"1"
sum_up(istore)                          | bigint                    | sum values of an istore                                                     | istore_sum_up('1=>4,2=>5'::istore)                            |  9
istore(integer[], integer[])            | istore                    | construct an istore from separate key and value arrays                      | istore(ARRAY[1,2,3], ARRAY[4,5,6])                            | "1"=>"4", "2"=>"5", "3"=>"6"
fill_gaps(istore, integer, integer)     | istore                    | fill missing istore keys upto second parameter with third parameter         | fill_gaps('1=>4,3=>10'::istore,4,2)                           | "0"=>"2", "1"=>"4", "2"=>"2", "3"=>"10", "4"=>"2"
accumulate(istore)                      | istore                    | for each key calculate the rolling sum of values                            | accumulate('1=>4,3=>10'::istore)                              | "1"=>"4", "2"=>"4", "3"=>"14"
accumulate(istore, integer)             | istore                    | for each key calculate the rolling sum of values upto second parameter      | accumulate('1=>4,3=>10'::istore, 4)                           | "1"=>"4", "2"=>"4", "3"=>"14", "4"=>"14"
istore_seed(integer, integer, integer)  | istore                    | create an istore from first to second parameter with third parameter value  | istore_seed(2, 4, 5)                                          | "2"=>"5", "3"=>"5", "4"=>"5"
istore_val_larger(istore, istore)       | istore                    | merge istores with larger values                                            | istore_val_larger('1=>4,2=>5'::istore, '1=>5,3=>6'::istore)   | "1"=>"5", "2"=>"5", "3"=>"6"
istore_val_smaller(istore, istore)      | istore                    | merge istores with smaller values                                           | istore_val_smaller('1=>4,2=>5'::istore, '1=>5,3=>6'::istore)  | "1"=>"4", "2"=>"5", "3"=>"6"
each(istore)                            | setof(key int, value int) | get istore's keys and values as a set                                       | each('1=>4,5=>10'::istore)                                    | key \| value<br/> ----+-------<br/> 1 \|     4<br/> 5 \|    10

### istore Aggregate Functions

Function        | Argument Type(s)    | Return Type           | Description
---------       | ----------------    | -----------           | -----------
sum(expression) | istore, bigistore   | bigistore             | sum of expression across all input values
min(expression) | istore, bigistore   | same as argument type | merge across all input values by selecting minimum keys value
max(expression) | istore, bigistore   | same as argument type | merge across all input values by selecting maximum keys value


### Indexes

istore has GIN index support for the ? operators For example:

    CREATE INDEX hidx ON testistore USING GIN (i);


### Authors

Manuel Kniep <manuel@adjust.com>, Berlin, adjust GmbH, Germany

Robert Abraham <robert@adust.com>, Berlin, adjust GmbH, Germany

GIN index support by Emre Hasegeli <emre@hasegeli.com>, Hamburg, Germany