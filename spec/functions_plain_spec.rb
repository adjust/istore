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

  it 'should add istores' do
    query("SELECT add('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore)").should match \
    '"1"=>"2","2"=>"2"'
    query("SELECT add('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore)").should match \
    '"-1"=>"1","1"=>"1","2"=>"2"'
    query("SELECT add('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"-1","1"=>"1","2"=>"2"'
    query("SELECT add('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"0","2"=>"2"'
    query("SELECT add('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"-2","2"=>"2"'
    query("SELECT add('-1=>-1, 2=>1'::istore, 1)").should match \
    '"-1"=>"0","2"=>"2"'
    query("SELECT add('-1=>-1, 2=>1'::istore, -1)").should match \
    '"-1"=>"-2","2"=>"0"'
    query("SELECT add('-1=>-1, 2=>1'::istore, 0)").should match \
    '"-1"=>"-1","2"=>"1"'
  end

  it 'should substract istores' do
    query("SELECT subtract('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore)").should match \
    '"1"=>"0","2"=>"0"'
    query("SELECT subtract('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore)").should match \
    '"-1"=>"-1","1"=>"1","2"=>"0"'
    query("SELECT subtract('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"1","1"=>"1","2"=>"0"'
    query("SELECT subtract('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"2","2"=>"0"'
    query("SELECT subtract('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
    '"-1"=>"0","2"=>"0"'
    query("SELECT subtract('-1=>-1, 2=>1'::istore, 1)").should match \
    '"-1"=>"-2","2"=>"0"'
    query("SELECT subtract('-1=>-1, 2=>1'::istore, -1)").should match \
    '"-1"=>"0","2"=>"2"'
    query("SELECT subtract('-1=>-1, 2=>1'::istore, 0)").should match \
    '"-1"=>"-1","2"=>"1"'
  end

  it 'should multiply istores' do
    query("SELECT multiply('1=>1, 2=>1'::istore, '1=>1, 2=>1'::istore)").should match \
      '"1"=>"1","2"=>"1"'
    query("SELECT multiply('1=>1, 2=>1'::istore, '-1=>1, 2=>1'::istore)").should match \
      '"-1"=>NULL,"1"=>NULL,"2"=>"1"'
    query("SELECT multiply('1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>NULL,"1"=>NULL,"2"=>"1"'
    query("SELECT multiply('-1=>1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>"-1","2"=>"1"'
    query("SELECT multiply('-1=>-1, 2=>1'::istore, '-1=>-1, 2=>1'::istore)").should match \
      '"-1"=>"1","2"=>"1"'
    query("SELECT multiply('-1=>-1, 2=>1'::istore, 1)").should match \
      '"-1"=>"-1","2"=>"1"'
    query("SELECT multiply('-1=>-1, 2=>1'::istore, -1)").should match \
      '"-1"=>"1","2"=>"-1"'
    query("SELECT multiply('-1=>-1, 2=>1'::istore, 0)").should match \
      '"-1"=>"0","2"=>"0"'
  end

  it 'should generate istore from array' do
    query("SELECT istore_from_array(ARRAY[1])").should match \
    '"1"=>"1"'
    query("SELECT istore_from_array(ARRAY[1,1,1,1])").should match \
    '"1"=>"4"'
    query("SELECT istore_from_array(NULL)").should match nil
    query("SELECT istore_from_array(ARRAY[1,2,3,4])").should match \
    '"1"=>"1","2"=>"1","3"=>"1","4"=>"1"'
    query("SELECT istore_from_array(ARRAY[1,2,3,4,1,2,3,4])").should match \
    '"1"=>"2","2"=>"2","3"=>"2","4"=>"2"'
    query("SELECT istore_from_array(ARRAY[1,2,3,4,1,2,3,NULL])").should match \
    '"1"=>"2","2"=>"2","3"=>"2","4"=>"1"'
    query("SELECT istore_from_array(ARRAY[NULL,2,3,4,1,2,3,4])").should match \
    '"1"=>"1","2"=>"2","3"=>"2","4"=>"2"'
    query("SELECT istore_from_array(ARRAY[NULL,2,3,4,1,2,3,NULL])").should match \
    '"1"=>"1","2"=>"2","3"=>"2","4"=>"1"'
    query("SELECT istore_from_array(ARRAY[1,2,3,NULL,1,NULL,3,4,1,2,3])").should match \
    '"1"=>"3","2"=>"2","3"=>"3","4"=>"1"'
  end

  it 'should agg an array of istores' do
    query("SELECT istore_agg(ARRAY['1=>1']::istore[])").should match \
    '"1"=>"1"'
    query("SELECT istore_agg(ARRAY['1=>1','1=>1']::istore[])").should match \
    '"1"=>"2"'
    query("SELECT istore_agg(ARRAY['1=>1,2=>1','1=>1,2=>-1']::istore[])").should match \
    '"1"=>"2","2"=>"0"'
    query("SELECT istore_agg(ARRAY['1=>1,2=>1','1=>1,2=>-1',NULL]::istore[])").should match \
    '"1"=>"2","2"=>"0"'
    query("SELECT istore_agg(ARRAY[NULL,'1=>1,2=>1','1=>1,2=>-1']::istore[])").should match \
    '"1"=>"2","2"=>"0"'
    query("SELECT istore_agg(ARRAY[NULL,'1=>1,2=>1','1=>1,2=>-1',NULL]::istore[])").should match \
    '"1"=>"2","2"=>"0"'
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
    '"1"=>"1","2"=>"1","3"=>"1"'
  end

  it 'should sum istores from table' do
    query("CREATE TABLE test (a istore)")
    query("INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>3')")
    query("SELECT SUM(a) FROM test").should match \
    '"1"=>"1","2"=>"1","3"=>"4"'
  end

  it 'should sum istores from table' do
    query("CREATE TABLE test (a istore)")
    query("INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>NULL')")
    query("SELECT SUM(a) FROM test").should match \
    '"1"=>"1","2"=>"1","3"=>"1"'
  end
end
