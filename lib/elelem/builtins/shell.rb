# frozen_string_literal: true

module Elelem
  module Builtins
    class Shell
      def initialize(env: ENV, windows: Gem.win_platform?)
        @env = env
        @windows = windows
      end

      def name = bash ? :bash : :cmd

      def argv(command)
        bash = self.bash
        bash ? [bash, "-c", command] : [command]
      end

      def bash
        return "bash" unless @windows
        return @bash if defined?(@bash)

        @bash = path_bash || git_bash
      end

      private

      def path_bash = find("bash.exe", dirs.reject { |dir| system?(dir) })

      def git_bash
        git = find("git.exe", dirs)
        bash = git && File.expand_path("../bin/bash.exe", File.dirname(git))
        bash if bash && File.file?(bash)
      end

      def find(name, dirs) = dirs.map { |dir| File.join(dir, name) }.find { |path| File.file?(path) }

      def dirs = @env.fetch("PATH", "").split(File::PATH_SEPARATOR).map { |dir| dir.delete('"') }.reject(&:empty?)

      def system?(dir)
        path = normalize(dir)
        windows_apps?(path) || under_system_root?(path)
      end

      def windows_apps?(path) = path.split("/").include?("windowsapps")

      def under_system_root?(path)
        root = normalize(@env["SystemRoot"])
        !root.empty? && "#{path}/".start_with?("#{root}/")
      end

      def normalize(path) = path.to_s.tr("\\", "/").downcase.chomp("/")
    end
  end
end
