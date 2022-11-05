require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["[]", [{ list: [] }]],
    ["[1]", [{ list: [[{ integer: 1 }]] }]],
    ["[1,2]", [{ list: [[{ integer: 1 }], [{ integer: 2 }]] }]],
    [
      "[1,[true]]",
      [{ list: [[{ integer: 1 }], [{ list: [[{ boolean: "true" }]] }]] }]
    ]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
