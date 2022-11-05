require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["1", [{:integer=>1}]],
    ["100", [{:integer=>100}]],
    ["0", [{:integer=>0}]],
    ["1_000", [{:integer=>1000}]],
    ["1.34", [{:decimal=>"1.34"}]],
    ["1_000.300_400", [{:decimal=>"1000.300400"}]],
    ["0x10", [{ integer: 16 }]],
    ["0o10", [{ integer: 8 }]],
    ["0b10", [{ integer: 2 }]],
    ["0b1_0000_0000", [{ integer: 256 }]],
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
