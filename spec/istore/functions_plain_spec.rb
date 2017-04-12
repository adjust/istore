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
        if type == :bigistore
          query("SELECT bigistore(Array[5,3,4]::int[], Array[5000000000,4000000000,5]::bigint[])").should match \
          '"3"=>"4000000000", "4"=>"5", "5"=>"5000000000"'
        end
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

      it 'should return length of empty istores' do
        query("SELECT istore_length(#{type}(ARRAY[]::integer[],ARRAY[]::integer[]))").should match 0
      end

      it 'should return length of non-empty istores' do
        query("SELECT istore_length(#{type}(ARRAY[1],ARRAY[1]))").should match 1
        query("SELECT istore_length(#{type}(ARRAY[1,2,3],ARRAY[1,2,3]))").should match 3
        query("SELECT istore_length(#{sample[type]}::#{type})").should match sample_hash[type].size
      end

      it 'should convert istore to json' do
        query("SELECT istore_to_json('5=>50, 7=>70, 9=>90'::#{type})").should match \
        '{"5": 50, "7": 70, "9": 90}'
        query("SELECT istore_to_json(#{sample[type]}::#{type})").should match \
          sample_hash[type].to_json.gsub(/[\,\:]/,{','=>', ',':'=>': '})
      end

      it 'should convert istore to array' do
        query("SELECT istore_to_array('5=>50, 7=>70, 9=>90'::#{type})").should match \
        '{5,50,7,70,9,90}'
        query("SELECT istore_to_array(#{sample[type]}::#{type})").should match \
          arr_to_sql_arr sample_hash[type].to_a.flatten
        query("SELECT istore_to_array(''::#{type})").should match \
          '{}'
      end

      it 'should convert istore to matrix' do
        query("SELECT istore_to_matrix('5=>50, 7=>70, 9=>90'::#{type})").should match \
        '{{5,50},{7,70},{9,90}}'
        query("SELECT istore_to_matrix(#{sample[type]}::#{type})").should match \
          arr_to_sql_arr sample_hash[type].to_a
      end

      describe 'slice' do
        it 'should return a partial istore' do
          query("SELECT slice('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::#{type}, ARRAY[3,5,1,9,11])").should match \
          '"1"=>"10", "3"=>"30", "5"=>"50", "9"=>"90"'
          query("SELECT slice(#{sample[type]}::#{type}, ARRAY[10,0])").should match \
          hash_to_istore [0,10].map{|k| [k,sample_hash[type][k]]}.to_h
        end

        it 'should return null if no key match' do
          query("SELECT slice('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::#{type}, ARRAY[30,50,10,90])").should match nil
        end
      end

      describe 'slice_array' do
        it 'should return a values from istore' do
          query("SELECT slice_array('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::#{type}, ARRAY[3,5,1,9,11])").should match \
          '{30,50,10,90,NULL}'
          query("SELECT slice_array(#{sample[type]}::#{type}, ARRAY[10,0])").should match \
          arr_to_sql_arr [10,0].map{|k| sample_hash[type][k]}.to_s
        end

        it 'should return null array if no key match' do
          query("SELECT slice_array('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::#{type}, ARRAY[30,50,10,90])").should match \
          '{NULL,NULL,NULL,NULL}'
        end
      end

      describe 'delete' do
        it 'should delete a key from istore' do
          query("SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::#{type},3)").should match \
          '"1"=>"10", "2"=>"20", "4"=>"40", "5"=>"50", "7"=>"70", "9"=>"90"'
          query("SELECT delete(#{sample[type]}::#{type}, 10)").should match \
            hash_to_istore sample_hash[type].reject{|k,_| k==10}
        end

        it 'should return istore if key unmatched' do
          query("SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::#{type},6)").should match \
          '"1"=>"10", "2"=>"20", "3"=>"30", "4"=>"40", "5"=>"50", "7"=>"70", "9"=>"90"'
        end

        it 'should delete multiple keys from istore' do
          query("SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::#{type},ARRAY[7,8,2,5,4])").should match \
          '"1"=>"10", "3"=>"30", "9"=>"90"'
          query("SELECT delete(#{sample[type]}::#{type}, ARRAY[0,10,-10])").should match \
            hash_to_istore sample_hash[type].reject{|k,_| [0,10,-10].any?{|m| m==k} }
        end

        it 'should return istore if keys are unmatched' do
          query("SELECT delete('1=>10, 2=>20, 3=>30, 4=>40, 5=>50, 7=>70, 9=>90'::#{type},ARRAY[8,6])").should match \
          '"1"=>"10", "2"=>"20", "3"=>"30", "4"=>"40", "5"=>"50", "7"=>"70", "9"=>"90"'
        end

        it 'should delete istore from istore' do
          query("SELECT delete(#{sample[type]}::#{type}, '0=>5, 10=>100')").should match \
            hash_to_istore sample_hash[type].reject{|k,_| [0].any?{|m| m==k} }
        end
      end

      describe 'existence' do
        it 'should check presence of a key' do
          query("SELECT exist(#{sample[type]}::#{type}, 10)").should match 't'
          query("SELECT exist(#{sample[type]}::#{type}, 25)").should match 'f'
        end
        it 'should check presence of any key' do
          query("SELECT exists_any(#{sample[type]}::#{type}, Array[10,0])").should match 't'
          query("SELECT exists_any(#{sample[type]}::#{type}, Array[27,25])").should match 'f'
          query("SELECT exists_any('1=>4,2=>5'::#{type}, ARRAY[]::int[]);").should match 'f'
        end
        it 'should check presence of all key' do
          query("SELECT exists_all(#{sample[type]}::#{type}, Array[10,0])").should match 't'
          query("SELECT exists_all(#{sample[type]}::#{type}, Array[10,25])").should match 'f'
          query("SELECT exists_all('1=>4,2=>5'::#{type}, ARRAY[1,3]);").should match 'f'
          query("SELECT exists_all('1=>4,2=>5'::#{type}, ARRAY[]::int[]);").should match 't'
        end
      end

      it 'should be able to find the smallest key' do
        query("SELECT min_key(''::#{type})").should match nil
        query("SELECT min_key('1=>1'::#{type})").should match '1'
        query("SELECT min_key('1=>1, 2=>1'::#{type})").should match '1'
        query("SELECT min_key('0=>2, 1=>2, 3=>0 ,2=>2'::#{type})").should match '0'
      end

      it 'should be able to find the biggest key' do
        query("SELECT max_key(''::#{type})").should match nil
        query("SELECT max_key('1=>1'::#{type})").should match '1'
        query("SELECT max_key('1=>1, 2=>1'::#{type})").should match '2'
        query("SELECT max_key('0=>2, 1=>2, 3=>0 ,2=>2'::#{type})").should match '3'
      end

      describe 'concat' do
        it 'should concat two istores' do
          query("SELECT concat('1=>4, 2=>5'::#{type}, '3=>4, 2=>7'::#{type})").should match \
          '"1"=>"4", "2"=>"7", "3"=>"4"'
          query("SELECT concat(#{sample[type]}::#{type}, #{sample[type]}::#{type})").should match \
          sample_out[type]
        end

        it 'should concat empty istores' do
          query("SELECT concat(#{sample[type]}::#{type}, ''::#{type})").should match \
            sample_out[type]
          query("SELECT concat(''::#{type}, #{sample[type]}::#{type})").should match \
            sample_out[type]
          query("SELECT concat(''::#{type}, ''::#{type})").should match \
            ''
        end
      end
    end
  end
end
