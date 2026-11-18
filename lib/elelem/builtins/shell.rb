# frozen_string_literal: true

module Elelem
  module Builtins
    class Shell
      def initialize(env: ENV, windows: Gem.win_platform?)
        @env = env
        @windows = windows
      end

      def name
        return :bash if bash

        @windows ? :cmd : :sh
      end

      def argv(command)
        case name
        when :bash then [bash, "-c", command]
        when :sh then ["sh", "-c", command]
        else [command]
        end
      end

      def bash
        return @bash if defined?(@bash)

        @bash = @windows ? bash_on_path || bash_beside_git : posix_bash
      end

      private

      def posix_bash
        "bash" if path_dirs.any? { |dir| File.file?(File.join(dir, "bash")) }
      end

      def bash_on_path
        bash = first_file(searchable_dirs.map { |dir| File.join(dir, "bash.exe") })
        bash && (launcher_above(bash) || bash)
      end

      def launcher_above(bash)
        usr_bin = File.dirname(bash)
        first_file([File.expand_path("../../bin/bash.exe", usr_bin)]) if normalize(usr_bin).end_with?("/usr/bin")
      end

      def bash_beside_git = first_file(git_homes.map { |home| File.join(home, "bin", "bash.exe") })

      def git_homes = path_dirs.filter_map { |dir| git_home(dir) }

      def git_home(dir)
        git = File.join(dir, "git.exe")
        return unless File.file?(git)

        shim = File.join(dir, "git.shim")
        git = scoop_target(shim) if File.file?(shim)
        git && File.expand_path("../..", git)
      end

      def scoop_target(shim) = File.read(shim).scrub[/^\W*path\s*=\s*"?([^"\r\n]+)/, 1]&.strip&.tr("\\", "/")

      def first_file(paths) = paths.find { |path| File.file?(path) }

      def searchable_dirs = path_dirs.reject { |dir| system_dir?(dir) }

      def path_dirs = @env.fetch("PATH", "").split(File::PATH_SEPARATOR).map { |dir| dir.delete('"') }.reject(&:empty?)

      def system_dir?(dir)
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
