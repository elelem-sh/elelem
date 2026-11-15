# frozen_string_literal: true

module Elelem
  class NullOutput < Output
    def initialize(**)
      super(stream: File.open(File::NULL, "w"))
    end
  end
end
