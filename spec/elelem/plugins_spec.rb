# frozen_string_literal: true

require "tmpdir"
require "fileutils"

RSpec.describe Elelem::Plugins do
  subject(:plugins) { described_class.new }

  let(:tmp_dir) { Dir.mktmpdir }
  let(:plugin_dir) { File.join(tmp_dir, "plugins") }

  before do
    FileUtils.mkdir_p(plugin_dir)
    stub_const("Elelem::Plugins::LOAD_PATHS", [plugin_dir].freeze)
  end

  after { FileUtils.remove_entry(tmp_dir) }

  it "loads .rb files from the configured paths" do
    File.write(File.join(plugin_dir, "probe.rb"), "$plugins_spec_loaded = true")

    plugins.load!

    expect($plugins_spec_loaded).to eq(true)
  ensure
    $plugins_spec_loaded = nil
  end

  it "only loads once unless forced" do
    File.write(File.join(plugin_dir, "counter.rb"), "$plugins_spec_count = ($plugins_spec_count || 0) + 1")

    plugins.load!
    plugins.load!

    expect($plugins_spec_count).to eq(1)
  ensure
    $plugins_spec_count = nil
  end

  it "loads a directory named twice only once, as ~/.agents/plugins is when run from home" do
    File.write(File.join(plugin_dir, "counter.rb"), "$plugins_spec_count = ($plugins_spec_count || 0) + 1")

    described_class.new(load_paths: [plugin_dir, "#{plugin_dir}/"]).load!

    expect($plugins_spec_count).to eq(1)
  ensure
    $plugins_spec_count = nil
  end

  it "reloads when forced" do
    File.write(File.join(plugin_dir, "counter.rb"), "$plugins_spec_count = ($plugins_spec_count || 0) + 1")

    plugins.load!
    plugins.load!(force: true)

    expect($plugins_spec_count).to eq(2)
  ensure
    $plugins_spec_count = nil
  end

  it "warns and continues when a plugin requires a missing gem" do
    File.write(File.join(plugin_dir, "broken.rb"), 'require "nope/not/real"')

    expect { plugins.load! }.to output(/failed to load plugin/).to_stderr
  end

  it "logs a plugin that fails to load" do
    File.write(File.join(plugin_dir, "broken.rb"), 'raise "kaboom"')

    expect { plugins.load! }.to output(/kaboom/).to_stderr
    expect(File.read(File.join(Elelem.state_dir, "elelem.log"))).to match(/WARN.*plugins: .*broken.rb: kaboom/)
  end

  it "warns and continues when a plugin has a syntax error" do
    File.write(File.join(plugin_dir, "broken.rb"), "def broken(")

    expect { plugins.load! }.to output(/failed to load plugin/).to_stderr
  end
end
