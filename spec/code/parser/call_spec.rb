require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["a()", [{:call=>{:name=>"a"}}]],
    ["hello(1)", [{:call=>{:arguments=>[[{:integer=>"1"}]], :name=>"hello"}}]],
    ["User(:name)", [{:call=>{:arguments=>[[{:string=>"name"}]], :name=>"User"}}]]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
