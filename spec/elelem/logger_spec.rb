# frozen_string_literal: true

RSpec.describe "Elelem.logger" do
  around do |example|
    saved = ENV.delete("ELELEM_LOG")
    Elelem.instance_variable_set(:@logger, nil)
    example.run
  ensure
    saved ? ENV.store("ELELEM_LOG", saved) : ENV.delete("ELELEM_LOG")
  end

  let(:log_path) { File.join(Elelem.state_dir, "elelem.log") }

  it "writes to a log file only you can read", if: !Gem.win_platform? do
    Elelem.logger.warn("hello")

    expect(File.stat(log_path).mode & 0o777).to eq(0o600)
    expect(File.read(log_path)).to include("WARN", "hello")
  end

  it "writes to stderr when ELELEM_LOG is -" do
    ENV["ELELEM_LOG"] = "-"

    expect { Elelem.logger.warn("hello") }.to output(/hello/).to_stderr
  end

  it "falls back to stderr when the state directory is not writable" do
    File.write(File.join(ENV.fetch("XDG_STATE_HOME"), "elelem"), "")

    expect { Elelem.logger.warn("hello") }.to output(/hello/).to_stderr
  end

  it "records a tool that raises as a warning, and the model sees ok: false" do
    toolbox = Elelem::Toolbox.new
    toolbox.add("boom", description: "Boom") { raise "kaboom" }

    expect(toolbox.run("boom", {})).not_to be_ok
    expect(File.read(log_path)).to match(/WARN.*toolbox: kaboom/)
  end
end
