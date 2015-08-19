require 'spec_helper'

describe 'binary_copy' do
  before do
    install_extension
  end

  def vals_to_match(vals)
    vals.map{|v| [v]}
  end

  def vals_to_input(vals)
    vals.map{|v| "('#{v}')"}.join(',')
  end

  test_types_and_values =
  {
     'istore' => ['"1"=>"1"', '"1"=>"2"', '"1"=>"3"', '"2"=>"1"', '"2"=>NULL', '"2"=>"2"'],
  }

  test_types_and_values.each do |type, vals|
    it "should copy data binary from country" do
      query("CREATE TABLE before (a istore)")
      query("INSERT INTO before values ('1=>1'),('1=>2'),('1=>3'),('2=>1'),('2=>NULL'),('2=>2')")
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
end
