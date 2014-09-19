require 'spec_helper'

describe 'istore_io' do
  before do
    install_extension
  end

  it 'should persist istores' do
    puts query(%{CREATE TABLE istore_io AS SELECT '1=>1,1=>2'::istore})
    query("SELECT * FROM istore_io").should match \
    '"1"=>"3"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '"1"=>"1", "1"=>"2"'::istore})
    query("SELECT * FROM istore_io").should match \
    '"1"=>"3"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '"1"=>"1", "-1"=>"2"'::istore})
    query("SELECT * FROM istore_io").should match \
    '"-1"=>"2", "1"=>"1"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '"-1"=>"+1","1"=>"2"'::istore})
    query("SELECT * FROM istore_io").should match \
    '"-1"=>"1", "1"=>"2"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT ' "-1"=>"+1","1"=>"2"'::istore})
    query("SELECT * FROM istore_io").should match \
    '"-1"=>"1", "1"=>"2"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '"-1"=> "+1","1"=>"2"'::istore})
    query("SELECT * FROM istore_io").should match \
    '"-1"=>"1", "1"=>"2"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '"-1"=>"+1", "1"=>"2"'::istore})
    query("SELECT * FROM istore_io").should match \
    '"-1"=>"1", "1"=>"2"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '"-1"=>"+1","1"=>"2" '::istore})
    query("SELECT * FROM istore_io").should match \
    '"-1"=>"1", "1"=>"2"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '-1=>+1,1=>2 '::istore})
    query("SELECT * FROM istore_io").should match \
    '"-1"=>"1", "1"=>"2"'
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '"-1"=>"+1" ,"1"=>"2"'::istore})
    query("SELECT * FROM istore_io").should match \
    '"-1"=>"1", "1"=>"2"'
  end

  it 'should persist empty istores' do
    query(%{CREATE TABLE istore_io AS SELECT ''::istore})
    query("SELECT * FROM istore_io").should match ''
  end
end
