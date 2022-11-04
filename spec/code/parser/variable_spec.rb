require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["a", [{ variable: "a" }]],
    ["hello", [{ variable: "hello" }]],
    ["User", [{ variable: "User" }]],
    ["UserController", [{ variable: "UserController" }]],
    ["admin?", [{ variable: "admin?" }]],
    ["defined?", [{ variable: "defined?" }]],
    ["update!", [{ variable: "update!" }]],
    ["*args", [{ variable: { name: "args", splat: :regular } }]],
    ["**kargs", [{ variable: { name: "kargs", splat: :keyword} }]],
    ["&block", [{ variable: { name: "block", block: true } }]]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
