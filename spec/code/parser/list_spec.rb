require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  ["[]", "[1]", "[1,2]", "[1,[true]]"].each do |input|
    context input do
      let!(:input) { input }

      it { expect { subject }.to_not raise_error }
    end
  end

  [
    "[ /* comment */ ]",
    "[ /* comment */ 1 ]",
    "[ 1 /* comment */ ]",
    "[ 1, /* comment */ 2 ]",
    "[ 1, 2 /* comment */ ]"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect(subject.to_json).to include("comment") }
    end
  end
end
