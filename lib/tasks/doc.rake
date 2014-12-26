namespace :doc do

  desc 'Generate YARD documentation'
  task :yard do
    sh 'yardoc'
  end

end
