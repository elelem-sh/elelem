# frozen_string_literal: true

RSpec.describe Elelem::Builtins::Terminal do
  subject(:terminal) { described_class.new(stream: stream) }

  let(:stream) { StringIO.new }

  around do |example|
    Dir.mktmpdir do |dir|
      saved = ENV.fetch("XDG_STATE_HOME", nil)
      ENV["XDG_STATE_HOME"] = dir
      example.run
    ensure
      saved ? ENV.store("XDG_STATE_HOME", saved) : ENV.delete("XDG_STATE_HOME")
    end
  end

  it "keeps the session transcript private to the user" do
    terminal.say("secret")

    dir = File.join(ENV.fetch("XDG_STATE_HOME"), "elelem", "sessions")
    file = Dir["#{dir}/*.transcript"].first
    expect([File.stat(dir).mode & 0o777, File.stat(file).mode & 0o777]).to eq([0o700, 0o600])
    expect(File.read(file)).to eq("secret\n")
  end

  it "says an error in ASCII" do
    terminal.say("boom", as: :error)

    expect(stream.string).to be_ascii_only
    expect(stream.string).to include("boom")
  end

  it "tells bat that the path is not an option" do
    allow(terminal).to receive(:system).and_return(true)

    terminal.display_file("--help")

    expect(terminal).to have_received(:system).with("bat", "--paging=never", "--", "--help")
  end
end
