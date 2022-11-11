require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["a ** b", [{ power: { left: { call: "a" }, right: { call: "b" } } }]],
    [
      "a ** b ** c ** d",
      [
        {
          power: {
            left: {
              call: "a"
            },
            right: {
              power: {
                left: {
                  call: "b"
                },
                right: {
                  power: {
                    left: {
                      call: "c"
                    },
                    right: {
                      call: "d"
                    }
                  }
                }
              }
            }
          }
        }
      ]
    ]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
