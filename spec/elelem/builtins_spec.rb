# frozen_string_literal: true

RSpec.describe Elelem::Builtins do
  it "stops a command at once on Ctrl-C, though it runs in its own process group" do
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    expect do
      described_class.sh("bash", args: ["-c", "echo hi; sleep 10"], timeout: 300) { raise Interrupt }
    end.to raise_error(Interrupt)
    expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).to be < 5
  end

  it "stops a command at once when the CLI's INT trap exits" do
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    expect do
      described_class.sh("bash", args: ["-c", "echo hi; sleep 10"], timeout: 300) { exit 1 }
    end.to raise_error(SystemExit)
    expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).to be < 5
  end
end
