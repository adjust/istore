require 'spec_helper'

describe 'casts' do
  before do
    install_extension
  end

  it 'should cast from istore to bigistore' do
    query("SELECT '1=>1, -1=>-1'::istore::bigistore").should match '"-1"=>"-1", "1"=>"1"'
  end

  it 'should cast from bigistore to istore' do
    query("SELECT '1=>1, -1=>-1'::bigistore::istore").should match '"-1"=>"-1", "1"=>"1"'
  end

  it 'should fail cast from bigistore to istore if any value is to big' do
    expect{query("SELECT '1=>1, -1=>3000000000'::bigistore::istore")}.to throw_error "integer out of range"
  end
end