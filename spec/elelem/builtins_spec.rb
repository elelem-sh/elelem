# frozen_string_literal: true

RSpec.describe Elelem::Builtins do
  def run(script, timeout, &)
    cmd, *args = described_class.shell_command(script)
    described_class.sh(cmd, args: args, timeout: timeout, &)
  end

  def sleeper(timeout, &) = run("echo hi; sleep 10", timeout, &)

  it "stops a command at once on Ctrl-C, though it runs in its own process group" do
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    expect do
      sleeper(300) { raise Interrupt }
    end.to raise_error(Interrupt)
    expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).to be < 5
  end

  it "stops a command at once when the CLI's INT trap exits" do
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    expect do
      sleeper(300) { exit 1 }
    end.to raise_error(SystemExit)
    expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).to be < 5
  end

  it "stops a command that runs past its timeout and says so" do
    result = sleeper(1)

    expect(result[:exit_status]).to eq(124)
    expect(result[:content]).to eq("hi\n\n[command timed out after 1s]")
  end

  it "says a command timed out even when it exits 0 on being stopped", if: !Gem.win_platform? do
    result = run("trap 'exit 0' TERM; echo hi; sleep 10 & wait", 1)

    expect(result).to eq({ exit_status: 124, content: "hi\n\n[command timed out after 1s]" })
  end

  it "keeps the exit status of a command that ended before its timeout" do
    expect(run("echo hi; exit 3", 300)).to include(exit_status: 3)
  end

  it "counts the characters it elides" do
    expect(described_class.truncate("abcdefg", limit: 5)).to eq("ab\n[3 characters elided]\nfg")
  end

  context "when the shell is cmd", if: Gem.win_platform? do
    around do |example|
      described_class.finder = Elelem::Builtins::Shell.new(env: { "PATH" => "" }, windows: true)
      example.run
    ensure
      described_class.finder = nil
    end

    def sleeper(timeout, &) = run("echo hi& ping -n 11 127.0.0.1 >nul", timeout, &)

    it "stops a command at once on Ctrl-C" do
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      expect do
        sleeper(300) { raise Interrupt }
      end.to raise_error(Interrupt)
      expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).to be < 5
    end

    it "stops a command at once when the CLI's INT trap exits" do
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      expect do
        sleeper(300) { exit 1 }
      end.to raise_error(SystemExit)
      expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).to be < 5
    end

    it "stops a command that runs past its timeout and says so" do
      result = sleeper(1)

      expect(result).to eq({ exit_status: 124, content: "hi\n\n[command timed out after 1s]" })
    end
  end
end
