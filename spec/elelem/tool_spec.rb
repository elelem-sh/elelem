# frozen_string_literal: true

RSpec.describe Elelem::Tool do
  def tool(params = {}, required = [])
    described_class.new("t", description: "A tool", params: params, required: required) { |args| args }
  end

  def errors(schema, value)
    tool({ p: schema }).validate({ "p" => value })
  end

  describe "#to_h" do
    it "describes the tool as a function with an object schema" do
      params = { path: { type: "string" } }

      expect(tool(params, ["path"]).to_h).to eq(
        type: "function",
        function: {
          name: "t",
          description: "A tool",
          parameters: { type: "object", properties: params, required: ["path"] }
        }
      )
    end
  end

  describe "#validate" do
    samples = {
      "string" => "a", "integer" => 1, "number" => 1.5, "boolean" => true,
      "array" => [1], "object" => { "a" => 1 }, "null" => nil
    }

    samples.each do |type, value|
      it "accepts #{value.inspect} as #{type}" do
        expect(errors({ type: type }, value)).to be_empty
      end

      samples.except(type).each do |other, wrong|
        next if type == "number" && other == "integer"

        it "rejects #{wrong.inspect} as #{type}" do
          expect(errors({ type: type }, wrong)).to eq(["p: expected #{type}, got #{other}"])
        end
      end
    end

    it "accepts false as boolean" do
      expect(errors({ type: "boolean" }, false)).to be_empty
    end

    it "accepts empty values of the right type" do
      expect([["string", ""], ["array", []], ["object", {}]].flat_map { |type, value| errors({ type: type }, value) })
        .to be_empty
    end

    describe "integer" do
      it "accepts zero, negative and very large integers" do
        expect([0, -3, 10**30].flat_map { |value| errors({ type: "integer" }, value) }).to be_empty
      end

      it "accepts a whole float, as JSON Schema does" do
        expect([2.0, -0.0, 1e30].flat_map { |value| errors({ type: "integer" }, value) }).to be_empty
      end

      it "rejects a float with a fraction" do
        expect(errors({ type: "integer" }, 2.5)).to eq(["p: expected integer, got number"])
      end

      it "rejects floats that are not finite" do
        expect([Float::NAN, Float::INFINITY].map { |value| errors({ type: "integer" }, value) })
          .to all(eq(["p: expected integer, got number"]))
      end

      it "rejects a string of digits" do
        expect(errors({ type: "integer" }, "2")).to eq(["p: expected integer, got string"])
      end

      it "rejects true" do
        expect(errors({ type: "integer" }, true)).to eq(["p: expected integer, got boolean"])
      end
    end

    describe "number" do
      it "accepts integers and floats" do
        expect([0, -3, 2.0, 2.5].flat_map { |value| errors({ type: "number" }, value) }).to be_empty
      end

      it "rejects a numeric string" do
        expect(errors({ type: "number" }, "2.5")).to eq(["p: expected number, got string"])
      end
    end

    describe "a list of types" do
      it "accepts a value of any listed type" do
        expect(["a", nil].flat_map { |value| errors({ type: %w[string null] }, value) }).to be_empty
      end

      it "rejects a value of no listed type" do
        expect(errors({ type: %w[string null] }, 1)).to eq(["p: expected string or null, got integer"])
      end

      it "accepts anything when the list is empty" do
        expect(errors({ type: [] }, 1)).to be_empty
      end

      it "accepts anything when the list names an unknown type" do
        expect(errors({ type: %w[string date] }, 1)).to be_empty
      end
    end

    describe "enum" do
      it "accepts a listed value" do
        expect(errors({ type: "string", enum: %w[a b] }, "b")).to be_empty
      end

      it "rejects an unlisted value" do
        expect(errors({ type: "string", enum: %w[a b] }, "c")).to eq(['p: expected one of "a", "b"'])
      end

      it "works without a type, and names the values as JSON" do
        expect(errors({ enum: ["a", 1, nil, true] }, 2)).to eq(['p: expected one of "a", 1, null, true'])
      end

      it "accepts a listed null" do
        expect(errors({ enum: ["a", nil] }, nil)).to be_empty
      end

      it "reports only the type when the type is wrong too" do
        expect(errors({ type: "string", enum: %w[a b] }, 1)).to eq(["p: expected string, got integer"])
      end

      it "ignores an enum that is not a list" do
        expect(errors({ enum: "a" }, "b")).to be_empty
      end
    end

    describe "required" do
      subject { tool({ path: { type: "string" }, content: { type: "string" } }, %w[path content]) }

      it "accepts arguments with every required key" do
        expect(subject.validate({ "path" => "a", "content" => "b" })).to be_empty
      end

      it "names every missing key in one message" do
        expect(subject.validate({})).to eq(["missing required: path, content"])
      end

      it "names only the keys that are missing" do
        expect(subject.validate({ "path" => "a" })).to eq(["missing required: content"])
      end

      it "treats a required key with a null value as present, and checks its type" do
        expect(subject.validate({ "path" => nil, "content" => "b" })).to eq(["path: expected string, got null"])
      end

      it "reports missing keys before wrong types" do
        expect(subject.validate({ "content" => 1 }))
          .to eq(["missing required: path", "content: expected string, got integer"])
      end

      it "requires a key that has no property" do
        expect(tool({}, ["path"]).validate({})).to eq(["missing required: path"])
      end

      it "accepts required keys given as symbols" do
        expect(tool({}, [:path]).validate({ "path" => "a" })).to be_empty
      end

      it "does not check an optional key that is absent" do
        expect(tool({ path: { type: "string" } }).validate({})).to be_empty
      end
    end

    describe "arguments" do
      subject { tool({ path: { type: "string" } }, ["path"]) }

      it "treats nil as no arguments" do
        expect(subject.validate(nil)).to eq(["missing required: path"])
      end

      it "accepts nil when nothing is required" do
        expect(tool.validate(nil)).to be_empty
      end

      it "rejects arguments that are not an object" do
        expect([[], "a", 1, false].map { |args| subject.validate(args) }).to eq(
          [
            ["arguments: expected object, got array"],
            ["arguments: expected object, got string"],
            ["arguments: expected object, got integer"],
            ["arguments: expected object, got boolean"]
          ]
        )
      end

      it "allows keys that are not in the schema" do
        expect(subject.validate({ "path" => "a", "extra" => 1 })).to be_empty
      end

      it "reads arguments by string key only, as the handlers do" do
        expect(subject.validate({ path: "a" })).to eq(["missing required: path"])
      end

      it "validates frozen arguments" do
        expect(subject.validate({ "path" => 1 }.freeze)).to eq(["path: expected string, got integer"])
      end
    end

    describe "schema keys" do
      it "reads a schema written with string keys" do
        strings = tool({ "path" => { "type" => "string", "enum" => %w[a b] } }, ["path"])

        expect([{}, { "path" => 1 }, { "path" => "c" }, { "path" => "a" }].flat_map { |args| strings.validate(args) })
          .to eq(["missing required: path", "path: expected string, got integer", 'path: expected one of "a", "b"'])
      end

      it "reads a type given as a symbol" do
        expect(errors({ type: :string }, 1)).to eq(["p: expected string, got integer"])
      end
    end

    describe "schemas it does not understand" do
      it "ignores an unknown type" do
        expect(errors({ type: "date" }, 1)).to be_empty
      end

      it "ignores a property with no type" do
        expect(errors({ description: "anything" }, 1)).to be_empty
      end

      it "checks only the top level of a nested object" do
        nested = { type: "object", properties: { name: { type: "string" } }, required: ["name"] }

        expect(errors(nested, { "name" => 1 })).to be_empty
      end

      it "checks only the top level of an array" do
        expect(errors({ type: "array", items: { type: "string" }, minItems: 3 }, [1])).to be_empty
      end

      it "ignores anyOf, oneOf and allOf" do
        expect(%i[anyOf oneOf allOf].flat_map { |key| errors({ key => [{ type: "string" }] }, 1) }).to be_empty
      end

      it "ignores a $ref, even one that points nowhere" do
        expect(errors({ "$ref": "#/$defs/missing" }, 1)).to be_empty
      end

      it "ignores pattern, format, bounds and unknown keywords" do
        schema = {
          type: "string", pattern: "^a$", format: "email", minLength: 9, maxLength: 0,
          additionalProperties: false, const: "z", "x-unknown": Object.new
        }

        expect(errors(schema, "b")).to be_empty
      end

      it "ignores bounds on a number" do
        expect(errors({ type: "integer", minimum: 5, maximum: 6, multipleOf: 4 }, 1)).to be_empty
      end

      it "ignores a property schema that is not a hash" do
        expect([true, false, nil, "string", 1, []].flat_map { |schema| errors(schema, 1) }).to be_empty
      end

      it "ignores a type or enum of the wrong shape" do
        expect([{ type: { a: 1 } }, { type: 1 }, { type: nil }, { type: [nil, 1] }, { enum: { a: 1 } }]
          .flat_map { |schema| errors(schema, 1) }).to be_empty
      end

      it "ignores properties that are not a hash" do
        expect([nil, [], [1, 2], "path", 1].flat_map { |params| tool(params).validate({ "path" => 1 }) }).to be_empty
      end

      it "ignores a required list of the wrong shape" do
        expect([nil, true, 1, { a: 1 }, [1, nil, ["a"]]].flat_map { |required| tool({}, required).validate({}) })
          .to be_empty
      end
    end
  end
end
