require 'spec_helper'

describe 'istore_io' do
  before do
    install_extension
  end

  it 'should persist istores' do
    query(%{CREATE TABLE istore_io AS SELECT '1=>1,1=>2'::istore})
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

  describe 'invalud input' do
    it 'should report invalid value input' do
      expect{query("SELECT '2=>4, 1=>foo, 5=>17'::istore")}.to throw_error 'invalid input syntax for istore: "2=>4, 1=>foo, 5=>17"'
    end

    it 'should report invalid value input' do
      expect{query("SELECT '2=>4, 1=>5foo, 5=>17'::istore")}.to throw_error 'invalid input syntax for istore: "2=>4, 1=>5foo, 5=>17"'
    end

    it 'should report invalid key input' do
      expect{query("SELECT '2=>4, 54foo=>5, 5=>17'::istore")}.to throw_error 'invalid input syntax for istore: "2=>4, 54foo=>5, 5=>17"'
    end

    it 'should report invalid key input' do
      expect{query("SELECT '2=>4, foo=>5, 5=>17'::istore")}.to throw_error 'invalid input syntax for istore: "2=>4, foo=>5, 5=>17"'
    end

    it 'should report invalid delimiter input' do
      expect{query("SELECT '2=>4, 10=5, 5=>17'::istore")}.to throw_error 'invalid input syntax for istore: "2=>4, 10=5, 5=>17"'
    end
  end
end
