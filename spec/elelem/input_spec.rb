# frozen_string_literal: true

RSpec.describe Elelem::Input do
  it "completes file names without a shell" do
    allow(Open3).to receive(:capture2)

    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "notes.md"), "")

      expect(described_class.new.send(:complete, "#{dir}/no", "read ")).to eq(["#{dir}/notes.md"])
    end
    expect(Open3).not_to have_received(:capture2)
  end

  it "completes glob characters literally, without walking the tree" do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "a[1].txt"), "")
      File.write(File.join(dir, "a1.txt"), "")

      expect(described_class.new.send(:complete_files, "#{dir}/a[")).to eq(["#{dir}/a[1].txt"])
      expect(described_class.new.send(:complete_files, "**")).to eq([])
    end
  end
end
