# frozen_string_literal: true

RSpec.describe Elelem::SystemPrompt do
  subject(:prompt) { described_class.new }

  it { expect(prompt.template).to eq(described_class::DEFAULT) }
  it { expect(prompt.render).to include("terminal coding agent") }

  context "with a custom template" do
    subject(:prompt) { described_class.new("Custom template") }

    it { expect(prompt.render).to eq("Custom template") }
  end

  describe "#render" do
    around do |example|
      original = described_class::USER_AGENTS_MD
      described_class.send(:remove_const, :USER_AGENTS_MD)
      described_class.const_set(:USER_AGENTS_MD, Pathname.new(Dir.mktmpdir) / "AGENTS.md")
      example.run
    ensure
      described_class.send(:remove_const, :USER_AGENTS_MD)
      described_class.const_set(:USER_AGENTS_MD, original)
    end

    it "interpolates AGENTS.md from the current directory upward" do
      Dir.mktmpdir do |tmpdir|
        File.write(File.join(tmpdir, "AGENTS.md"), "project rules")
        Dir.chdir(tmpdir) do
          prompt = described_class.new("<%= agents_md %>")
          expect(prompt.render).to eq("project rules")
        end
      end
    end

    it "returns nil when no AGENTS.md is found" do
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          prompt = described_class.new("<%= agents_md.inspect %>")
          expect(prompt.render).to eq("nil")
        end
      end
    end

    it "includes the user's global AGENTS.md" do
      described_class::USER_AGENTS_MD.dirname.mkpath
      described_class::USER_AGENTS_MD.write("global rules")

      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          prompt = described_class.new("<%= agents_md %>")
          expect(prompt.render).to eq("global rules")
        end
      end
    end

    it "combines global and project AGENTS.md, global first" do
      described_class::USER_AGENTS_MD.dirname.mkpath
      described_class::USER_AGENTS_MD.write("global rules")

      Dir.mktmpdir do |tmpdir|
        File.write(File.join(tmpdir, "AGENTS.md"), "project rules")
        Dir.chdir(tmpdir) do
          prompt = described_class.new("<%= agents_md %>")
          expect(prompt.render).to eq("global rules\n\nproject rules")
        end
      end
    end
  end
end
