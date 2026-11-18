# frozen_string_literal: true

RSpec.describe Elelem::Builtins::Shell do
  around { |example| Dir.mktmpdir { |dir| @root = dir and example.run } }

  def dir(*parts) = File.join(@root, *parts).tap { |path| FileUtils.mkdir_p(path) }

  def exe(*parts, name) = File.join(dir(*parts), name).tap { |path| FileUtils.touch(path) }

  def windows(*path, **env)
    described_class.new(env: { "PATH" => path.join(File::PATH_SEPARATOR), **env.transform_keys(&:to_s) }, windows: true)
  end

  it "is bash when not on Windows" do
    shell = described_class.new(env: { "PATH" => "" }, windows: false)

    expect([shell.name, shell.argv("ls | wc")]).to eq([:bash, ["bash", "-c", "ls | wc"]])
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

  it "ignores a bash under WindowsApps" do
    exe("Users", "me", "AppData", "Local", "Microsoft", "WindowsApps", "bash.exe")
    shell = windows(dir("Users", "me", "AppData", "Local", "Microsoft", "WindowsApps"), SystemRoot: dir("Windows"))

    expect(shell.name).to eq(:cmd)
  end
end
