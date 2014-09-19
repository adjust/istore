require 'spec_helper'

describe 'os_name_iostore_io' do
  before do
    install_extension
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT 'android=>1,android=>2'::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"3"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT '"android"=>"1", "android"=>"2"'::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"3"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT '"android"=>"1", "ios"=>"2"'::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"1", "ios"=>"2"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1","android"=>"2"'::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"2", "ios"=>"1"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT ' "ios"=>"+1","android"=>"2"'::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"2", "ios"=>"1"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT '"ios"=> "+1","android"=>"2"'::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"2", "ios"=>"1"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1" ,"android"=>"2"'::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"2", "ios"=>"1"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1", "android"=>"2"'::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"2", "ios"=>"1"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT '"ios"=>"+1","android"=>"2" '::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"2", "ios"=>"1"'
  end

  it 'should persist os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT 'ios=>+1,android=>2 '::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match \
    '"android"=>"2", "ios"=>"1"'

  end
  it 'should persist emptz os_name_iostores' do
    query(%{CREATE TABLE os_name_istore_io AS SELECT ''::os_name_istore})
    query("SELECT * FROM os_name_istore_io").should match ''

  end
end
