# frozen_string_literal: true

# The default output. A gem that registers its own output first keeps it.
Elelem.configure do |config|
  config.output { Elelem::Builtins::Terminal.new } unless config.factories.key?(:output)
end
