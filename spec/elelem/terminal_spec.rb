# frozen_string_literal: true

RSpec.describe Elelem::Terminal do
  subject(:terminal) { described_class.new(stream: stream) }

  let(:stream) { StringIO.new }

  it "keeps the session transcript private to the user", if: !Gem.win_platform? do
    terminal.say("secret")

    dir = File.join(ENV.fetch("XDG_STATE_HOME"), "elelem", "sessions")
    file = Dir["#{dir}/*.transcript"].first
    expect([File.stat(dir).mode & 0o777, File.stat(file).mode & 0o777]).to eq([0o700, 0o600])
    expect(File.read(file)).to eq("secret\n")
  end

  it "writes nothing to disk until there is something to say" do
    terminal

    expect(Dir.children(ENV.fetch("XDG_STATE_HOME"))).to be_empty
  end

  it "shows no dots or blank line for a reply that comes at once" do
    terminal.waiting
    terminal.say("hi")

    expect(stream.string).to eq("hi\n")
  end

  it "ends the dots with a line break before a slow reply" do
    terminal.waiting
    sleep 0.25
    terminal.say("hi")

    expect(stream.string).to match(/\A\.+\nhi\n\z/)
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
