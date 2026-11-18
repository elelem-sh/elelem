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

      def path_bash
        bash = find("bash.exe", dirs.reject { |dir| system?(dir) })
        bash && launcher(bash)
      end

      def launcher(bash)
        above = File.expand_path("../../bin/bash.exe", File.dirname(bash))
        normalize(File.dirname(bash)).end_with?("/usr/bin") && File.file?(above) ? above : bash
      end

      def git_bash
        dirs.filter_map { |dir| git_dir(dir) }
            .map { |dir| File.expand_path("../bin/bash.exe", dir) }
            .find { |bash| File.file?(bash) }
      end

      def find(name, dirs) = dirs.map { |dir| File.join(dir, name) }.find { |path| File.file?(path) }

      def git_dir(dir)
        return unless File.file?(File.join(dir, "git.exe"))

        shim = File.join(dir, "git.shim")
        File.file?(shim) ? shim_dir(shim) : dir
      end

      def shim_dir(shim)
        target = File.read(shim).scrub[/^\W*path\s*=\s*"?([^"\r\n]+)/, 1]
        target && File.dirname(target.strip.tr("\\", "/"))
      end

      def dirs = @env.fetch("PATH", "").split(File::PATH_SEPARATOR).map { |dir| dir.delete('"') }.reject(&:empty?)

      def system?(dir)
        path = normalize(dir)
        windows_apps?(path) || under_system_root?(path)
      end

      def windows_apps?(path) = path.split("/").include?("windowsapps")

      def under_system_root?(path)
        "#{path}/".start_with?("#{system_root}/")
      end

      def system_root
        normalize(@env.values_at("SystemRoot", "windir").compact.reject(&:empty?).first || "C:\\Windows")
      end

      def normalize(path) = path.to_s.tr("\\", "/").downcase.chomp("/")
    end
  end
end
