# frozen_string_literal: true

RSpec.describe "the write tool" do
  let(:session) { Elelem::Config.build_session("stub", input: Elelem::NullInput.new, output: Elelem::NullOutput.new) }

  it "returns the verify result to the model" do
    session.toolbox.add("verify", description: "Verify", params: { path: { type: "string" } }) do |args|
      { checked: args["path"], error: "ruby -c exited 1" }
    end

    Dir.mktmpdir do |dir|
      path = File.join(dir, "a.rb")
      result = session.toolbox.run("write", { "path" => path, "content" => "x" })

      expect(result[:verify]).to eq(checked: path, error: "ruby -c exited 1", ok: false)
    end
  end

  it "has no verify key without a verify tool" do
    Dir.mktmpdir do |dir|
      result = session.toolbox.run("write", { "path" => File.join(dir, "a"), "content" => "x" })

      expect(result[:bytes]).to eq(1)
      expect(result.key?(:verify)).to be false
    end
  end
end

RSpec.describe "the write tool's diff" do
  let(:stream) { StringIO.new }
  let(:input) { Class.new(Elelem::NullInput) { def interactive? = true }.new }
  let(:session) { Elelem::Config.build_session("stub", input: input, output: Elelem::Output.new(stream: stream)) }

  it "shows the diff through the session output when the session is interactive" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "a.txt")
      File.write(path, "old\n")

      expect { session.toolbox.run("write", { "path" => path, "content" => "new\n" }) }.not_to output.to_stdout
      expect(stream.string).to include("-old", "+new")
    end
  end

  it "still writes the file when diff is not installed" do
    allow(Open3).to receive(:capture2).and_raise(Errno::ENOENT, "diff")
    Dir.mktmpdir do |dir|
      path = File.join(dir, "a.txt")
      File.write(path, "old\n")

      expect(session.toolbox.run("write", { "path" => path, "content" => "new\n" })).to be_ok
      expect(File.read(path)).to eq("new\n")
    end
  end
end
