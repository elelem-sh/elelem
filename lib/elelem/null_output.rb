# frozen_string_literal: true

module Elelem
  class NullOutput < Output
    private

    def write(_text) = nil
  end
end
