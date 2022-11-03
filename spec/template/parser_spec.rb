require "spec_helper"

RSpec.describe ::Template::Parser do
  subject { ::Template::Parser.parse(input) }

  [
    ["", []],
    ["Hello Dorian", [{ text: "Hello Dorian" }]],
    ["Hello \\{name}", [{ text: "Hello {name}" }]],
    ["Hello {name}", [{ text: "Hello " }, { code: [{ variable: "name" }] }]],
    [
      "Hello {name} you are {age} years old",
      [
        { text: "Hello " },
        { code: [{ variable: "name" }] },
        { text: " you are " },
        { code: [{ variable: "age" }] },
        { text: " years old" }
      ]
    ],
    ["{name", [{ code: [{ variable: "name" }] }]],
    ["{nothing", [{ code: [{ nothing: "nothing" }] }]],
    ["{nil", [{ code: [{ nothing: "nil" }] }]],
    ["{null", [{ code: [{ nothing: "null" }] }]],
    ["{true", [{ code: [{ boolean: "true" }] }]],
    ["{false", [{ code: [{ boolean: "false" }] }]]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
