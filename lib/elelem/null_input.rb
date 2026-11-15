# frozen_string_literal: true

module Elelem
  class NullInput < Input
    def initialize(**)
      super(stream: File.open(File::NULL))
    end
  end
end
