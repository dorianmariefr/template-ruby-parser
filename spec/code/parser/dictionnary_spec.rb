require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["{}", [{ dictionnary: [] }]],
    [
      "{a:1}",
      [{ dictionnary: [{ key: { call: "a" }, value: [{ integer: 1 }] }] }]
    ],
    [
      "{ a: 1 }",
      [{ dictionnary: [{ key: { call: "a" }, value: [{ integer: 1 }] }] }]
    ],
    [
      "{ :a => 1 }",
      [{ dictionnary: [{ key: { string: "a" }, value: [{ integer: 1 }] }] }]
    ],
    [
      "{ :a => 1, b: 2 }",
      [
        {
          dictionnary: [
            { key: { string: "a" }, value: [{ integer: 1 }] },
            { key: { call: "b" }, value: [{ integer: 2 }] }
          ]
        }
      ]
    ],
    [
      "{ :a => 1, b: { c: 2 } }",
      [
        {
          dictionnary: [
            { key: { string: "a" }, value: [{ integer: 1 }] },
            {
              key: {
                call: "b"
              },
              value: [
                {
                  dictionnary: [{ key: { call: "c" }, value: [{ integer: 2 }] }]
                }
              ]
            }
          ]
        }
      ]
    ]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
