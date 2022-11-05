require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["()", [{ group: [] }]],
    [
      "(true nothing)",
      [{ group: [{ boolean: "true" }, { nothing: "nothing" }] }]
    ],
    [
      "(true (nothing))",
      [{ group: [{ boolean: "true" }, { group: [{ nothing: "nothing" }] }] }]
    ]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
