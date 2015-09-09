require 'spec_helper'
types.each do |type|
  describe "#{type}" do
    describe 'operators' do
      before do
        install_extension
      end

      describe "#{type}" do
        it 'should fetch values' do
          query("SELECT '1=>1, -1=>0'::#{type} -> -1").should match 0
          query("SELECT '1=>1, -1=>3'::#{type} -> -1").should match 3
        end

        it'should check existense of a key' do
          query("SELECT '1=>1, -1=>3'::#{type} ? -1").should match 't'
          query("SELECT '1=>1, -1=>3'::#{type} ? 5").should match 'f'
        end

        it "should add two #{type}" do
          query("SELECT '1=>1, -1=>3'::#{type} + '1=>1'::#{type}").should match \
          '"-1"=>"3", "1"=>"2"'
          query("SELECT '1=>1, -1=>3'::#{type} + '-1=>-1'::#{type}").should match \
          '"-1"=>"2", "1"=>"1"'
          query("SELECT '1=>1, -1=>3'::#{type} + '1=>-1'::#{type}").should match \
          '"-1"=>"3", "1"=>"0"'
          query("SELECT '1=>0, -1=>3'::#{type} + '1=>-1'::#{type}").should match \
          '"-1"=>"3", "1"=>"-1"'
          query("SELECT '1=>1, -1=>0'::#{type} + '-1=>-1'::#{type}").should match \
          '"-1"=>"-1", "1"=>"1"'
       end

        it 'should add an integer to #{type}' do
          query("SELECT '1=>1, -1=>3'::#{type}  + 1").should match \
          '"-1"=>"4", "1"=>"2"'
          query("SELECT '-1=>1, 1=>3'::#{type}  + 1").should match \
          '"-1"=>"2", "1"=>"4"'
          query("SELECT '-1=>1, -1=>3'::#{type} + 1").should match \
          '"-1"=>"5"'
          query("SELECT '1=>1, -1=>3'::#{type}  + 0").should match \
          '"-1"=>"3", "1"=>"1"'
          query("SELECT '-1=>1, 1=>3'::#{type}  + 0").should match \
          '"-1"=>"1", "1"=>"3"'
          query("SELECT '-1=>1, -1=>3'::#{type} + 0").should match \
          '"-1"=>"4"'
          query("SELECT '1=>1, -1=>3'::#{type}  + -1").should match \
          '"-1"=>"2", "1"=>"0"'
          query("SELECT '-1=>1, 1=>3'::#{type}  + -1").should match \
          '"-1"=>"0", "1"=>"2"'
          query("SELECT '-1=>1, -1=>3'::#{type} + -1").should match \
          '"-1"=>"3"'
       end

        it "should substract two #{type}" do
          query("SELECT '1=>1, -1=>3'::#{type} - '1=>1'::#{type}").should match \
          '"-1"=>"3", "1"=>"0"'
          query("SELECT '1=>1, -1=>3'::#{type} - '-1=>-1'::#{type}").should match \
          '"-1"=>"4", "1"=>"1"'
          query("SELECT '1=>1, -1=>3'::#{type} - '1=>-1'::#{type}").should match \
          '"-1"=>"3", "1"=>"2"'
          query("SELECT '1=>0, -1=>3'::#{type} - '1=>-1'::#{type}").should match \
          '"-1"=>"3", "1"=>"1"'
       end

        it "should substract integer from #{type}" do
          query("SELECT '1=>1, -1=>3'::#{type}  - 1").should match \
          '"-1"=>"2", "1"=>"0"'
          query("SELECT '-1=>1, 1=>3'::#{type}  - 1").should match \
          '"-1"=>"0", "1"=>"2"'
          query("SELECT '-1=>1, -1=>3'::#{type} - 1").should match \
          '"-1"=>"3"'
          query("SELECT '1=>1, -1=>3'::#{type}  - 0").should match \
          '"-1"=>"3", "1"=>"1"'
          query("SELECT '-1=>1, 1=>3'::#{type}  - 0").should match \
          '"-1"=>"1", "1"=>"3"'
          query("SELECT '-1=>1, -1=>3'::#{type} - 0").should match \
          '"-1"=>"4"'
          query("SELECT '1=>1, -1=>3'::#{type}  - -1").should match \
          '"-1"=>"4", "1"=>"2"'
          query("SELECT '-1=>1, 1=>3'::#{type}  - -1").should match \
          '"-1"=>"2", "1"=>"4"'
          query("SELECT '-1=>1, -1=>3'::#{type} - -1").should match \
          '"-1"=>"5"'
       end

        it "should multiply two #{type}" do
          query("SELECT '1=>3, 2=>2'::#{type} * '1=>2, 3=>5'::#{type}").should match \
          '"1"=>"6"'
          query("SELECT '-1=>3, 2=>2'::#{type} * '-1=>2, 3=>5'::#{type}").should match \
          '"-1"=>"6"'
          query("SELECT '-1=>3, 2=>2'::#{type} * '-1=>-2, 3=>5'::#{type}").should match \
          '"-1"=>"-6"'
          query("SELECT '-1=>3, 2=>0'::#{type} * '-1=>-2, 3=>5'::#{type}").should match \
          '"-1"=>"-6"'
       end

        it 'should multiply #{type} with integer' do
          query("SELECT '1=>1, -1=>3'::#{type}  * 1").should match \
          '"-1"=>"3", "1"=>"1"'
          query("SELECT '-1=>1, 1=>3'::#{type}  * 1").should match \
          '"-1"=>"1", "1"=>"3"'
          query("SELECT '-1=>1, -1=>3'::#{type} * 1").should match \
          '"-1"=>"4"'
          query("SELECT '1=>1, -1=>3'::#{type}  * 0").should match \
          '"-1"=>"0", "1"=>"0"'
          query("SELECT '-1=>1, 1=>3'::#{type}  * 0").should match \
          '"-1"=>"0", "1"=>"0"'
          query("SELECT '-1=>1, -1=>3'::#{type} * 0").should match \
          '"-1"=>"0"'
          query("SELECT '1=>1, -1=>3'::#{type}  * -1").should match \
          '"-1"=>"-3", "1"=>"-1"'
          query("SELECT '-1=>1, 1=>3'::#{type}  * -1").should match \
          '"-1"=>"-1", "1"=>"-3"'
          query("SELECT '-1=>1, -1=>3'::#{type} * -1").should match \
          '"-1"=>"-4"'
        end
      end
    end
  end
end