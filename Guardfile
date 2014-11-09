# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', cmd: "rspec -fp" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/(.*)/.+_spec\.rb$})

  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }

  watch(%r{^lib/app.rb$})                             { "spec" }
  watch(%r{^lib/app/routes/put.rb$})                  { |m| "spec/put" }
  watch(%r{^lib/app/routes/(.+)/(.+)\.rb$})           { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }
  #
  # Endpoints
  # --------------------------------------------
  watch(%r{^lib/app/routes/(.+)/(.+)\.rb$})           { |m| "spec/#{m[1]}/endpoints_spec.rb" }
  watch(%r{^lib/app/routes/(.+)\.rb$})                { |m| "spec/#{m[1]}/endpoints_spec.rb" }

  watch(%r{^spec/(.+)/support\.rb$})                  { |m| "spec/#{m[1]}" }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  #
  # GET's
  # --------------------------------------------
  watch(%r{^lib/app/routes/(.+)/status\.rb$})           { |m| "spec/#{m[1]}/comments_spec.rb" }
  watch(%r{^lib/app/routes/(.+)/status\.rb$})           { |m| "spec/#{m[1]}/comments_spec.rb" }

end
