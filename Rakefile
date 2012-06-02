
desc 'Generate YARD documentation'
task :yard do
  sh 'yardoc'
end

namespace :yard do
  desc 'Generate YARD documentation for github web page'
  task :github do
    sh 'yardoc --output-dir ../dmytro.github.com/nagira/doc'
  end
end
