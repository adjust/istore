require 'spec_helper'

describe 'functions_os_name' do
  before do
    install_extension
  end

  it 'should find presence of a key' do
    query("SELECT exist('ios=>1'::os_name_istore, 'ios')").should match 't'
    query("SELECT exist('ios=>1'::os_name_istore, 'android')").should match 'f'
    query("SELECT exist('ios=>1, android=>0'::os_name_istore, 'ios')").should match 't'
    query("SELECT exist('ios=>1, android=>0'::os_name_istore, 'windows')").should match 'f'
  end

  it 'should fetch values' do
    query("SELECT fetchval('ios=>1'::os_name_istore, 'ios')").should match '1'
    query("SELECT fetchval('windows=>1'::os_name_istore, 'ios')").should match nil
    query("SELECT fetchval('ios=>1, ios=>1'::os_name_istore, 'ios')").should match '2'
    query("SELECT fetchval('ios=>1, ios=>1'::os_name_istore, 'windows')").should match nil
  end

  it 'should add to os_name_istores' do
    query("SELECT add('ios=>1, windows=>1'::os_name_istore, 'ios=>1, windows=>1'::os_name_istore)").should match \
     '"ios"=>"2", "windows"=>"2"'

    query("SELECT add('ios=>1, windows=>1'::os_name_istore, 'android=>1, windows=>1'::os_name_istore)").should match \
     '"android"=>"1", "ios"=>"1", "windows"=>"2"'

    query("SELECT add('ios=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"-1", "ios"=>"1", "windows"=>"2"'

    query("SELECT add('android=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"0", "windows"=>"2"'

    query("SELECT add('android=>-1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"-2", "windows"=>"2"'

    query("SELECT add('android=>-1, windows=>1'::os_name_istore, 1)").should match \
     '"android"=>"0", "windows"=>"2"'

    query("SELECT add('android=>-1, windows=>1'::os_name_istore, -1)").should match \
     '"android"=>"-2", "windows"=>"0"'

    query("SELECT add('android=>-1, windows=>1'::os_name_istore, 0)").should match \
     '"android"=>"-1", "windows"=>"1"'
  end

  it 'should substract to os_name_istores' do
    query("SELECT subtract('ios=>1, windows=>1'::os_name_istore, 'ios=>1, windows=>1'::os_name_istore)").should match \
     '"ios"=>"0", "windows"=>"0"'

    query("SELECT subtract('ios=>1, windows=>1'::os_name_istore, 'android=>1, windows=>1'::os_name_istore)").should match \
     '"android"=>"-1", "ios"=>"1", "windows"=>"0"'

    query("SELECT subtract('ios=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"1", "ios"=>"1", "windows"=>"0"'

    query("SELECT subtract('android=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"2", "windows"=>"0"'

    query("SELECT subtract('android=>-1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"0", "windows"=>"0"'

    query("SELECT subtract('android=>-1, windows=>1'::os_name_istore, 1)").should match \
     '"android"=>"-2", "windows"=>"0"'

    query("SELECT subtract('android=>-1, windows=>1'::os_name_istore, -1)").should match \
     '"android"=>"0", "windows"=>"2"'

    query("SELECT subtract('android=>-1, windows=>1'::os_name_istore, 0)").should match \
     '"android"=>"-1", "windows"=>"1"'
  end

  it 'should multiply two os_name_istores' do
    query("SELECT multiply('ios=>1, windows=>1'::os_name_istore, 'ios=>1, windows=>1'::os_name_istore)").should match \
     '"ios"=>"1", "windows"=>"1"'

    query("SELECT multiply('ios=>1, windows=>1'::os_name_istore, 'android=>1, windows=>1'::os_name_istore)").should match \
     '"android"=>NULL, "ios"=>NULL, "windows"=>"1"'

    query("SELECT multiply('ios=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>NULL, "ios"=>NULL, "windows"=>"1"'

    query("SELECT multiply('android=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"-1", "windows"=>"1"'

    query("SELECT multiply('android=>-1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"1", "windows"=>"1"'

    query("SELECT multiply('android=>-1, windows=>1'::os_name_istore, 1)").should match \
     '"android"=>"-1", "windows"=>"1"'

    query("SELECT multiply('android=>-1, windows=>1'::os_name_istore, -1)").should match \
     '"android"=>"1", "windows"=>"-1"'

    query("SELECT multiply('android=>-1, windows=>1'::os_name_istore, 0)").should match \
     '"android"=>"0", "windows"=>"0"'
  end

  it 'should divide two os_name_istores' do
    query("SELECT divide('ios=>1, windows=>1'::os_name_istore, 'ios=>1, windows=>1'::os_name_istore)").should match \
     '"ios"=>"1", "windows"=>"1"'

    query("SELECT divide('ios=>1, windows=>1'::os_name_istore, 'android=>1, windows=>1'::os_name_istore)").should match \
     '"android"=>NULL, "ios"=>NULL, "windows"=>"1"'

    query("SELECT divide('ios=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>NULL, "ios"=>NULL, "windows"=>"1"'

    query("SELECT divide('android=>1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"-1", "windows"=>"1"'

    query("SELECT divide('android=>-1, windows=>1'::os_name_istore, 'android=>-1, windows=>1'::os_name_istore)").should match \
     '"android"=>"1", "windows"=>"1"'

    query("SELECT divide('android=>-1, windows=>1'::os_name_istore, 1)").should match \
     '"android"=>"-1", "windows"=>"1"'

    query("SELECT divide('android=>-1, windows=>1'::os_name_istore, -1)").should match \
     '"android"=>"1", "windows"=>"-1"'

    query("SELECT divide('android=>-1, windows=>1'::os_name_istore, 0)").should match \
     '"android"=>NULL, "windows"=>NULL'
   end

   it 'should generate an os_name_istore from array' do
    query("SELECT os_name_istore_from_array(ARRAY['android'])").should match \
     '"android"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY['android','android','android','android'])").should match \
     '"android"=>"4"'

    query("SELECT os_name_istore_from_array(NULL::text[])").should match nil

    query("SELECT os_name_istore_from_array(ARRAY['android','ios','windows','windows-phone'])").should match \
     '"android"=>"1", "ios"=>"1", "windows"=>"1", "windows-phone"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY['android','ios','windows','windows-phone','android','ios','windows','windows-phone'])").should match \
     '"android"=>"2", "ios"=>"2", "windows"=>"2", "windows-phone"=>"2"'

    query("SELECT os_name_istore_from_array(ARRAY['android','ios','windows','windows-phone','android','ios','windows',NULL])").should match \
     '"android"=>"2", "ios"=>"2", "windows"=>"2", "windows-phone"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY[NULL,'ios','windows','windows-phone','android','ios','windows','windows-phone'])").should match \
     '"android"=>"1", "ios"=>"2", "windows"=>"2", "windows-phone"=>"2"'

    query("SELECT os_name_istore_from_array(ARRAY[NULL,'ios','windows','windows-phone','android','ios','windows',NULL])").should match \
     '"android"=>"1", "ios"=>"2", "windows"=>"2", "windows-phone"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY['android','ios','windows',NULL,'android',NULL,'windows','windows-phone','android','ios','windows'])").should match \
     '"android"=>"3", "ios"=>"2", "windows"=>"3", "windows-phone"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY['android'::os_name])").should match \
     '"android"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY['android'::os_name,'android'::os_name,'android'::os_name,'android'::os_name])").should match \
     '"android"=>"4"'

    query("SELECT os_name_istore_from_array(NULL::text[])").should match nil

    query("SELECT os_name_istore_from_array(ARRAY['android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name])").should match \
     '"android"=>"1", "ios"=>"1", "windows"=>"1", "windows-phone"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY['android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name])").should match \
     '"android"=>"2", "ios"=>"2", "windows"=>"2", "windows-phone"=>"2"'

    query("SELECT os_name_istore_from_array(ARRAY['android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name,NULL])").should match \
     '"android"=>"2", "ios"=>"2", "windows"=>"2", "windows-phone"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY[NULL,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name])").should match \
     '"android"=>"1", "ios"=>"2", "windows"=>"2", "windows-phone"=>"2"'

    query("SELECT os_name_istore_from_array(ARRAY[NULL,'ios'::os_name,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name, NULL])").should match \
    '"android"=>"1", "ios"=>"2", "windows"=>"2", "windows-phone"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY['android'::os_name,'ios'::os_name,'windows'::os_name,NULL,'android'::os_name,NULL,'windows'::os_name,'windows-phone'::os_name,'android'::os_name,'ios'::os_name,'windows'::os_name])").should match \
     '"android"=>"3", "ios"=>"2", "windows"=>"3", "windows-phone"=>"1"'

    query("SELECT os_name_istore_from_array(ARRAY[NULL::os_name,NULL::os_name,NULL::os_name,NULL::os_name,NULL::os_name,NULL::os_name,NULL::os_name,NULL::os_name,NULL,NULL::os_name,NULL])").should match ''

    query("SELECT os_name_istore_from_array(ARRAY[]::os_name[])").should match ''
   end

   it 'should agg an array of os_name_istores' do
    query("SELECT os_name_istore_agg(ARRAY['ios=>1']::os_name_istore[])").should match \
     '"ios"=>"1"'

    query("SELECT os_name_istore_agg(ARRAY['ios=>1','ios=>1']::os_name_istore[])").should match \
     '"ios"=>"2"'

    query("SELECT os_name_istore_agg(ARRAY['ios=>1,windows=>1','ios=>1,windows=>-1']::os_name_istore[])").should match \
     '"ios"=>"2", "windows"=>"0"'

    query("SELECT os_name_istore_agg(ARRAY['ios=>1,windows=>1','ios=>1,windows=>-1',NULL]::os_name_istore[])").should match \
     '"ios"=>"2", "windows"=>"0"'

    query("SELECT os_name_istore_agg(ARRAY[NULL,'ios=>1,windows=>1','ios=>1,windows=>-1']::os_name_istore[])").should match \
     '"ios"=>"2", "windows"=>"0"'

    query("SELECT os_name_istore_agg(ARRAY[NULL,'ios=>1,windows=>1','ios=>1,windows=>-1',NULL]::os_name_istore[])").should match \
     '"ios"=>"2", "windows"=>"0"'
   end

   it 'should sum_up os_name_istores' do
    query("SELECT os_name_istore_sum_up('ios=>1'::os_name_istore)").should match 1

    query("SELECT os_name_istore_sum_up(NULL::os_name_istore)").should match nil

    query("SELECT os_name_istore_sum_up('ios=>1, windows=>1'::os_name_istore)").should match 2

    query("SELECT os_name_istore_sum_up('ios=>1 ,windows=>-1, ios=>1'::os_name_istore)").should match 1
   end

   it 'should SUM os_names FROM table' do
    query("CREATE TABLE test (a os_name_istore)")
    query("INSERT INTO test VALUES('ios=>1'),('windows=>1'),('windows-phone=>1')")
    query("SELECT SUM(a) FROM test").should match \
      '"ios"=>"1", "windows"=>"1", "windows-phone"=>"1"'
   end

   it 'should SUM os_names FROM table' do
    query("CREATE TABLE test (a os_name_istore)")
    query("INSERT INTO test VALUES('ios=>1'),('windows=>1'),('windows-phone=>1'),(NULL),('windows-phone=>3')")
    query("SELECT SUM(a) FROM test").should match \
      '"ios"=>"1", "windows"=>"1", "windows-phone"=>"4"'
   end
end
