require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    "{}",
    "{a:1}",
    "{ a: 1 }",
    "{ :a => 1 }",
    "{ :a => 1, b: 2 }",
    "{ :a => 1, b: { c: 2 } }"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect { subject }.to_not raise_error }
    end
  end
end
