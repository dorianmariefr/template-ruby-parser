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
    "update! /* cool */ { }",
    "each{/* cool */}",
    "render(/* cool */ a)",
    "render(a /* cool */)",
    "render(a, /* cool */ b)",
    "render(a, b /* cool */)",
    "render(/* cool */ a: 1)",
    "render(a: 1 /* cool */)",
    "render(a: 1, /* cool */ b: 2)",
    "render(a: 1, b: 2 /* cool */)",
    "render { /* cool */ |a, b| }",
    "render { |/* cool */ a, b| }",
    "render { |a /* cool */, b| }",
    "render { |a: 1, /* cool */ b: 2| }",
    "render { |a: 1, b: 2 /* cool */| }"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect(subject.to_json).to include("cool") }
    end
  end
end
