require 'spec_helper'

describe 'functions_country' do
  before do
    install_extension
  end

  it 'should find keys with exists' do
    query("SELECT exist('de=>1'::country_istore, 'de')").should match 't'
    query("SELECT exist('de=>1'::country_istore, 'es')").should match 'f'
    query("SELECT exist('de=>1, es=>0'::country_istore, 'uk')").should match 'f'
    query("SELECT exist('de=>1, es=>0'::country_istore, 'es')").should match 't'
  end

  it 'should fetchvals' do
    query("SELECT fetchval('de=>1'::country_istore, 'de');").should match '1'
    query("SELECT fetchval('us=>1'::country_istore, 'uk');").should match nil
    query("SELECT fetchval('de=>1, de=>1'::country_istore, 'uk');").should match nil
    query("SELECT fetchval('de=>1, de=>1'::country_istore, 'de');").should match '2'
  end

  it 'should add country_istores' do
    query("SELECT add('de=>1, us=>1'::country_istore, 'de=>1, us=>1'::country_istore);").should match \
      '"de"=>"2", "us"=>"2"'
    query("SELECT add('de=>1, us=>1'::country_istore, 'es=>1, us=>1'::country_istore);").should match \
      '"de"=>"1", "es"=>"1", "us"=>"2"'
    query("SELECT add('de=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);").should match \
      '"de"=>"1", "es"=>"-1", "us"=>"2"'
    query("SELECT add('es=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);").should match \
      '"es"=>"0", "us"=>"2"'
    query("SELECT add('es=>-1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore);").should match \
      '"es"=>"-2", "us"=>"2"'
    query("SELECT add('es=>-1, us=>1'::country_istore, 1);").should match \
      '"es"=>"0", "us"=>"2"'
    query("SELECT add('es=>-1, us=>1'::country_istore, -1);").should match \
      '"es"=>"-2", "us"=>"0"'
    query("SELECT add('es=>-1, us=>1'::country_istore, 0);").should match \
      '"es"=>"-1", "us"=>"1"'
  end

  it 'should substract country_istores' do
    query("SELECT subtract('de=>1, us=>1'::country_istore, 'de=>1, us=>1'::country_istore)").should match \
     '"de"=>"0", "us"=>"0"'
    query("SELECT subtract('de=>1, us=>1'::country_istore, 'es=>1, us=>1'::country_istore)").should match \
     '"de"=>"1", "es"=>"-1", "us"=>"0"'
    query("SELECT subtract('de=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore)").should match \
     '"de"=>"1", "es"=>"1", "us"=>"0"'
    query("SELECT subtract('es=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore)").should match \
     '"es"=>"2", "us"=>"0"'
    query("SELECT subtract('es=>-1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore)").should match \
     '"es"=>"0", "us"=>"0"'
    query("SELECT subtract('es=>-1, us=>1'::country_istore, 1)").should match \
     '"es"=>"-2", "us"=>"0"'
    query("SELECT subtract('es=>-1, us=>1'::country_istore, -1)").should match \
     '"es"=>"0", "us"=>"2"'
    query("SELECT subtract('es=>-1, us=>1'::country_istore, 0)").should match \
     '"es"=>"-1", "us"=>"1"'
  end

  it 'should multiply country_istores' do
    query("SELECT multiply('de=>1, us=>1'::country_istore, 'de=>1, us=>1'::country_istore)").should match \
     '"de"=>"1", "us"=>"1"'
    query("SELECT multiply('de=>1, us=>1'::country_istore, 'es=>1, us=>1'::country_istore)").should match \
     '"de"=>NULL, "es"=>NULL, "us"=>"1"'
    query("SELECT multiply('de=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore)").should match \
     '"de"=>NULL, "es"=>NULL, "us"=>"1"'
    query("SELECT multiply('es=>1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore)").should match \
     '"es"=>"-1", "us"=>"1"'
    query("SELECT multiply('es=>-1, us=>1'::country_istore, 'es=>-1, us=>1'::country_istore)").should match \
     '"es"=>"1", "us"=>"1"'
    query("SELECT multiply('es=>-1, us=>1'::country_istore, 1)").should match \
     '"es"=>"-1", "us"=>"1"'
    query("SELECT multiply('es=>-1, us=>1'::country_istore, -1)").should match \
     '"es"=>"1", "us"=>"-1"'
    query("SELECT multiply('es=>-1, us=>1'::country_istore, 0)").should match \
     '"es"=>"0", "us"=>"0"'
  end

  it 'should build a country_isotre_from array aka array_count' do
    query("SELECT country_istore_from_array(ARRAY['de'])").should match \
      '"de"=>"1"'
    query("SELECT country_istore_from_array(ARRAY['de','de','de','de'])").should match \
      '"de"=>"4"'
    query("SELECT country_istore_from_array(NULL::text[])").should match nil
    query("SELECT country_istore_from_array(ARRAY['de','es','io','us'])").should match \
      '"de"=>"1", "es"=>"1", "io"=>"1", "us"=>"1"'
    query("SELECT country_istore_from_array(ARRAY['de','es','io','us','de','es','io','us'])").should match \
      '"de"=>"2", "es"=>"2", "io"=>"2", "us"=>"2"'
    query("SELECT country_istore_from_array(ARRAY['de','es','io','us','de','es','io','us',NULL])").should match \
      '"de"=>"2", "es"=>"2", "io"=>"2", "us"=>"2"'
    query("SELECT country_istore_from_array(ARRAY[NULL,'de','es','io','us','de','es','io','us'])").should match \
      '"de"=>"2", "es"=>"2", "io"=>"2", "us"=>"2"'
    query("SELECT country_istore_from_array(ARRAY[NULL,'de','es','io','us','de','es','io','us',NULL])").should match \
      '"de"=>"2", "es"=>"2", "io"=>"2", "us"=>"2"'
    query("SELECT country_istore_from_array(ARRAY['de','es','io','us','de','es','io','us',NULL,'de',NULL,'de','es','io','us','de','es','io','us'])").should match \
      '"de"=>"5", "es"=>"4", "io"=>"4", "us"=>"4"'
    query("SELECT country_istore_from_array(ARRAY['de'::country])").should match \
      '"de"=>"1"'
    query("SELECT country_istore_from_array(ARRAY['de'::country,'de'::country,'de'::country,'de'::country])").should match \
      '"de"=>"4"'
    query("SELECT country_istore_from_array(NULL::text[])").should match nil
    query("SELECT country_istore_from_array(ARRAY['de'::country,'es'::country,'io'::country,'us'::country])").should match \
      '"de"=>"1", "es"=>"1", "io"=>"1", "us"=>"1"'
    query("SELECT country_istore_from_array(ARRAY['de'::country,'es'::country,'io'::country,'us'::country,'de'::country,'es'::country,'io'::country,'us'::country])").should match \
      '"de"=>"2", "es"=>"2", "io"=>"2", "us"=>"2"'
    query("SELECT country_istore_from_array(ARRAY['de'::country,'es'::country,'io'::country,'us'::country,'de'::country,'es'::country,'io'::country,'us'::country,NULL])").should match \
      '"de"=>"2", "es"=>"2", "io"=>"2", "us"=>"2"'
    query("SELECT country_istore_from_array(ARRAY[NULL,'de'::country,'es'::country,'io'::country,'us'::country,'de'::country,'es'::country,'io'::country,'us'::country])").should match \
      '"de"=>"2", "es"=>"2", "io"=>"2", "us"=>"2"'
    query("SELECT country_istore_from_array(ARRAY[NULL,'de'::country,'es'::country,'io'::country,'us'::country,'de'::country,'es'::country,'io'::country,'us'::country,NULL])").should match \
      '"de"=>"2", "es"=>"2", "io"=>"2", "us"=>"2"'
    query("SELECT country_istore_from_array(ARRAY['de'::country,'es'::country,'io'::country,'us'::country,'de'::country,'es'::country,'io'::country,'us'::country,NULL,'de'::country,NULL,'de'::country,'es'::country,'io'::country,'us'::country,'de'::country,'es'::country,'io'::country,'us'::country])").should match \
      '"de"=>"5", "es"=>"4", "io"=>"4", "us"=>"4"'
    query("SELECT country_istore_from_array(ARRAY[NULL::country,NULL::country,NULL::country,NULL::country,NULL::country,NULL::country,NULL::country,NULL::country,NULL,NULL::country,NULL])").should match nil
  end

  it 'should sum up an array of country_istores' do
    query("SELECT country_istore_agg(ARRAY['de=>1']::country_istore[]);").should match \
     '"de"=>"1"'
    query("SELECT country_istore_agg(ARRAY['de=>1','de=>1']::country_istore[]);").should match \
     '"de"=>"2"'
    query("SELECT country_istore_agg(ARRAY['de=>1,us=>1','de=>1,us=>-1']::country_istore[]);").should match \
     '"de"=>"2", "us"=>"0"'
    query("SELECT country_istore_agg(ARRAY['de=>1,us=>1','de=>1,us=>-1',NULL]::country_istore[]);").should match \
     '"de"=>"2", "us"=>"0"'
    query("SELECT country_istore_agg(ARRAY[NULL,'de=>1,us=>1','de=>1,us=>-1']::country_istore[]);").should match \
     '"de"=>"2", "us"=>"0"'
    query("SELECT country_istore_agg(ARRAY[NULL,'de=>1,us=>1','de=>1,us=>-1',NULL]::country_istore[]);").should match \
     '"de"=>"2", "us"=>"0"'
  end

  it 'should sum up the total' do
    query("SELECT country_istore_sum_up('de=>1'::country_istore)").should match 1
    query("SELECT country_istore_sum_up(NULL::country_istore)").should match nil
    query("SELECT country_istore_sum_up('de=>1, us=>1'::country_istore)").should match 2
    query("SELECT country_istore_sum_up('de=>1 ,us=>-1, de=>1'::country_istore)").should match 1
    query("SELECT country_istore_sum_up('de=>3000000000 ,us=>4000000000, de=>3000000000'::country_istore)").should match 10000000000
  end

  it 'should SUM istores' do
    query("CREATE TABLE test (a country_istore)")
    query("INSERT INTO test VALUES ('de=>1'), ('us=>1'),('io=>1')")
    query("SELECT SUM(a) FROM test").should match \
      '"de"=>"1", "io"=>"1", "us"=>"1"'
  end

  it 'should SUM istores' do
    query("CREATE TABLE test (a country_istore)")
    query("INSERT INTO test VALUES ('de=>1'), ('us=>1'), ('io=>1'), (NULL), ('io=>3')")
    query("SELECT SUM(a) FROM test").should match \
      '"de"=>"1", "io"=>"4", "us"=>"1"'
  end
end
