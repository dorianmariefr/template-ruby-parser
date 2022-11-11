require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    "a.b",
    "a.b.c",
    "a(1).b.c(2)",
    "user.first_name",
    "User.all",
    "User.each do |user| user.update(created_at: Time.now) end"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect { subject }.to_not raise_error }
    end
  end

  [
    "a /* comment */ . b",
    "a . /* comment */ b",
    "a . # cool\n /* comment */ b"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect(subject.to_json).to include("comment") }
    end
  end
end
