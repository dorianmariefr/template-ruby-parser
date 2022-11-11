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

  [
    "(/* comment */)=>{}",
    "(/* comment */ a)=>{}",
    "(/* comment */ a:)=>{}",
    "(a /* comment */ )=>{}",
    "(a /* comment */ :)=>{}",
    "(a /* comment */ => 1)=>{}",
    "(a = /* comment */ 1)=>{}",
    "(a = 1 /* comment */)=>{}",
    "(a, /* comment */ b)=>{}",
    "(a, b /* comment */)=>{}",
    "(a, b /* comment */ = 1)=>{}",
    "(a, b: /* comment */)=>{}",
    "() /* comment */ => {}",
    "() => /* comment */ {}",
    "() => { /* comment */ }"
  ].each do |input|
    context input do
      let!(:input) { input }

      it { expect(subject.to_json).to include("comment") }
    end
  end
end
