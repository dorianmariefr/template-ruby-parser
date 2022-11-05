require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["a", [{ call: "a" }]],
    ["admin?", [{ call: "admin?" }]],
    ["update!", [{ call: "update!" }]],
    [
      "update!(user)",
      [{ call: { arguments: [[{ call: "user" }]], name: "update!" } }]
    ]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
