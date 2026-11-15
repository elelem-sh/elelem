# frozen_string_literal: true

RSpec.describe "the read tool" do
  let(:session) { Elelem::Config.build_session("stub", input: Elelem::NullInput.new, output: Elelem::NullOutput.new) }

  it "fails on a binary file instead of returning bytes the model cannot read" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "a.bin")
      File.binwrite(path, "\xFF\xFE\x00".b)

      expect(session.toolbox.run("read", { "path" => path })[:error]).to eq("binary file (3 bytes)")
    end
  end

  it "fails on a binary file made only of valid UTF-8 bytes" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "a.out")
      File.binwrite(path, "\x00\x01\x02ELF".b)

      expect(session.toolbox.run("read", { "path" => path })[:error]).to eq("binary file (6 bytes)")
    end
  end

  it "reads a text file that is not UTF-8, replacing the bytes it cannot decode" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "latin1.txt")
      File.binwrite(path, "caf\xE9 au lait".b)

      content = session.toolbox.run("read", { "path" => path })[:content]
      expect(content).to eq("caf\uFFFD au lait")
      expect(content).to be_valid_encoding
    end
  end

  it "truncates a large file as execute does" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "big.txt")
      File.write(path, "a" * 20_000)

      expect(session.toolbox.run("read", { "path" => path })[:content]).to include("[10000 characters elided]")
    end
  end
end
