# frozen_string_literal: true

RSpec.describe Elelem::Builtins::Shell do
  around { |example| Dir.mktmpdir { |dir| @root = dir and example.run } }

  def dir(*parts) = File.join(@root, *parts).tap { |path| FileUtils.mkdir_p(path) }

  def exe(*parts, name) = File.join(dir(*parts), name).tap { |path| FileUtils.touch(path) }

  def windows(*path, **env)
    described_class.new(env: { "PATH" => path.join(File::PATH_SEPARATOR), **env.transform_keys(&:to_s) }, windows: true)
  end

  def posix(*path) = described_class.new(env: { "PATH" => path.join(File::PATH_SEPARATOR) }, windows: false)

  it "is bash when not on Windows and bash is on PATH" do
    File.chmod(0o755, exe("usr", "bin", "bash"))
    shell = posix(dir("usr", "bin"))

    expect([shell.name, shell.argv("ls | wc")]).to eq([:bash, ["bash", "-c", "ls | wc"]])
  end

  it "is sh when not on Windows and bash is not on PATH" do
    exe("usr", "bin", "bash")
    shell = posix(dir("usr", "bin"))

    expect([shell.name, shell.argv("ls | wc")]).to eq([:sh, ["sh", "-c", "ls | wc"]])
  end

  it "is cmd on Windows when the only bash is the WSL launcher in SystemRoot" do
    exe("Windows", "System32", "bash.exe")
    shell = windows(dir("Windows", "System32"), SystemRoot: dir("Windows").upcase)

    expect([shell.name, shell.argv("dir | more")]).to eq([:cmd, ["dir | more"]])
  end

  it "is the Git bash on PATH on Windows, not the WSL launcher before it" do
    exe("Windows", "System32", "bash.exe")
    bash = exe("Git", "bin", "bash.exe")
    shell = windows(dir("Windows", "System32"), dir("Git", "bin"), SystemRoot: dir("Windows"))

    expect([shell.name, shell.argv("ls")]).to eq([:bash, [bash, "-c", "ls"]])
  end

  it "is the bash beside Git on Windows when only Git's cmd directory is on PATH" do
    exe("Git", "cmd", "git.exe")
    bash = exe("Git", "bin", "bash.exe")
    shell = windows(dir("Git", "cmd"), SystemRoot: dir("Windows"))

    expect([shell.name, shell.argv("ls")]).to eq([:bash, [bash, "-c", "ls"]])
  end

  it "is cmd on Windows when Git has no bash beside it" do
    exe("Git", "cmd", "git.exe")

    expect(windows(dir("Git", "cmd"), SystemRoot: dir("Windows")).name).to eq(:cmd)
  end

  it "is the bash beside Git on Windows when a git.exe without bash comes before Git's cmd directory on PATH" do
    exe("shims", "git.exe")
    exe("Git", "cmd", "git.exe")
    bash = exe("Git", "bin", "bash.exe")
    shell = windows(dir("shims"), dir("Git", "cmd"), SystemRoot: dir("Windows"))

    expect([shell.name, shell.argv("ls")]).to eq([:bash, [bash, "-c", "ls"]])
  end

  it "is the bash beside the Git that a Scoop shim points to" do
    git = exe("scoop", "apps", "git", "current", "cmd", "git.exe")
    bash = exe("scoop", "apps", "git", "current", "bin", "bash.exe")
    exe("scoop", "shims", "git.exe")
    File.write(File.join(dir("scoop", "shims"), "git.shim"), "path = \"#{git.tr("/", "\\")}\"\r\nargs = -c x=y\r\n")
    shell = windows(dir("scoop", "shims"), SystemRoot: dir("Windows"))

    expect([shell.name, shell.argv("ls")]).to eq([:bash, [bash, "-c", "ls"]])
  end

  it "is the bash beside the Git that a Scoop shim points to without quotes" do
    git = exe("scoop", "apps", "git", "current", "cmd", "git.exe")
    bash = exe("scoop", "apps", "git", "current", "bin", "bash.exe")
    exe("scoop", "shims", "git.exe")
    File.write(File.join(dir("scoop", "shims"), "git.shim"), "path = #{git}\n")
    shell = windows(dir("scoop", "shims"), SystemRoot: dir("Windows"))

    expect([shell.name, shell.argv("ls")]).to eq([:bash, [bash, "-c", "ls"]])
  end

  it "is cmd on Windows when a Scoop shim points to a Git without bash" do
    git = exe("scoop", "apps", "git", "current", "cmd", "git.exe")
    exe("scoop", "shims", "git.exe")
    exe("scoop", "bin", "bash.exe")
    File.write(File.join(dir("scoop", "shims"), "git.shim"), "path = \"#{git}\"\n")

    expect(windows(dir("scoop", "shims"), SystemRoot: dir("Windows")).name).to eq(:cmd)
  end

  it "is Git's bash launcher on Windows when Git's usr\\bin directory is on PATH" do
    exe("Git", "usr", "bin", "bash.exe")
    bash = exe("Git", "bin", "bash.exe")
    shell = windows(dir("Git", "usr", "bin"), SystemRoot: dir("Windows"))

    expect([shell.name, shell.argv("ls")]).to eq([:bash, [bash, "-c", "ls"]])
  end

  it "is the bash in usr\\bin on Windows when there is no launcher above it" do
    bash = exe("msys64", "usr", "bin", "bash.exe")
    shell = windows(dir("msys64", "usr", "bin"), SystemRoot: dir("Windows"))

    expect([shell.name, shell.argv("ls")]).to eq([:bash, [bash, "-c", "ls"]])
  end

  it "is cmd on Windows when usr\\bin on PATH has no bash, though a launcher sits above it" do
    exe("Git", "bin", "bash.exe")

    expect(windows(dir("Git", "usr", "bin"), SystemRoot: dir("Windows")).name).to eq(:cmd)
  end

  it "is the bash beside a Git found in a system directory" do
    exe("Windows", "Git", "cmd", "git.exe")
    bash = exe("Windows", "Git", "bin", "bash.exe")
    shell = windows(dir("Windows", "Git", "cmd"), SystemRoot: dir("Windows"))

    expect([shell.name, shell.argv("ls")]).to eq([:bash, [bash, "-c", "ls"]])
  end

  it "ignores the WSL launcher under windir when SystemRoot is unset" do
    exe("Windows", "System32", "bash.exe")

    expect(windows(dir("Windows", "System32"), windir: dir("Windows")).name).to eq(:cmd)
  end

  it "ignores the WSL launcher under windir when SystemRoot is empty" do
    exe("Windows", "System32", "bash.exe")

    expect(windows(dir("Windows", "System32"), SystemRoot: "", windir: dir("Windows")).name).to eq(:cmd)
  end

  it "ignores the WSL launcher in C:\\Windows when SystemRoot and windir are unset",
     if: File.file?("C:/Windows/System32/bash.exe") do
    expect(windows("C:\\Windows\\System32").name).to eq(:cmd)
  end

  it "ignores a bash under WindowsApps" do
    exe("Users", "me", "AppData", "Local", "Microsoft", "WindowsApps", "bash.exe")
    shell = windows(dir("Users", "me", "AppData", "Local", "Microsoft", "WindowsApps"), SystemRoot: dir("Windows"))

    expect(shell.name).to eq(:cmd)
  end
end
