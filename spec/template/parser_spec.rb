require "spec_helper"

RSpec.describe ::Template::Parser do
  subject { ::Template::Parser.parse(input) }

  [
    ["", []],
    ["Hello Dorian", [{ text: "Hello Dorian" }]],
    ["Hello \\{name}", [{ text: "Hello {name}" }]],
    [
      "Hello {name}",
      [{ text: "Hello " }, { code: [{ variable: { value: "name" } }] }]
    ],
    [
      "Hello {name} you are {age} years old",
      [
        { text: "Hello " },
        { code: [{ variable: { value: "name" } }] },
        { text: " you are " },
        { code: [{ variable: { value: "age" } }] },
        { text: " years old" }
      ]
    ],
    ["{name", [{ code: [{ variable: { value: "name" } }] }]],
    ["{nothing", [{ code: [{ nothing: { value: "nothing" } }] }]],
    ["{nil", [{ code: [{ nothing: { value: "nil" } }] }]],
    ["{null", [{ code: [{ nothing: { value: "null" } }] }]],
    ["{true", [{ code: [{ boolean: { value: "true" } }] }]],
    ["{false", [{ code: [{ boolean: { value: "false" } }] }]]
  ].each do |input, output|
    context input.inspect do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
