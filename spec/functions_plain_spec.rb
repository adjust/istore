require 'spec_helper'

describe 'functions_plain' do
  before do
    install_extension
  end

  it 'should find keys with exists' do
    query("SELECT exist('1=>1'::istore, 1)").should match 't'
    query("SELECT exist('1=>1'::istore, 2)").should match 'f'
    query("SELECT exist('1=>1, -1=>0'::istore, 2)").should match 'f'
    query("SELECT exist('1=>1, -1=>0'::istore, -1)").should match 't'
  end

  it 'should fetchvals' do
    query("SELECT fetchval('1=>1'::istore, 1)").should match '1'
    query("SELECT fetchval('2=>1'::istore, 1)").should match nil
    query("SELECT fetchval('1=>1, 1=>1'::istore, 1)").should match '2'
    query("SELECT fetchval('1=>1, 1=>1'::istore, 2)").should match nil
  end

  it 'should return set of ints' do
    query("SELECT * FROM each('1=>1'::istore)").should match ['1','1']

    query("SELECT * FROM each('5=>11, 4=>8'::istore)").should match \
      ['5','11'],
      ['4','8']

    query("SELECT * FROM each('5=>-411, 4=>8'::istore)").should match \
      ['5','-411'],
      ['4','8']

    query("SELECT value + 100 FROM each('5=>-411, 4=>8'::istore)").should match \
      ['-311'],
      ['108']

    query("SELECT * FROM each('1=>1, 5=>NULL'::istore)").should match \
      ['1','1'],
      ['5',nil]

    query("SELECT * FROM each(NULL::istore)").should match []
  end

  it 'should add istores' do
    query("SELECT add('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore)").should match \
    '"1"=>"2", "2"=>"2"'
    query("SELECT add('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore)").should match \
    '"-1"=>"1", "1"=>"1", "2"=>"2"'
    query("SELECT add('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"-1", "1"=>"1", "2"=>"2"'
    query("SELECT add('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"0", "2"=>"2"'
    query("SELECT add('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"-2", "2"=>"2"'
    query("SELECT add('-1=>-1, 2=>1'::istore, 1)").should match \
    '"-1"=>"0", "2"=>"2"'
    query("SELECT add('-1=>-1, 2=>1'::istore, -1)").should match \
    '"-1"=>"-2", "2"=>"0"'
    query("SELECT add('-1=>-1, 2=>1'::istore, 0)").should match \
    '"-1"=>"-1", "2"=>"1"'
    query("SELECT add(istore(Array[]::integer[], Array[]::integer[]), '1=>NULL'::istore);").should match \
    '"1"=>NULL'
  end

  it 'should substract istores' do
    query("SELECT subtract('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore)").should match \
    '"1"=>"0", "2"=>"0"'
    query("SELECT subtract('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore)").should match \
    '"-1"=>"-1", "1"=>"1", "2"=>"0"'
    query("SELECT subtract('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"1", "1"=>"1", "2"=>"0"'
    query("SELECT subtract('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"2", "2"=>"0"'
    query("SELECT subtract('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"0", "2"=>"0"'
    query("SELECT subtract('-1=>-1, 2=>1'::istore, 1)").should match \
    '"-1"=>"-2", "2"=>"0"'
    query("SELECT subtract('-1=>-1, 2=>1'::istore, -1)").should match \
    '"-1"=>"0", "2"=>"2"'
    query("SELECT subtract('-1=>-1, 2=>1'::istore, 0)").should match \
    '"-1"=>"-1", "2"=>"1"'
    query("SELECT subtract(istore(Array[]::integer[], Array[]::integer[]), '1=>NULL'::istore);").should match \
    '"1"=>NULL'
  end

  it 'should multiply istores' do
    query("SELECT multiply('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore)").should match \
      '"1"=>"1", "2"=>"1"'
    query("SELECT multiply('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore)").should match \
      '"-1"=>NULL, "1"=>NULL, "2"=>"1"'
    query("SELECT multiply('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>NULL, "1"=>NULL, "2"=>"1"'
    query("SELECT multiply('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>"-1", "2"=>"1"'
    query("SELECT multiply('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>"1", "2"=>"1"'
    query("SELECT multiply('-1=>-1, 2=>1'::istore, 1)").should match \
      '"-1"=>"-1", "2"=>"1"'
    query("SELECT multiply('-1=>-1, 2=>1'::istore, -1)").should match \
      '"-1"=>"1", "2"=>"-1"'
    query("SELECT multiply('-1=>-1, 2=>1'::istore, 0)").should match \
      '"-1"=>"0", "2"=>"0"'
  end

  it 'should divide istores' do
    query("SELECT divide('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore)").should match \
      '"1"=>"1", "2"=>"1"'
    query("SELECT divide('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore)").should match \
      '"-1"=>NULL, "1"=>NULL, "2"=>"1"'
    query("SELECT divide('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>NULL, "1"=>NULL, "2"=>"1"'
    query("SELECT divide('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>"-1", "2"=>"1"'
    query("SELECT divide('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>"1", "2"=>"1"'
    query("SELECT divide('-1=>-1, 2=>1'::istore, 1)").should match \
      '"-1"=>"-1", "2"=>"1"'
    query("SELECT divide('-1=>-1, 2=>1'::istore, -1)").should match \
      '"-1"=>"1", "2"=>"-1"'
    query("SELECT divide('-1=>-1, 2=>1'::istore, 0)").should match \
      '"-1"=>NULL, "2"=>NULL'
    query("SELECT divide('-1=>-1, 2=>1'::istore, 1::bigint)").should match \
      '"-1"=>"-1", "2"=>"1"'
    query("SELECT divide('-1=>-1, 2=>1'::istore, -1::bigint)").should match \
      '"-1"=>"1", "2"=>"-1"'
    query("SELECT divide('-1=>-1, 2=>1'::istore, 0::bigint)").should match \
      '"-1"=>NULL, "2"=>NULL'
    query("SELECT divide('-1=>-8000000000, 2=>8000000000'::istore, 4000000000)").should match \
      '"-1"=>"-2", "2"=>"2"'
  end

  it 'should generate istore from array' do
    query("SELECT istore_from_array(ARRAY[1])").should match \
    '"1"=>"1"'
    query("SELECT istore_from_array(ARRAY[1,1,1,1])").should match \
    '"1"=>"4"'
    query("SELECT istore_from_array(NULL)").should match nil
    query("SELECT istore_from_array(ARRAY[1,2,3,4])").should match \
    '"1"=>"1", "2"=>"1", "3"=>"1", "4"=>"1"'
    query("SELECT istore_from_array(ARRAY[1,2,3,4,1,2,3,4])").should match \
    '"1"=>"2", "2"=>"2", "3"=>"2", "4"=>"2"'
    query("SELECT istore_from_array(ARRAY[1,2,3,4,1,2,3,NULL])").should match \
    '"1"=>"2", "2"=>"2", "3"=>"2", "4"=>"1"'
    query("SELECT istore_from_array(ARRAY[NULL,2,3,4,1,2,3,4])").should match \
    '"1"=>"1", "2"=>"2", "3"=>"2", "4"=>"2"'
    query("SELECT istore_from_array(ARRAY[NULL,2,3,4,1,2,3,NULL])").should match \
    '"1"=>"1", "2"=>"2", "3"=>"2", "4"=>"1"'
    query("SELECT istore_from_array(ARRAY[1,2,3,NULL,1,NULL,3,4,1,2,3])").should match \
    '"1"=>"3", "2"=>"2", "3"=>"3", "4"=>"1"'
    query("SELECT istore_from_array(ARRAY[NULL,NULL,NULL,NULL]::integer[])").should match ""
    query("SELECT istore_from_array(ARRAY[]::integer[])").should match ""
  end

  it 'should agg an array of istores' do
    query("SELECT istore_agg(ARRAY['1=>1']::istore[])").should match \
    '"1"=>"1"'
    query("SELECT istore_agg(ARRAY['1=>1','1=>1']::istore[])").should match \
    '"1"=>"2"'
    query("SELECT istore_agg(ARRAY['1=>1,2=>1','1=>1,2=>-1']::istore[])").should match \
    '"1"=>"2", "2"=>"0"'
    query("SELECT istore_agg(ARRAY['1=>1,2=>1','1=>1,2=>-1',NULL]::istore[])").should match \
    '"1"=>"2", "2"=>"0"'
    query("SELECT istore_agg(ARRAY[NULL,'1=>1,2=>1','1=>1,2=>-1']::istore[])").should match \
    '"1"=>"2", "2"=>"0"'
    query("SELECT istore_agg(ARRAY[NULL,'1=>1,2=>1','1=>1,2=>-1',NULL]::istore[])").should match \
    '"1"=>"2", "2"=>"0"'
  end

  it 'should sum up istores' do
    query("SELECT istore_sum_up('1=>1'::istore)").should match 1
    query("SELECT istore_sum_up(NULL::istore)").should match nil
    query("SELECT istore_sum_up('1=>1, 2=>1'::istore)").should match 2
    query("SELECT istore_sum_up('1=>1 ,2=>-1, 1=>1'::istore)").should match 1
  end

  it 'should sum istores from table' do
    query("CREATE TABLE test (a istore)")
    query("INSERT INTO test VALUES('1=>1'),('2=>1'), ('3=>1')")
    query("SELECT SUM(a) FROM test").should match \
    '"1"=>"1", "2"=>"1", "3"=>"1"'
  end

  it 'should sum istores from table' do
    query("CREATE TABLE test (a istore)")
    query("INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>3')")
    query("SELECT SUM(a) FROM test").should match \
    '"1"=>"1", "2"=>"1", "3"=>"4"'
  end

  it 'should sum istores from table' do
    query("CREATE TABLE test (a istore)")
    query("INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>NULL')")
    query("SELECT SUM(a) FROM test").should match \
    '"1"=>"1", "2"=>"1", "3"=>"1"'
  end

  it 'should return istores from arrays' do
    query("SELECT istore_array_add(Array[5,3,4,5], Array[1,2,3,4])").should match \
      '"3"=>"2", "4"=>"3", "5"=>"5"'

    query("SELECT istore_array_add(Array['de', 'de', 'us']::country[], Array[7,2,5])").should match \
      '"de"=>"9", "us"=>"5"'

    query("SELECT istore_array_add(Array['mac', 'mac']::device_type[], Array[1,4])").should match \
      '"mac"=>"5"'

    query("SELECT istore_array_add(Array['ios', 'android', 'ios']::os_name[], Array[2,3,4])").should match \
      '"android"=>"3", "ios"=>"6"'

    query("SELECT istore_array_add(Array[]::os_name[], Array[]::int[])").should match ''

    query("SELECT istore(Array[5,3,4,5], Array[1,2,3,4])").should match \
      '"3"=>"2", "4"=>"3", "5"=>"5"'

    query("SELECT istore(Array[5,3,4,5], Array[1,2,3,4]::bigint[])").should match \
      '"3"=>"2", "4"=>"3", "5"=>"5"'

    query("SELECT istore(Array[5,3,4,5], Array[4000000000,2,4000000000,4]::bigint[])").should match \
      '"3"=>"2", "4"=>"4000000000", "5"=>"4000000004"'
  end

  it 'should fill gaps' do
    query("SELECT fill_gaps('2=>17, 4=>3'::istore, 5, 0)").should match \
      '"0"=>"0", "1"=>"0", "2"=>"17", "3"=>"0", "4"=>"3", "5"=>"0"'

    query("SELECT fill_gaps('2=>17, 4=>3'::istore, 5)").should match \
      '"0"=>"0", "1"=>"0", "2"=>"17", "3"=>"0", "4"=>"3", "5"=>"0"'

    query("SELECT fill_gaps('2=>17, 4=>3'::istore, 3, 11)").should match \
      '"0"=>"11", "1"=>"11", "2"=>"17", "3"=>"11"'

    query("SELECT fill_gaps('2=>17, 4=>3'::istore, 0, 0)").should match \
      '"0"=>"0"'

    query("SELECT fill_gaps('2=>17'::istore, 3, NULL)").should match \
      '"0"=>NULL, "1"=>NULL, "2"=>"17", "3"=>NULL'

    query("SELECT fill_gaps('2=>NULL, 3=>3'::istore, 3, 0)").should match \
      '"0"=>"0", "1"=>"0", "2"=>NULL, "3"=>"3"'

    query("SELECT fill_gaps(''::istore, 3, 0)").should match \
      '"0"=>"0", "1"=>"0", "2"=>"0", "3"=>"0"'

    query("SELECT fill_gaps(NULL::istore, 3, 0)").should match nil

    expect{query("SELECT fill_gaps('2=>17, 4=>3'::istore, -5, 0)")}.to throw_error 'parameter upto must be >= 0'
  end

  it 'should fill accumulate' do
    query("SELECT accumulate('2=>17, 4=>3'::istore)").should match \
      '"2"=>"17", "3"=>"17", "4"=>"20"'
    query("SELECT accumulate('2=>NULL, 4=>3'::istore)").should match \
      '"2"=>"0", "3"=>"0", "4"=>"3"'
    query("SELECT accumulate('1=>3, 2=>NULL, 4=>3, 6=>2'::istore)").should match \
      '"1"=>"3", "2"=>"3", "3"=>"3", "4"=>"6", "5"=>"6", "6"=>"8"'

  end
end
