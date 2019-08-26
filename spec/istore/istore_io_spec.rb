require 'spec_helper'
types.each do |type|
  describe "#{type}" do
    describe 'istore_io' do
      before do
        install_extension
      end

      it 'should persist istores' do
        query(%{CREATE TABLE istore_io AS SELECT #{sample[type]}::#{type}})
        query("SELECT * FROM istore_io").should match \
        sample_out[type]
      end

      it 'should persist istores' do
        query(%{CREATE TABLE istore_io AS SELECT '"-1"=>"+1","1"=>"2"'::#{type}})
        query("SELECT * FROM istore_io").should match \
        '"-1"=>"1", "1"=>"2"'
      end

      it 'should persist istores' do
        query(%{CREATE TABLE istore_io AS SELECT ' "-1"=>"+1","1"=>"2"'::#{type}})
        query("SELECT * FROM istore_io").should match \
        '"-1"=>"1", "1"=>"2"'
      end

      it 'should persist empty istores' do
        query(%{CREATE TABLE istore_io AS SELECT ''::#{type}})
        query("SELECT * FROM istore_io").should match ''
      end

      it 'should turn istore to json' do
        query("SELECT istore_to_json(#{sample[type]}::#{type})").should match \
        %{{"#{values[:istore][:low]}": 10, "-10": #{values[type][:low]}, "0": 5, "10": #{values[type][:high]}, "#{values[:istore][:high]}": 10}}
      end

      describe 'invalid input' do
        it 'should report invalid value input' do
          expect{query("SELECT '2=>4, 1=>foo, 5=>17'::#{type}")}.to throw_error "invalid input syntax for istore: \"2=>4, 1=>foo, 5=>17\""
        end

        it 'should report invalid value input' do
          expect{query("SELECT '2=>4, 1=>5foo, 5=>17'::#{type}")}.to throw_error "invalid input syntax for istore: \"2=>4, 1=>5foo, 5=>17\""
        end

        it 'should report to big value input' do
          err = type == :istore ? "integer out of range" : "istore \"2=>4, 1=>#{values[type][:high]*2}, 5=>17\" is out of range"
          expect{query("SELECT '2=>4, 1=>#{values[type][:high]*2}, 5=>17'::#{type}")}.to throw_error err
        end

        it 'should report to small value input' do
          err = type == :istore ? "integer out of range" : "istore \"2=>4, 1=>#{values[type][:low]*2}, 5=>17\" is out of range"
          expect{query("SELECT '2=>4, 1=>#{values[type][:low]*2}, 5=>17'::#{type}")}.to throw_error err
        end

        it 'should report invalid key input' do
          expect{query("SELECT '2=>4, 54foo=>5, 5=>17'::#{type}")}.to throw_error "invalid input syntax for istore: \"2=>4, 54foo=>5, 5=>17\""
        end

        it 'should report invalid key input' do
          expect{query("SELECT '2=>4, foo=>5, 5=>17'::#{type}")}.to throw_error "invalid input syntax for istore: \"2=>4, foo=>5, 5=>17\""
        end

        it 'should report to big key input' do
          expect{query("SELECT '2=>4, 4000000000=>5, 5=>17'::#{type}")}.to throw_error "istore \"2=>4, 4000000000=>5, 5=>17\" is out of range"
        end

        it 'should report to small key input' do
          expect{query("SELECT '2=>4, -4000000000=>5, 5=>17'::#{type}")}.to throw_error "istore \"2=>4, -4000000000=>5, 5=>17\" is out of range"
        end

        it 'should report invalid delimiter input' do
          expect{query("SELECT '2=>4, 10=5, 5=>17'::#{type}")}.to throw_error "invalid input syntax for istore: \"2=>4, 10=5, 5=>17\""
        end

        it 'should report unexpected end of line' do
          expect{query("SELECT '1=>2,2='::#{type}")}.to throw_error "invalid input syntax for istore: \"1=>2,2=\""
        end
      end
      describe 'array input' do
        it 'should parse normal arrays tuple' do
          query("SELECT '([1,2], [11, 22])'::#{type}").should match \
          '"1"=>"11", "2"=>"22"'
        end
        it 'should parse normal arrays tuple with spaces' do
          query("SELECT '([1, 2] ,[ 11, 22])'::#{type}").should match \
          '"1"=>"11", "2"=>"22"'
        end
        it 'should parse normal small arrays tuple' do
          query("SELECT '([1],[11])'::#{type}").should match \
          '"1"=>"11"'
        end
        it 'should parse normal empty arrays tuple' do
          query("SELECT '([],[])'::#{type}").should match \
          ''
        end
      end
      describe 'array invalid input' do
        it 'should report unexpected end of line' do
          expect{query("SELECT '([1,2], ['::#{type}")}.to throw_error "invalid input syntax for istore: \"([1,2], [\""
        end
        it 'should report expected comma in values' do
          expect{query("SELECT '([1,2], [1'::#{type}")}.to throw_error "invalid input syntax for istore: \"([1,2], [1\""
        end
        it 'should report expected number' do
          expect{query("SELECT '([1,2], [1,'::#{type}")}.to throw_error "invalid input syntax for istore: \"([1,2], [1,\""
        end
        it 'should report on uneven tuples' do
          expect{query("SELECT '([1,2], [1,2,3])'::#{type}")}.to throw_error "invalid input syntax for istore: \"([1,2], [1,2,3])\""
        end
        it 'should report on uneven tuples' do
          expect{query("SELECT '([1,2,3],[1,2])'::#{type}")}.to throw_error "invalid input syntax for istore: \"([1,2,3],[1,2])\""
        end
        it 'should report arrays delimiter' do
          expect{query("SELECT '([1,2]|[1,2])'::#{type}")}.to throw_error "invalid input syntax for istore: \"([1,2]|[1,2])\""
        end
        it 'should report on ending bracket' do
          expect{query("SELECT '([1,2],[1,2]'::#{type}")}.to throw_error "invalid input syntax for istore: \"([1,2],[1,2]\""
        end
      end
      describe 'arrays row input' do
        it "should create #{type} from row" do
          query("SELECT row_to_#{type}((array[1,2], array[11, 22]))").should match \
          '"1"=>"11", "2"=>"22"'
        end
        it "should create #{type} from row with int8 keys" do
          query("SELECT row_to_#{type}((array[1::int8,2::int8], array[11, 22]))").should match \
          '"1"=>"11", "2"=>"22"'
        end
        it "should fail on other kind of rows (case 1)" do
          expect{query("SELECT row_to_#{type}((array[1,2], array[11, 22], array[1,2]))")}.to throw_error "expected two arrays in wholerow"
        end
        it "should fail on other kind of rows (case 2)" do
          expect{query("SELECT row_to_#{type}((array[1,2], 'qwerty'))")}.to throw_error "expected only arrays in wholerow"
        end
        it "should fail on other kind of rows (case 3)" do
          expect{query("SELECT row_to_#{type}((array[1,2], array['1', '2']))")}.to throw_error "unsupported array type"
        end
        it "should fail on integer overflow (INT_MAX)" do
          expect{query("SELECT row_to_#{type}((array[4147483647,2], array[11, 22]))")}.to throw_error "integer out of range"
        end
        it "should fail on integer overflow (INT_MIN)" do
          expect{query("SELECT row_to_#{type}((array[-4147483648,2], array[11, 22]))")}.to throw_error "integer out of range"
        end
      end
    end
  end
end
