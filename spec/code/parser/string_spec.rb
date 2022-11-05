require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["''", [{ string: "" }]],
    ['""', [{ string: "" }]],
    [":a", [{ string: "a" }]],
    ["'Hello Dorian'", [{ string: "Hello Dorian" }]],
    ['"Hello Dorian"', [{ string: "Hello Dorian" }]],
    ["'Hello \\' Dorian'", [{ string: "Hello ' Dorian" }]],
    ['"Hello \\" Dorian"', [{ string: 'Hello " Dorian' }]],
    ["'Hello \\{name}'", [{ string: "Hello {name}" }]],
    ['"Hello \\{name}', [{ string: "Hello {name}" }]],
    [
      "'Hello {name}'",
      [{ string: [{ text: "Hello " }, { code: [{ call: "name" }] }] }]
    ],
    [
      '"Hello {name}',
      [{ string: [{ text: "Hello " }, { code: [{ call: "name" }] }] }]
    ],
    ['"Hello \\n\\a\\{"', [{ string: "Hello \n\\a{" }]],
    ["'Hello \\n\\a\\{'", [{ string: "Hello \n\\a{" }]]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
