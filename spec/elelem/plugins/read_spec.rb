# frozen_string_literal: true

RSpec.describe "the read tool" do
  let(:session) { Elelem::Config.build_session("demo", input: Elelem::NullInput.new, output: Elelem::NullOutput.new) }

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

  it "returns the whole of a file up to 64 KB" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "big.txt")
      File.write(path, "a" * 65_536)

      expect(session.toolbox.run("read", { "path" => path })[:content]).to eq("a" * 65_536)
    end
  end

  it "refuses a file over 64 KB and returns none of it" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "huge.txt")
      File.write(path, "a" * 65_537)

      result = session.toolbox.run("read", { "path" => path })
      expect(result[:error]).to eq("file is 65537 bytes; too large to read whole. " \
                                   "Use execute with grep -n or sed -n 'A,Bp'")
      expect(result[:content]).to be_nil
    end
  end
end
