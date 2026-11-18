# frozen_string_literal: true

RSpec.describe Elelem::Builtins do
  def sleeper(timeout, &)
    cmd, *args = described_class.shell_command("echo hi; sleep 10")
    described_class.sh(cmd, args: args, timeout: timeout, &)
  end

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
end
