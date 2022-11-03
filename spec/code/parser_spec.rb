require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["", []],
    ["nothing", [{ nothing: { value: "nothing" } }]],
    ["nil", [{ nothing: { value: "nil" } }]],
    ["null", [{ nothing: { value: "null" } }]],
    ["true", [{ boolean: { value: "true" } }]],
    ["false", [{ boolean: { value: "false" } }]],
    ["''", [{ string: { value: "" } }]],
    ['""', [{ string: { value: "" } }]],
    ["'hello'", [{ string: { value: "hello" } }]],
    ['"hello"', [{ string: { value: "hello" } }]],
    ["'hello\"Dorian'", [{ string: { value: 'hello"Dorian' } }]],
    ['"hello\'Dorian"', [{ string: { value: "hello'Dorian" } }]],
    ["'hello\\'Dorian'", [{ string: { value: "hello'Dorian" } }]],
    ['"hello\\"Dorian"', [{ string: { value: 'hello"Dorian' } }]],
  ].each do |input, output|
    context input.inspect do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
