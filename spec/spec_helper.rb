# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  command_name "RSpec"
  at_exit do
    result = SimpleCov.result
    result.files.sort_by(&:covered_percent).each do |file|
      puts "#{file.covered_percent.round(1).to_s.rjust(5)}%  #{file.filename.delete_prefix("#{SimpleCov.root}/")}"
    end
    total = result.covered_lines + result.missed_lines
    puts "Total: #{result.covered_percent.round(2)}% (#{result.covered_lines}/#{total} lines)"
  end
end

require_relative "../lib/elelem"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
