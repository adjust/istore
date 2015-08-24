require 'spec_helper'

types.each do |type|
  describe "#{type}" do
    describe 'binary_copy' do
      before do
        install_extension
      end
      it "should copy data binary from country" do
        # binding.pry
        query("CREATE TABLE before (a #{type})")
        query("INSERT INTO before values ('1=>1'),('1=>#{values[type][:low]}'),('1=>3'),('2=>1'),('2=>0'),('2=>#{values[type][:high]}')")
        query("CREATE TABLE after (a #{type})")
        query("COPY before TO '/tmp/tst' WITH (FORMAT binary)")
        query("COPY after FROM '/tmp/tst' WITH (FORMAT binary)")
        query("SELECT * FROM after").should match \
          [%{"1"=>"#{values[type][:low]}"}],
          ['"1"=>"1"'],
          ['"1"=>"3"'],
          ['"2"=>"0"'],
          ['"2"=>"1"'],
          [%{"2"=>"#{values[type][:high]}"}]
      end
    end
  end
end
