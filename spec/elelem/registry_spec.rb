# frozen_string_literal: true

RSpec.describe Elelem::Registry do
  subject(:registry) { described_class.new }

  describe "#build_provider" do
    it "registers a provider factory and builds a provider from it" do
      provider = double("provider")
      registry.configure { |c| c.provider(:test) { provider } }

      expect(registry.build_provider("test")).to eq(provider)
    end

    it "accepts symbol or string names" do
      provider = double("provider")
      registry.configure { |c| c.provider("string_provider") { provider } }

      expect(registry.build_provider(:string_provider)).to eq(provider)
    end

    it "calls the factory on every build, not memoized" do
      call_count = 0
      registry.configure { |c| c.provider(:counter) { call_count += 1 } }

      registry.build_provider("counter")
      registry.build_provider("counter")

      expect(call_count).to eq(2)
    end

    it "raises a friendly error for unknown provider" do
      expect { registry.build_provider("unknown") }.to raise_error(/unknown provider/)
    end

    it "reports a load error inside an installed provider gem as itself" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "elelem"))
        File.write(File.join(dir, "elelem", "broken_dep.rb"), 'require "elelem/no_such_dependency"')
        $LOAD_PATH.unshift(dir)

        expect { registry.build_provider("broken_dep") }
          .to raise_error(LoadError, %r{elelem/no_such_dependency})
      ensure
        $LOAD_PATH.delete(dir)
      end
    end

    it "passes options through to the factory" do
      seen = nil
      registry.configure { |c| c.provider(:model_aware) { |**options| seen = options } }

      registry.build_provider("model_aware", model: "some.gguf")

      expect(seen).to eq(model: "some.gguf")
    end

    it "does not raise when a zero-arg factory is built with options" do
      provider = double("provider")
      registry.configure { |c| c.provider(:legacy) { provider } }

      expect(registry.build_provider("legacy", model: "some.gguf")).to eq(provider)
    end
  end

  describe "#names" do
    it "returns registered provider names" do
      registry.configure do |c|
        c.provider(:alpha) {}
        c.provider(:beta) {}
      end

      expect(registry.names).to contain_exactly("alpha", "beta")
    end
  end

  describe "#apply" do
    it "records a setup block and replays it against an agent later" do
      received = nil
      registry.configure { |c| c.setup(:probe) { |agent| received = agent } }

      agent = double("agent")
      registry.apply(agent)

      expect(received).to eq(agent)
    end
  end

  describe "#reload" do
    it "drops plugin-file setups, keeps gem setups, clears toolbox/commands, then reloads and reapplies" do
      plugins = instance_double(Elelem::Plugins, dirs: [__dir__])
      registry = described_class.new(plugins: plugins)

      calls = []
      registry.configure { |c| c.setup(:stale) { calls << :stale } }
      gem_setup = proc { calls << :gem }
      allow(gem_setup).to receive(:source_location).and_return(["/gems/elelem-tools/lib/elelem/tools.rb", 1])
      registry.configure { |c| c.setup(:gem, &gem_setup) }
      allow(plugins).to receive(:load!) { registry.configure { |c| c.setup(:fresh) { calls << :fresh } } }

      toolbox = instance_double(Elelem::Toolbox, clear!: nil)
      commands = instance_double(Elelem::Commands, clear!: nil)
      agent = double("agent", toolbox: toolbox, commands: commands)

      registry.reload(agent)

      expect(toolbox).to have_received(:clear!)
      expect(commands).to have_received(:clear!)
      expect(plugins).to have_received(:load!).with(force: true)
      expect(calls).to contain_exactly(:gem, :fresh)
    end

    it "preserves provider factories across reload" do
      provider = double("provider")
      registry.configure { |c| c.provider(:test) { provider } }

      toolbox = instance_double(Elelem::Toolbox, clear!: nil)
      commands = instance_double(Elelem::Commands, clear!: nil)
      agent = double("agent", toolbox: toolbox, commands: commands)

      registry.reload(agent)

      expect(registry.build_provider("test")).to eq(provider)
    end
  end

  describe "core's terminal output" do
    let(:core_plugins) { Elelem::Plugins.new(load_paths: [File.expand_path("../../lib/elelem/plugins", __dir__)]) }

    it "is a fallback: an output a gem registered first still wins after plugins load" do
      gem_output = Object.new
      registry = described_class.new(plugins: core_plugins)
      registry.configure { |c| c.output { gem_output } }

      expect(registry.send(:build_output)).to be(gem_output)
    end
  end
end
