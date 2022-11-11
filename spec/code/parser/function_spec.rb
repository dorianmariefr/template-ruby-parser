require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    "()=>{}",
    "() => {}",
    "(a, b) => { add(a, b) }",
    "(a, b = 1, c:, d: 2, *e, **f) => { }",
    "(a?, b! = 1, c?:, d?: 2, *e?, *f!, **g?, **h!) => { }"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect { subject }.to_not raise_error }
    end
  end
end
