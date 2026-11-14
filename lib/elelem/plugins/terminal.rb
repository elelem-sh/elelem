# frozen_string_literal: true

Elelem.configure { |config| config.output { Elelem::Builtins::Terminal.new } }
