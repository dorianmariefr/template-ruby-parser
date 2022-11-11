require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["!a", [{ negation: { call: "a" } }]],
    ["!!a", [{ negation: { negation: { call: "a" } } }]]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
