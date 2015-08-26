require 'rake'
require 'rspec/core/rake_task'
require 'dumbo/rake_task'
require 'dumbo/db_task'
require 'dumbo'
require 'csv'

load File.expand_path('../config/boot.rb', __FILE__)

Dumbo::RakeTask.new(:dumbo)
Dumbo::DbTask.new(:db)
RSpec::Core::RakeTask.new(:spec)

Dir.glob('lib/tasks/**/*.rake').each { |taskfile| load taskfile }

task default: ['dumbo:all', 'db:test:prepare', :spec]

task :bench do
  transactions = ENV['transactions'] || 30
  bench_dir = File.expand_path('../bench', __FILE__)
  files = Dir.glob(File.join(bench_dir, "*.sql")).reject{|f| f.include?"init.sql"}
  data = files.inject({}) do |m,f|
    key = File.basename(f,".sql")
    r = %x(pgbench -f #{f} -t #{transactions} -n is_bench).split("\n").reduce do |m,o|
      m = o[/tps = (\d+(\.\d+)?) \(excluding connections establishing\)/,1] || m
    end
    m[key] = r
    m
  end

  write_result(bench_dir, data)
end

task :bench_init do
  bench_dir = File.expand_path('../bench', __FILE__)
  scale = ENV['scale'] || 1
  size  = ENV['size']  || 30
  keys  = ENV['keys']  || 30
  init_bench(bench_dir, scale, size, keys)
end

def init_bench(bench_dir, scale, size, keys)
  %x(psql -c "DROP DATABASE IF EXISTS is_bench" postgres)
  %x(psql -c "CREATE DATABASE is_bench;" postgres)
  init_file = File.join(bench_dir, "init.sql")
  %x(psql -f #{init_file} --set=scale=#{scale} --set=size=#{size} --set=keys=#{keys} is_bench)

  $?.success?
end

def write_result(bench_dir, data)
  csv = [[]]
  bench_file = File.join(bench_dir, "benchmarks.csv")
  current_branch = `git rev-parse --abbrev-ref HEAD`.chomp

  if File.exists?(bench_file)
    csv = CSV.read(bench_file)
  end

  csv_keys = csv.map{|r| r[0].to_s}
  branches = csv[0][1..-1] || []
  n = 1
  while branches.include?(current_branch) do
    curnum = current_branch[/ #(\d+)$/,1]
    if curnum
      n = curnum.to_i + 1
      current_branch = current_branch.gsub(Regexp.new("#{curnum}$"), n.to_s)
    else
      current_branch << " ##{n}"
    end
    n+=1
  end

  data.each do |k,v|
    data[k] = {current_branch => v}
  end

  keys = data.keys | csv_keys.reject(&:empty?)
  csv_data = csv[1..-1].inject(data) do |m,row|
    k = row[0]
    m[k] ||={}
    m[k] = m[k].merge(Hash[branches.zip(row[1..-1])])

    m
  end
  branches << current_branch
  CSV.open(bench_file, "w") do |f|
    f << [nil] + branches
    keys.sort.each do |k|
      f << [k] + branches.map{|b| csv_data[k][b]}
    end
  end
end