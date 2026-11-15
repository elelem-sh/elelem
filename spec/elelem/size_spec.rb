# frozen_string_literal: true

RSpec.describe "the size of elelem" do
  it "keeps the core, without its plugins, within 1,024 lines of code" do
    root = File.expand_path("../../lib", __dir__)
    core = Dir["#{root}/**/*.rb"].reject { |path| path.start_with?("#{root}/elelem/plugins/") }
    lines = core.flat_map { |path| File.readlines(path) }.map(&:strip)
    code = lines.reject { |line| line.empty? || line.start_with?("#") }

    expect(code.size).to be <= 1024
  end
end
