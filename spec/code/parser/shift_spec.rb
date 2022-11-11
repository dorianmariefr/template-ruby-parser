require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  ["a << b", "a >> b", "(a << b) >> c", "a << (b >> c)"].each do |input|
    context input do
      let!(:input) { input }

      it { expect { subject }.to_not raise_error }
    end
  end

  [
    "a /+ comment */ << b",
    "a >> /* comment */ b",
    "a <<  b >> c /* comment */",
    "a >> b << /* comment */ c"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect(subject.to_json).to include("comment") }
    end
  end
end
