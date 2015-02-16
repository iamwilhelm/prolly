
def run(cmd)
  IO.popen(cmd) { |f| f.each_line { |l| puts l } }
end

desc "run tests"
task :test do
  run "rspec ./specs"
end

task :default => :test

namespace :example do

  desc "decision tree"
  task :decision_tree do
    run "ruby -Ilib examples/decision_tree/main.rb"
  end

end
