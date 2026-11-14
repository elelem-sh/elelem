# frozen_string_literal: true

module Elelem
  class Plugins
    LOAD_PATHS = [
      File.expand_path("plugins", __dir__),
      "~/.agents/plugins",
      ".agents/plugins"
    ].freeze

    def initialize(load_paths: LOAD_PATHS)
      @loaded = false
      @load_paths = load_paths
    end

    def load!(force: false)
      return if @loaded && !force

      @load_paths.each { |path| load_dir(File.expand_path(path)) }
      @loaded = true
    end

    private

    def load_dir(dir)
      return unless File.directory?(dir)

      Dir["#{dir}/*.rb"].each { |file| load_plugin(file) }
    end

    def load_plugin(file)
      load(file)
    rescue StandardError, ScriptError => e
      warn "elelem: failed to load plugin #{file}: #{e.message}"
    end
  end
end
