require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["nothing", [{ nothing: "nothing" }]],
    ["null", [{ nothing: "null" }]],
    ["nil", [{ nothing: "nil" }]],
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
