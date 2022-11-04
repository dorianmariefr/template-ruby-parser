require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["", []],
    ["nothing", [{ nothing: "nothing" }]],
    ["nil", [{ nothing: "nil" }]],
    ["null", [{ nothing: "null" }]],
    ["true", [{ boolean: "true" }]],
    ["false", [{ boolean: "false" }]],
    ["''", [{ string: [] }]],
    ['""', [{ string: [] }]],
    ["'hello'", [{ string: [{ text: "hello" }] }]],
    ['"hello"', [{ string: [{ text: "hello" }] }]],
    [
      "'hello\\a\\b\\r\\n\\s\\t'",
      [{ string: [{ text: "hello\a\b\r\n\s\t" }] }]
    ],
    [
      '"hello\\a\\b\\r\\n\\s\\t"',
      [{ string: [{ text: "hello\a\b\r\n\s\t" }] }]
    ],
    ['"hello"', [{ string: [{ text: "hello" }] }]],
    ["'hello\"Dorian'", [{ string: [{ text: 'hello"Dorian' }] }]],
    ['"hello\'Dorian"', [{ string: [{ text: "hello'Dorian" }] }]],
    ["'hello\\'Dorian'", [{ string: [{ text: "hello'Dorian" }] }]],
    ['"hello\\"Dorian"', [{ string: [{ text: 'hello"Dorian' }] }]],
    ["'hello \\{name}'", [{ string: [{ text: "hello {name}" }] }]],
    ['"hello \\{name}"', [{ string: [{ text: "hello {name}" }] }]],
    [
      "'hello {name}'",
      [{ string: [{ text: "hello " }, { code: [{ variable: "name" }] }] }]
    ],
    [
      '"hello {name}"',
      [{ string: [{ text: "hello " }, { code: [{ variable: "name" }] }] }]
    ],
    ["1", [{ integer: "1" }]],
    ["100", [{ integer: "100" }]],
    ["1.0", [{ decimal: "1.0" }]],
    ["123.24", [{ decimal: "123.24" }]]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
