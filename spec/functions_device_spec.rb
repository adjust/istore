require 'spec_helper'

describe 'functions_device' do
  before do
    install_extension
  end

  it 'should find presence of a key' do
    query("SELECT exist('phone=>1'::device_istore, 'phone')").should match 't'
    query("SELECT exist('phone=>1'::device_istore, 'tablet')").should match 'f'
    query("SELECT exist('phone=>1, bot=>0'::device_istore, 'bot')").should match 't'
    query("SELECT exist('phone=>1, bot=>0'::device_istore, 'kermit')").should match 'f'
  end

  it 'should fetch values' do
    query("SELECT fetchval('phone=>1'::device_istore, 'phone')").should match '1'
    query("SELECT fetchval('tablet=>1'::device_istore, 'phone')").should match nil
    query("SELECT fetchval('phone=>1, phone=>1'::device_istore, 'tablet')").should match nil
    query("SELECT fetchval('phone=>1, phone=>1'::device_istore, 'phone')").should match '2'
  end

  it 'should add to device_istores' do
    query("SELECT add('phone=>1, tablet=>1'::device_istore, 'phone=>1, tablet=>1'::device_istore)").should match \
      '"phone"=>"2", "tablet"=>"2"'
    query("SELECT add('phone=>1, tablet=>1'::device_istore, 'bot=>1, tablet=>1'::device_istore)").should match \
      '"bot"=>"1", "phone"=>"1", "tablet"=>"2"'
    query("SELECT add('phone=>1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>"-1", "phone"=>"1", "tablet"=>"2"'
    query("SELECT add('bot=>1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>"0", "tablet"=>"2"'
    query("SELECT add('bot=>-1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>"-2", "tablet"=>"2"'
    query("SELECT add('bot=>-1, tablet=>1'::device_istore, 1)").should match \
      '"bot"=>"0", "tablet"=>"2"'
    query("SELECT add('bot=>-1, tablet=>1'::device_istore, -1)").should match \
      '"bot"=>"-2", "tablet"=>"0"'
    query("SELECT add('bot=>-1, tablet=>1'::device_istore, 0)").should match \
      '"bot"=>"-1", "tablet"=>"1"'
  end

  it 'should substract device_istores' do
    query("SELECT subtract('phone=>1, tablet=>1'::device_istore, 'phone=>1, tablet=>1'::device_istore)").should match \
      '"phone"=>"0", "tablet"=>"0"'
    query("SELECT subtract('phone=>1, tablet=>1'::device_istore, 'bot=>1, tablet=>1'::device_istore)").should match \
      '"bot"=>"-1", "phone"=>"1", "tablet"=>"0"'
    query("SELECT subtract('phone=>1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>"1", "phone"=>"1", "tablet"=>"0"'
    query("SELECT subtract('bot=>1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>"2", "tablet"=>"0"'
    query("SELECT subtract('bot=>-1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>"0", "tablet"=>"0"'
    query("SELECT subtract('bot=>-1, tablet=>1'::device_istore, 1)").should match \
      '"bot"=>"-2", "tablet"=>"0"'
    query("SELECT subtract('bot=>-1, tablet=>1'::device_istore, -1)").should match \
      '"bot"=>"0", "tablet"=>"2"'
    query("SELECT subtract('bot=>-1, tablet=>1'::device_istore, 0)").should match \
      '"bot"=>"-1", "tablet"=>"1"'
  end

  it 'should multiply device_istores' do
    query("SELECT multiply('phone=>1, tablet=>1'::device_istore, 'phone=>1, tablet=>1'::device_istore)").should match \
      '"phone"=>"1", "tablet"=>"1"'
    query("SELECT multiply('phone=>1, tablet=>1'::device_istore, 'bot=>1, tablet=>1'::device_istore)").should match \
      '"bot"=>NULL, "phone"=>NULL, "tablet"=>"1"'
    query("SELECT multiply('phone=>1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>NULL, "phone"=>NULL, "tablet"=>"1"'
    query("SELECT multiply('bot=>1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>"-1", "tablet"=>"1"'
    query("SELECT multiply('bot=>-1, tablet=>1'::device_istore, 'bot=>-1, tablet=>1'::device_istore)").should match \
      '"bot"=>"1", "tablet"=>"1"'
    query("SELECT multiply('bot=>-1, tablet=>1'::device_istore, 1)").should match \
      '"bot"=>"-1", "tablet"=>"1"'
    query("SELECT multiply('bot=>-1, tablet=>1'::device_istore, -1)").should match \
      '"bot"=>"1", "tablet"=>"-1"'
    query("SELECT multiply('bot=>-1, tablet=>1'::device_istore, 0)").should match \
      '"bot"=>"0", "tablet"=>"0"'
  end

  it 'should create an device_istore from array' do
    query("SELECT device_istore_from_array(ARRAY['bot'])").should match \
      '"bot"=>"1"'
    query("SELECT device_istore_from_array(ARRAY['bot','bot','bot','bot'])").should match \
      '"bot"=>"4"'
    query("SELECT device_istore_from_array(NULL::text[])").should match nil
    query("SELECT device_istore_from_array(ARRAY['bot','phone','tablet','mac'])").should match \
      '"bot"=>"1", "mac"=>"1", "phone"=>"1", "tablet"=>"1"'
    query("SELECT device_istore_from_array(ARRAY['bot','phone','tablet','mac','bot','phone','tablet','mac'])").should match \
      '"bot"=>"2", "mac"=>"2", "phone"=>"2", "tablet"=>"2"'
    query("SELECT device_istore_from_array(ARRAY['bot','phone','tablet','mac','bot','phone','tablet','mac',NULL])").should match \
      '"bot"=>"2", "mac"=>"2", "phone"=>"2", "tablet"=>"2"'
    query("SELECT device_istore_from_array(ARRAY[NULL,'bot','phone','tablet','mac','bot','phone','tablet','mac'])").should match \
      '"bot"=>"2", "mac"=>"2", "phone"=>"2", "tablet"=>"2"'
    query("SELECT device_istore_from_array(ARRAY[NULL,'bot','phone','tablet','mac','bot','phone','tablet','mac',NULL])").should match \
      '"bot"=>"2", "mac"=>"2", "phone"=>"2", "tablet"=>"2"'
    query("SELECT device_istore_from_array(ARRAY['bot','phone','tablet','mac','bot','phone','tablet','mac',NULL,'bot',NULL,'bot','phone','tablet','mac','bot','phone','tablet','mac'])").should match \
      '"bot"=>"5", "mac"=>"4", "phone"=>"4", "tablet"=>"4"'
    query("SELECT device_istore_from_array(ARRAY['bot'::device_type])").should match \
      '"bot"=>"1"'
    query("SELECT device_istore_from_array(ARRAY['bot'::device_type,'bot'::device_type,'bot'::device_type,'bot'::device_type])").should match \
      '"bot"=>"4"'
    query("SELECT device_istore_from_array(NULL::text[])").should match nil
    query("SELECT device_istore_from_array(ARRAY['bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type])").should match \
      '"bot"=>"1", "mac"=>"1", "phone"=>"1", "tablet"=>"1"'
    query("SELECT device_istore_from_array(ARRAY['bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type])").should match \
      '"bot"=>"2", "mac"=>"2", "phone"=>"2", "tablet"=>"2"'
    query("SELECT device_istore_from_array(ARRAY['bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,NULL])").should match \
      '"bot"=>"2", "mac"=>"2", "phone"=>"2", "tablet"=>"2"'
    query("SELECT device_istore_from_array(ARRAY[NULL,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type])").should match \
      '"bot"=>"2", "mac"=>"2", "phone"=>"2", "tablet"=>"2"'
    query("SELECT device_istore_from_array(ARRAY[NULL,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,NULL])").should match \
      '"bot"=>"2", "mac"=>"2", "phone"=>"2", "tablet"=>"2"'
    query("SELECT device_istore_from_array(ARRAY['bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,NULL,'bot'::device_type,NULL,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type,'bot'::device_type,'phone'::device_type,'tablet'::device_type,'mac'::device_type])").should match \
      '"bot"=>"5", "mac"=>"4", "phone"=>"4", "tablet"=>"4"'
    query("SELECT device_istore_from_array(ARRAY[NULL::device_type,NULL::device_type,NULL::device_type,NULL::device_type,NULL::device_type,NULL::device_type,NULL::device_type,NULL::device_type,NULL,NULL::device_type,NULL])").should match ''
    query("SELECT device_istore_from_array(ARRAY[]::device_type[])").should match ''
  end

  it 'should agg an array of device_istores' do
    query("SELECT device_istore_agg(ARRAY['phone=>1']::device_istore[])").should match \
      '"phone"=>"1"'
    query("SELECT device_istore_agg(ARRAY['phone=>1','phone=>1']::device_istore[])").should match \
      '"phone"=>"2"'
    query("SELECT device_istore_agg(ARRAY['phone=>1,tablet=>1','phone=>1,tablet=>-1']::device_istore[])").should match \
      '"phone"=>"2", "tablet"=>"0"'
    query("SELECT device_istore_agg(ARRAY['phone=>1,tablet=>1','phone=>1,tablet=>-1',NULL]::device_istore[])").should match \
      '"phone"=>"2", "tablet"=>"0"'
    query("SELECT device_istore_agg(ARRAY[NULL,'phone=>1,tablet=>1','phone=>1,tablet=>-1']::device_istore[])").should match \
      '"phone"=>"2", "tablet"=>"0"'
    query("SELECT device_istore_agg(ARRAY[NULL,'phone=>1,tablet=>1','phone=>1,tablet=>-1',NULL]::device_istore[])").should match \
      '"phone"=>"2", "tablet"=>"0"'
  end

  it 'should sum up device_istores' do
    query("SELECT device_istore_sum_up('phone=>1'::device_istore)").should match '1'
    query("SELECT device_istore_sum_up(NULL::device_istore)").should match nil
    query("SELECT device_istore_sum_up('phone=>1, tablet=>1'::device_istore)").should match '2'
    query("SELECT device_istore_sum_up('phone=>1 ,tablet=>-1, phone=>1'::device_istore)").should match '1'
  end

  it 'should SUM device_istores FROM table' do
    query("CREATE TABLE test (a device_istore)")
    query("INSERT INTO test VALUES ('phone=>1'), ('tablet=>1'), ('mac=>1')")
    query("SELECT SUM(a) FROM test").should match \
      '"mac"=>"1", "phone"=>"1", "tablet"=>"1"'
  end

  it 'should SUM device_istores FROM table' do
    query("CREATE TABLE test (a device_istore)")
    query("INSERT INTO test VALUES ('phone=>1'), ('tablet=>1'), ('mac=>1'), (NULL), ('mac=>3')")
    query("SELECT SUM(a) FROM test").should match \
      '"mac"=>"4", "phone"=>"1", "tablet"=>"1"'
  end

end
