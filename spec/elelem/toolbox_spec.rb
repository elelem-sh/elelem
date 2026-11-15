# frozen_string_literal: true

RSpec.describe Elelem::Toolbox do
  subject { described_class.new }

  before do
    subject.add("read",
                description: "Read file",
                params: { path: { type: "string" } },
                required: ["path"],
                aliases: ["open"]) { |a| { content: File.read(a["path"]) } }

    subject.add("write",
                description: "Write file",
                params: { path: { type: "string" }, content: { type: "string" } },
                required: %w[path content]) { |a| { bytes: File.write(a["path"], a["content"]) } }
  end

  describe "#to_a" do
    it "returns all tools in API format" do
      tool_names = subject.to_a.map { |t| t.dig(:function, :name) }
      expect(tool_names).to include("read", "write")
    end
  end

  describe "#run" do
    it "executes read tool" do
      result = subject.run("read", { "path" => __FILE__ })
      expect(result[:content]).to include("RSpec.describe")
    end

    it "resolves open alias to read" do
      result = subject.run("open", { "path" => __FILE__ })
      expect(result[:content]).to include("RSpec.describe")
    end

    it "runs a real tool named like another tool's alias" do
      subject.add("open", description: "Open a URL") { |_a| { opened: true } }

      expect(subject.run("open", { "path" => __FILE__ })[:opened]).to be(true)
    end

    it "returns error for unknown tools" do
      result = subject.run("nonexistent", {})
      expect(result[:error]).to include("unknown tool")
    end

    it "returns a failure result instead of crashing when a tool raises a LoadError" do
      subject.add("broken", description: "Broken tool", params: {}, required: []) { require "nope/not/real" }

      result = subject.run("broken", {})

      expect(result[:error]).to include("nope/not/real")
    end
  end

  describe "#tool_for" do
    it "returns nil for an unknown name" do
      expect(subject.tool_for("nonexistent")).to be_nil
    end
  end

  describe "hooks with unknown tools" do
    it "does not fire before(:*) or after(:*) hooks for an unknown tool" do
      called = false
      subject.before { |_args, tool_name:| called = true }
      subject.after { |_args, _result, tool_name:| called = true }
      result = subject.run("nonexistent", {})
      expect(called).to be false
      expect(result[:error]).to include("unknown tool")
    end
  end

  describe "hooks" do
    it "runs tool-specific before hooks" do
      called = false
      subject.before("read") { |_args| called = true }
      subject.run("read", { "path" => __FILE__ })
      expect(called).to be true
    end

    it "runs tool-specific after hooks" do
      result_seen = nil
      subject.after("read") { |_args, result| result_seen = result }
      subject.run("read", { "path" => __FILE__ })
      expect(result_seen[:content]).to include("RSpec.describe")
    end

    it "runs global before hooks with tool_name" do
      tool_names = []
      subject.before { |_args, tool_name:| tool_names << tool_name }
      subject.run("read", { "path" => __FILE__ })
      subject.run("write", { "path" => "/dev/null", "content" => "" })
      expect(tool_names).to eq(%w[read write])
    end

    it "runs global after hooks with tool_name" do
      tool_names = []
      subject.after { |_args, _result, tool_name:| tool_names << tool_name }
      subject.run("read", { "path" => __FILE__ })
      expect(tool_names).to eq(["read"])
    end

    it "runs global hooks before tool-specific hooks" do
      order = []
      subject.before { |_args, tool_name:| order << :global }
      subject.before("read") { |_args| order << :specific }
      subject.run("read", { "path" => __FILE__ })
      expect(order).to eq(%i[global specific])
    end
  end

  it "returns the tool it adds, so eval can show it" do
    tool = described_class.new.add("now", description: "Current time") { {} }

    expect(tool.inspect).to eq("#<Elelem::Tool now>")
  end

  it "treats error: from a tool as a failure" do
    toolbox = described_class.new
    toolbox.add("check", description: "Check", params: {}) { { error: "exit 1", exit_status: 1 } }

    expect(toolbox.run("check", {})).not_to be_ok
  end
end
