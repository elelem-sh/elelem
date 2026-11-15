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
