require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    "a",
    "admin?",
    "update!",
    "*args",
    "**kargs",
    "&block",
    "update!(user)",
    "each{}",
    "each do end",
    "render(a, *b, **c, &d) { |e, *f, **g, &h| puts(e) }",
    "&render {}"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect { subject }.to_not raise_error }
    end
  end

  [
    "update! /* comment */ { }",
    "each{/* comment */}",
    "render(/* comment */ a)",
    "render(a /* comment */)",
    "render(a, /* comment */ b)",
    "render(a, b /* comment */)",
    "render(/* comment */ a: 1)",
    "render(a: 1 /* comment */)",
    "render(a: 1, /* comment */ b: 2)",
    "render(a: 1, b: 2 /* comment */)",
    "render { /* comment */ |a, b| }",
    "render { |/* comment */ a, b| }",
    "render { |a /* comment */, b| }",
    "render { |a: 1, /* comment */ b: 2| }",
    "render { |a: 1, b: 2 /* comment */| }"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect(subject.to_json).to include("comment") }
    end
  end
end
