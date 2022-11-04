require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["(1)", [{ group: [{ integer: "1" }] }]],
    ["(a b)", [{ group: [{ variable: "a" }, { variable: "b" }] }]]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
