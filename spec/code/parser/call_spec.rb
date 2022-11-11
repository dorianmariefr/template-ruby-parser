require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["a", [{ call: "a" }]],
    ["admin?", [{ call: "admin?" }]],
    ["update!", [{ call: "update!" }]],
    ["*args", [{ call: { name: "args", splat: :regular } }]],
    ["**kargs", [{ call: { name: "kargs", splat: :keyword } }]],
    ["&block", [{ call: { block: true, name: "block" } }]],
    [
      "update!(user)",
      [{ call: { arguments: [[{ call: "user" }]], name: "update!" } }]
    ],
    ["each{}", [{ call: { block_body: [], name: "each" } }]],
    ["each do end", [{ call: { block_body: [], name: "each" } }]],
    [
      "render(a, *b, **c, &d) { |e, *f, **g, &h| puts(e) }",
      [
        {
          call: {
            arguments: [
              [{ call: "a" }],
              [{ call: { name: "b", splat: :regular } }],
              [{ call: { name: "c", splat: :keyword } }],
              [{ call: { block: true, name: "d" } }]
            ],
            block_parameters: [
              { name: "e" },
              { name: "f", splat: :regular },
              { name: "g", splat: :keyword },
              { block: true, name: "h" }
            ],
            block_body: [
              { call: { arguments: [[{ call: "e" }]], name: "puts" } }
            ],
            name: "render"
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
