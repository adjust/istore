require 'spec_helper'

types.each do |type|
  describe "#{type}" do
    describe 'functions' do
      before do
        install_extension
      end

      it 'should find keys with exists' do
        query("SELECT exist('1=>1'::#{type}, 1)").should match 't'
        query("SELECT exist('1=>1'::#{type}, 2)").should match 'f'
        query("SELECT exist('1=>1, -1=>0'::#{type}, 2)").should match 'f'
        query("SELECT exist('1=>1, -1=>0'::#{type}, -1)").should match 't'
      end

      it 'should fetchvals' do
        query("SELECT fetchval('1=>1'::#{type}, 1)").should match '1'
        query("SELECT fetchval('2=>1'::#{type}, 1)").should match nil
        query("SELECT fetchval('1=>1, 1=>1'::#{type}, 1)").should match '2'
        query("SELECT fetchval('1=>1, 1=>1'::#{type}, 2)").should match nil
      end

      it 'should return set of ints' do
        query("SELECT * FROM each('1=>1'::#{type})").should match ['1','1']

        query("SELECT * FROM each('5=>11, 4=>8'::#{type})").should match \
          ['5','11'],
          ['4','8']

        query("SELECT * FROM each('5=>-411, 4=>8'::#{type})").should match \
          ['5','-411'],
          ['4','8']

        query("SELECT value + 100 FROM each('5=>-411, 4=>8'::#{type})").should match \
          ['-311'],
          ['108']

        query("SELECT * FROM each(#{sample[type]}::#{type})").should match \
          ["-10",         "#{values[type][:low]}"],
          ["-2147483647", "10"],
          ["0",           "5"],
          ["10",          "#{values[type][:high]}"],
          ["2147483647",  "10"]

        query("SELECT * FROM each(NULL::#{type})").should match []
      end

      it 'should compact istores' do
        query("SELECT compact('0=>2, 1=>2, 3=>0 ,2=>2'::#{type})").should match \
        '"0"=>"2", "1"=>"2", "2"=>"2"'
      end

      it 'should add istores' do
        query("SELECT add('1=>1, 2=>1'::#{type}, '1=>1, 2=>1'::#{type})").should match \
        '"1"=>"2", "2"=>"2"'
        query("SELECT add('1=>1, 2=>1'::#{type}, '-1=>1, 2=>1'::#{type})").should match \
        '"-1"=>"1", "1"=>"1", "2"=>"2"'
        query("SELECT add('1=>1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
        '"-1"=>"-1", "1"=>"1", "2"=>"2"'
        query("SELECT add('-1=>1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
        '"-1"=>"0", "2"=>"2"'
        query("SELECT add('-1=>-1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
        '"-1"=>"-2", "2"=>"2"'
        query("SELECT add('-1=>-1, 2=>1'::#{type}, 1)").should match \
        '"-1"=>"0", "2"=>"2"'
        query("SELECT add('-1=>-1, 2=>1'::#{type}, -1)").should match \
        '"-1"=>"-2", "2"=>"0"'
        query("SELECT add('-1=>-1, 2=>1'::#{type}, 0)").should match \
        '"-1"=>"-1", "2"=>"1"'
        query("SELECT add(#{type}(Array[]::integer[], Array[]::integer[]), '1=>0'::#{type});").should match \
        '"1"=>"0"'
      end

      it 'should substract istores' do
        query("SELECT subtract('1=>1, 2=>1'::#{type}, '1=>1, 2=>1'::#{type})").should match \
        '"1"=>"0", "2"=>"0"'
        query("SELECT subtract('1=>1, 2=>1'::#{type}, '-1=>1, 2=>1'::#{type})").should match \
        '"-1"=>"-1", "1"=>"1", "2"=>"0"'
        query("SELECT subtract('1=>1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
        '"-1"=>"1", "1"=>"1", "2"=>"0"'
        query("SELECT subtract('-1=>1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
        '"-1"=>"2", "2"=>"0"'
        query("SELECT subtract('-1=>-1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
        '"-1"=>"0", "2"=>"0"'
        query("SELECT subtract('-1=>-1, 2=>1'::#{type}, 1)").should match \
        '"-1"=>"-2", "2"=>"0"'
        query("SELECT subtract('-1=>-1, 2=>1'::#{type}, -1)").should match \
        '"-1"=>"0", "2"=>"2"'
        query("SELECT subtract('-1=>-1, 2=>1'::#{type}, 0)").should match \
        '"-1"=>"-1", "2"=>"1"'
        query("SELECT subtract(#{type}(Array[]::integer[], Array[]::integer[]), '1=>0'::#{type});").should match \
        '"1"=>"0"'
      end

      it 'should multiply istores' do
        query("SELECT multiply('1=>1, 2=>1'::#{type}, '1=>1, 2=>1'::#{type})").should match \
          '"1"=>"1", "2"=>"1"'
        query("SELECT multiply('1=>1, 2=>1'::#{type}, '-1=>1, 2=>1'::#{type})").should match \
          '"2"=>"1"'
        query("SELECT multiply('1=>1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
          '"2"=>"1"'
        query("SELECT multiply('-1=>1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
          '"-1"=>"-1", "2"=>"1"'
        query("SELECT multiply('-1=>-1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
          '"-1"=>"1", "2"=>"1"'
        query("SELECT multiply('-1=>-1, 2=>1'::#{type}, 1)").should match \
          '"-1"=>"-1", "2"=>"1"'
        query("SELECT multiply('-1=>-1, 2=>1'::#{type}, -1)").should match \
          '"-1"=>"1", "2"=>"-1"'
        query("SELECT multiply('-1=>-1, 2=>1'::#{type}, 0)").should match \
          '"-1"=>"0", "2"=>"0"'
      end

      it 'should divide istores' do
        query("SELECT divide('1=>1, 2=>1'::#{type}, '1=>1, 2=>1'::#{type})").should match \
          '"1"=>"1", "2"=>"1"'
        query("SELECT divide('1=>1, 2=>1'::#{type}, '-1=>1, 2=>1'::#{type})").should match \
          '"2"=>"1"'
        query("SELECT divide('1=>1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
          '"2"=>"1"'
        query("SELECT divide('-1=>1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
          '"-1"=>"-1", "2"=>"1"'
        query("SELECT divide('-1=>-1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
          '"-1"=>"1", "2"=>"1"'
        query("SELECT divide('-1=>-1, 2=>1'::#{type}, '-1=>-1, 2=>1'::#{type})").should match \
          '"-1"=>"1", "2"=>"1"'
        query("SELECT divide('1=>0, 2=>1'::#{type}, '1=>-1, 2=>1'::#{type})").should match \
          '"1"=>"0", "2"=>"1"'
        query("SELECT divide('1=>1, 2=>1'::#{type}, '1=>-1, 2=>1, 3=>0'::#{type})").should match \
          '"1"=>"-1", "2"=>"1"'
        query("SELECT divide('1=>1, 2=>1'::#{type}, '3=>0'::#{type})").should match ''
        query("SELECT divide('-1=>-1, 2=>1'::#{type}, -1)").should match \
          '"-1"=>"1", "2"=>"-1"'
      end

      it 'should raise division by zero error' do
        expect{query("SELECT divide('-1=>-1, 2=>1'::#{type}, 0)")}.to throw_error 'division by zero'
      end

      it 'should raise division by zero error' do
        expect{query("SELECT divide('-1=>-1, 2=>1'::#{type}, '2=>0')")}.to throw_error 'division by zero'
      end

      it 'should generate #{type} from array' do
        query("SELECT #{type}(ARRAY[1])").should match \
        '"1"=>"1"'
        query("SELECT #{type}(ARRAY[1,1,1,1])").should match \
        '"1"=>"4"'
        query("SELECT #{type}(NULL)").should match nil
        query("SELECT #{type}(ARRAY[1,2,3,4])").should match \
        '"1"=>"1", "2"=>"1", "3"=>"1", "4"=>"1"'
        query("SELECT #{type}(ARRAY[1,2,3,4,1,2,3,4])").should match \
        '"1"=>"2", "2"=>"2", "3"=>"2", "4"=>"2"'
        query("SELECT #{type}(ARRAY[1,2,3,4,1,2,3,NULL])").should match \
        '"1"=>"2", "2"=>"2", "3"=>"2", "4"=>"1"'
        query("SELECT #{type}(ARRAY[NULL,2,3,4,1,2,3,4])").should match \
        '"1"=>"1", "2"=>"2", "3"=>"2", "4"=>"2"'
        query("SELECT #{type}(ARRAY[NULL,2,3,4,1,2,3,NULL])").should match \
        '"1"=>"1", "2"=>"2", "3"=>"2", "4"=>"1"'
        query("SELECT #{type}(ARRAY[1,2,3,NULL,1,NULL,3,4,1,2,3])").should match \
        '"1"=>"3", "2"=>"2", "3"=>"3", "4"=>"1"'
        query("SELECT #{type}(ARRAY[NULL,NULL,NULL,NULL]::integer[])").should match ""
        query("SELECT #{type}(ARRAY[]::integer[])").should match ""
      end

      it 'should sum up istores' do
        query("SELECT sum_up('1=>1'::#{type})").should match 1
        query("SELECT sum_up(NULL::#{type})").should match nil
        query("SELECT sum_up('1=>1, 2=>1'::#{type})").should match 2
        query("SELECT sum_up('1=>1, 5=>1, 3=> 4'::#{type}, 3)").should match 5
        query("SELECT sum_up('1=>1 ,2=>-1, 1=>1'::#{type})").should match 1
      end

      it 'should sum istores from table' do
        query("CREATE TABLE test (a #{type})")
        query("INSERT INTO test VALUES('1=>1'),('2=>1'), ('3=>1')")
        query("SELECT SUM(a) FROM test").should match \
        '"1"=>"1", "2"=>"1", "3"=>"1"'
      end

      it 'should sum istores from table' do
        query("CREATE TABLE test (a #{type})")
        query("INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>3')")
        query("SELECT SUM(a) FROM test").should match \
        '"1"=>"1", "2"=>"1", "3"=>"4"'
      end

      it 'should sum istores from table' do
        query("CREATE TABLE test (a #{type})")
        query("INSERT INTO test VALUES('1=>1'),('2=>1'),('3=>1'),(NULL),('3=>0')")
        query("SELECT SUM(a) FROM test").should match \
        '"1"=>"1", "2"=>"1", "3"=>"1"'
      end

      it 'should return istores from arrays' do
        query("SELECT #{type}(Array[5,3,4,5], Array[1,2,3,4])").should match \
          '"3"=>"2", "4"=>"3", "5"=>"5"'

        query("SELECT #{type}(Array[5,3,4,5], Array[1,2,3,4])").should match \
          '"3"=>"2", "4"=>"3", "5"=>"5"'

        query("SELECT #{type}(Array[5,3,4,5], Array[4000,2,4000,4])").should match \
          '"3"=>"2", "4"=>"4000", "5"=>"4004"'
      end

      it 'should fill gaps' do
        query("SELECT fill_gaps('2=>17, 4=>3'::#{type}, 5, 0)").should match \
          '"0"=>"0", "1"=>"0", "2"=>"17", "3"=>"0", "4"=>"3", "5"=>"0"'

        query("SELECT fill_gaps('2=>17, 4=>3'::#{type}, 5)").should match \
          '"0"=>"0", "1"=>"0", "2"=>"17", "3"=>"0", "4"=>"3", "5"=>"0"'

        query("SELECT fill_gaps('2=>17, 4=>3'::#{type}, 3, 11)").should match \
          '"0"=>"11", "1"=>"11", "2"=>"17", "3"=>"11"'

        query("SELECT fill_gaps('2=>17, 4=>3'::#{type}, 0, 0)").should match \
          '"0"=>"0"'

        query("SELECT fill_gaps('2=>17'::#{type}, 3, NULL)").should match nil

        query("SELECT fill_gaps('2=>0, 3=>3'::#{type}, 3, 0)").should match \
          '"0"=>"0", "1"=>"0", "2"=>"0", "3"=>"3"'

        query("SELECT fill_gaps(''::#{type}, 3, 0)").should match \
          '"0"=>"0", "1"=>"0", "2"=>"0", "3"=>"0"'

        query("SELECT fill_gaps(''::#{type}, 3, 400)").should match \
          '"0"=>"400", "1"=>"400", "2"=>"400", "3"=>"400"'

        query("SELECT fill_gaps(NULL::#{type}, 3, 0)").should match nil

        expect{query("SELECT fill_gaps('2=>17, 4=>3'::#{type}, -5, 0)")}.to throw_error 'parameter upto must be >= 0'
      end

      it 'should fill accumulate' do
        query("SELECT accumulate('2=>17, 4=>3'::#{type})").should match \
          '"2"=>"17", "3"=>"17", "4"=>"20"'
        query("SELECT accumulate('2=>0, 4=>3'::#{type})").should match \
          '"2"=>"0", "3"=>"0", "4"=>"3"'
        query("SELECT accumulate('1=>3, 2=>0, 4=>3, 6=>2'::#{type})").should match \
          '"1"=>"3", "2"=>"3", "3"=>"3", "4"=>"6", "5"=>"6", "6"=>"8"'
        query("SELECT accumulate(''::#{type})").should match ''
        query("SELECT accumulate('10=>5'::#{type})").should match '"10"=>"5"'
        query("SELECT accumulate(NULL::#{type})").should match nil
        query("SELECT accumulate('-20=> 5, -10=> 5'::#{type})").should match \
          '"-20"=>"5", "-19"=>"5", "-18"=>"5", "-17"=>"5", "-16"=>"5", "-15"=>"5", "-14"=>"5", "-13"=>"5", "-12"=>"5", "-11"=>"5", "-10"=>"10"'
        query("SELECT accumulate('-5=> 5, 3=> 5'::#{type})").should match \
          '"-5"=>"5", "-4"=>"5", "-3"=>"5", "-2"=>"5", "-1"=>"5", "0"=>"5", "1"=>"5", "2"=>"5", "3"=>"10"'
      end

      it 'should fill accumulate upto' do
        query("SELECT accumulate('2=>17, 4=>3'::#{type}, 8)").should match \
          '"2"=>"17", "3"=>"17", "4"=>"20", "5"=>"20", "6"=>"20", "7"=>"20", "8"=>"20"'
        query("SELECT accumulate('2=>0, 4=>3'::#{type}, 8)").should match \
          '"2"=>"0", "3"=>"0", "4"=>"3", "5"=>"3", "6"=>"3", "7"=>"3", "8"=>"3"'
        query("SELECT accumulate('1=>3, 2=>0, 4=>3, 6=>2'::#{type}, 8)").should match \
          '"1"=>"3", "2"=>"3", "3"=>"3", "4"=>"6", "5"=>"6", "6"=>"8", "7"=>"8", "8"=>"8"'
        query("SELECT accumulate(''::#{type}, 8)").should match ''
        query("SELECT accumulate('10=>5'::#{type}, 8)").should match ''
        query("SELECT accumulate('1=>5'::#{type}, 0)").should match ''
        query("SELECT accumulate(NULL::#{type}, 8)").should match nil
        query("SELECT accumulate('-20=> 5, -10=> 5'::#{type}, -8)").should match \
          '"-20"=>"5", "-19"=>"5", "-18"=>"5", "-17"=>"5", "-16"=>"5", "-15"=>"5", "-14"=>"5", "-13"=>"5", "-12"=>"5", "-11"=>"5", "-10"=>"10", "-9"=>"10", "-8"=>"10"'
        query("SELECT accumulate('-5=> 5, 3=> 5'::#{type}, 2)").should match \
          '"-5"=>"5", "-4"=>"5", "-3"=>"5", "-2"=>"5", "-1"=>"5", "0"=>"5", "1"=>"5", "2"=>"5"'
      end

      it 'should accumulate big numbers' do
        query("SELECT accumulate('0=>20000000000, 1=>10000000000, 3=>10000000000'::bigistore, 4)").should match \
          '"0"=>"20000000000", "1"=>"30000000000", "2"=>"30000000000", "3"=>"40000000000", "4"=>"40000000000"'
      end

      it 'should seed an #{type} from integer' do
        query("SELECT istore_seed(2,5,8::#{val_type[type]})").should match \
          '"2"=>"8", "3"=>"8", "4"=>"8", "5"=>"8"'
        query("SELECT istore_seed(2,5,NULL::#{val_type[type]})").should match nil
        query("SELECT istore_seed(2,5,0::#{val_type[type]})").should match \
          '"2"=>"0", "3"=>"0", "4"=>"0", "5"=>"0"'
        query("SELECT istore_seed(2,2,8::#{val_type[type]})").should match \
          '"2"=>"8"'
        expect{query("SELECT istore_seed(2,0,8::#{val_type[type]})")}.to throw_error 'parameter upto must be >= from'
        end

      it 'should throw an error if negativ seed span' do
        expect{query("SELECT istore_seed(-2,0,8)")}.to throw_error 'parameter from must be >= 0'
      end

      it 'should merge istores by larger keys' do
        query("SELECT istore_val_larger('1=>1,2=>1,3=>3'::#{type}, '1=>2,3=>1,4=>1')").should match \
        '"1"=>"2", "2"=>"1", "3"=>"3", "4"=>"1"'
      end

      it 'should merge istores by smaller keys' do
        query("SELECT istore_val_smaller('1=>1,2=>1,3=>3'::#{type}, '1=>2,3=>1,4=>1')").should match \
        '"1"=>"1", "2"=>"1", "3"=>"1", "4"=>"1"'
      end

      it 'should return #{type} with maxed values' do
        query("SELECT MAX(s) FROM (VALUES('1=>5, 2=>2, 3=>3'::#{type}),('1=>1, 2=>5, 3=>3'),('1=>1, 2=>4, 3=>5'))t(s)").should match \
        '"1"=>"5", "2"=>"5", "3"=>"5"'
      end

      it 'should return #{type} with maxed values' do
        query("SELECT MIN(s) FROM (VALUES('1=>5, 2=>2, 3=>3'::#{type}),('1=>1, 2=>5, 3=>3'),('1=>1, 2=>4, 3=>5'))t(s)").should match \
        '"1"=>"1", "2"=>"2", "3"=>"3"'
      end

      it 'should return keys as array' do
        query("SELECT akeys('-5=>10, 0=>-5, 5=>0'::#{type})").should match '{-5,0,5}'
        query("SELECT akeys(''::#{type})").should match '{}'
      end

      it 'should return values as array' do
        query("SELECT avals('-5=>10, 0=>-5, 5=>0'::#{type})").should match '{10,-5,0}'
        query("SELECT avals(''::#{type})").should match '{}'
      end
      it 'should return keys as set' do
        query("SELECT skeys('-5=>10, 0=>-5, 5=>0'::#{type})").should match \
        [-5],
        [0,],
        [5]
        query("SELECT skeys(''::#{type})").should match []
      end

      it 'should return values set array' do
        query("SELECT svals('-5=>10, 0=>-5, 5=>0'::#{type})").should match \
        [10],
        [-5],
        [0]
        query("SELECT svals(''::#{type})").should match []
      end

      it 'should sum up istores' do
        query("SELECT sum_up('10=>5, 15=>10'::istore)").should match 15
      end
      
      it 'should sum up istores with big numbers' do
        query("SELECT sum_up('10=>2000000000, 15=>1000000000'::istore)").should match 3000000000
      end

      it 'should sum up bigistores' do
        query("SELECT sum_up('10=>5, 15=>10'::bigistore)").should match 15
      end

      it 'should sum up istores with negative values' do
        query("SELECT sum_up('10=>5, 15=>-10'::istore)").should match -5
      end

      it 'should sum up bigistores with negative values' do
        query("SELECT sum_up('10=>5, 15=>-10'::bigistore)").should match -5
      end
    end
  end
end