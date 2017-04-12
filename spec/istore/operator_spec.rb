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
          query("SELECT '0=>40000000000'::bigistore->0").should match 40000000000 if type == :bigistore
          query("SELECT #{sample[type]}::#{type} -> 10").should match \
            sample_hash[type][10]
          query("SELECT #{sample[type]}::#{type} -> Array[10,0]").should match \
            arr_to_sql_arr [10,0].map{|k| sample_hash[type][k]}.to_s
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

        it 'should return convert to array' do
          query("SELECT %%#{sample[type]}::#{type}").should match \
          arr_to_sql_arr sample_hash[type].to_a.flatten
          query("SELECT %##{sample[type]}::#{type}").should match \
          arr_to_sql_arr sample_hash[type].to_a
        end

        describe 'existence' do
          it 'should check presence of a key' do
            query("SELECT #{sample[type]}::#{type} ? 10").should match 't'
            query("SELECT #{sample[type]}::#{type} ? 25").should match 'f'
          end
          it 'should check presence of any key' do
            query("SELECT #{sample[type]}::#{type} ?| Array[10,0]").should match 't'
            query("SELECT #{sample[type]}::#{type} ?| Array[27,25]").should match 'f'
          end
          it 'should check presence of all key' do
            query("SELECT #{sample[type]}::#{type} ?& Array[10,0]").should match 't'
            query("SELECT #{sample[type]}::#{type} ?& Array[27,25]").should match 'f'
          end
        end
      end
    end
  end
end