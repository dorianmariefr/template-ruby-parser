require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["()=>{}", [{ function: { body: [] } }]],
    ["() => {}", [{ function: { body: [] } }]],
    [
      "(a, b) => { add(a, b) }",
      [
        {
          function: {
            body: [
              {
                call: {
                  arguments: [[{ call: "a" }], [{ call: "b" }]],
                  name: "add"
                }
              }
            ],
            parameters: [{ name: "a" }, { name: "b" }]
          }
        }
      ]
    ],
    [
      "(a, b = 1, c:, d: 2, *e, **f) => { }",
      [
        {
          function: {
            body: [],
            parameters: [
              { name: "a" },
              { default: [{ integer: 1 }], name: "b" },
              { keyword: true, name: "c" },
              { default: [{ integer: 2 }], keyword: true, name: "d" },
              { name: "e", splat: :regular },
              { name: "f", splat: :keyword }
            ]
          }
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
