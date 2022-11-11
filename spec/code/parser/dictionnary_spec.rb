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

  [
    "{ /* comment */ }",
    "{ a /* comment */ : 1",
    "{ a /* comment */ => 1",
    "{ a: 1 /* comment */ }",
    "{ a: 1, /* comment */ b: 2 }",
    "{ a: 1, b /* comment */ : 2 }",
    "{ a: 1, b /* comment */ => 2 }",
    "{ a: 1, b => /* comment */ 2 }",
    "{ a: 1, b => 2 /* comment */ }",
    "{ /* comment */ **kargs }",
    "{ **kargs /* comment */ }"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect(subject.to_json).to include("comment") }
    end
  end
end
