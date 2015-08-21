require 'spec_helper'

describe 'binary_copy' do
  before do
    install_extension
  end

  it "should copy data binary from country" do
    query("CREATE TABLE before (a istore)")
    query("INSERT INTO before values ('1=>1'),('1=>2'),('1=>3'),('2=>1'),('2=>0'),('2=>2')")
    query("CREATE TABLE after (a istore)")
    query("COPY before TO '/tmp/tst' WITH (FORMAT binary)")
    query("COPY after FROM '/tmp/tst' WITH (FORMAT binary)")
    query("SELECT * FROM after").should match \
      ['"1"=>"1"'],
      ['"1"=>"2"'],
      ['"1"=>"3"'],
      ['"2"=>"0"'],
      ['"2"=>"1"'],
      ['"2"=>"2"']
  end
end
