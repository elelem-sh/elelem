# frozen_string_literal: true

module Elelem
  class PrivateFile
    attr_reader :path

    def initialize(path, own_dir: false)
      @path = path
      @own_dir = own_dir
    end

    def <<(text)
      @dir ||= make_dir
      File.write(path, text, mode: "a", perm: 0o600)
      self
    end

    def touch = self << ""

    private

    def make_dir
      File.dirname(path).tap do |dir|
        FileUtils.mkdir_p(dir, mode: 0o700)
        File.chmod(0o700, dir) if @own_dir
      end
    end
  end
  private_constant :PrivateFile
end
