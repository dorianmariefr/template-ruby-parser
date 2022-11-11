require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  ["[]", "[1]", "[1,2]", "[1,[true]]"].each do |input|
    context input do
      let!(:input) { input }

      it { expect { subject }.to_not raise_error }
    end
  end
end
