require "simplecov"

if ENV["CI"]
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start do
  add_filter "/spec/"
end
