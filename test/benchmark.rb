#!/usr/bin/env ruby
$: << (File.dirname(__FILE__) + "/../lib")

require 'benchmark'
require "ruby-nagios/nagios/status"
a = Nagios::Status.new "./data/status.dat"

p "Regular parse"

time = Benchmark.measure do
  1000.times { a.parse }
end

p time

require "nagira/status"
b = Nagios::Status.new "./data/status.dat"


p "Timed parse"

time = Benchmark.measure do
  1000.times { b.parse }
end

p time
