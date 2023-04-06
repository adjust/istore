-- istore test cases
SELECT max_value(''::istore);
SELECT max_value('1=>1'::istore);
SELECT max_value('1=>1, 2=>1'::istore);
SELECT max_value('0=>2, 1=>4, 3=>0 ,2=>2'::istore);
SELECT max_value('10=>21, 11=>500, 13=>800 ,12=>4200'::istore);

-- bigistore test cases
SELECT max_value(''::bigistore);
SELECT max_value('1=>1'::bigistore);
SELECT max_value('1=>1, 2=>1'::bigistore);
SELECT max_value('0=>2, 1=>4, 3=>0 ,2=>2'::bigistore);
SELECT max_value('10=>21, 11=>500, 13=>800 ,12=>4200'::bigistore);
SELECT max_value('10=>21, 11=>500, 13=>800 ,12=>3147483647'::bigistore);
