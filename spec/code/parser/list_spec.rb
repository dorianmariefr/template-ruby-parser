require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["[]", [{ list: [] }]],
    ["[1]", [{ list: [[{ integer: "1" }]] }]],
    ["[1,2]", [{ list: [[{ integer: "1" }], [{ integer: "2" }]] }]],
    [
      "[1,2,3]",
      [{ list: [[{ integer: "1" }], [{ integer: "2" }], [{ integer: "3" }]] }]
    ],
    ["[1,2,]", [{ list: [[{ integer: "1" }], [{ integer: "2" }]] }]],
    ["[1, 2]", [{ list: [[{ integer: "1" }], [{ integer: "2" }]] }]],
    [
      "[1, /* two */ 2]",
      [
        {
          list: [
            [{ integer: "1" }],
            [{ comment: "/* two */" }, { integer: "2" }]
          ]
        }
      ]
    ],
    [
      "[1, [2, 3]]",
      [
        {
          list: [
            [{ integer: "1" }],
            [{ list: [[{ integer: "2" }], [{ integer: "3" }]] }]
          ]
        }
      ]
    ],
    [
      <<~INPUT,
      /* before */
      [ # start
        a, // first
        b, # second
        /*
          third
        */
        c
      ]
      /* after */
      INPUT
      [
        { comment: "/* before */" },
        { newline: "\n" },
        {
          list: [
            [{ comment: "# start\n" }, { variable: "a" }],
            [{ comment: "// first\n" }, { variable: "b" }],
            [
              { comment: "# second\n" },
              { comment: "/*\n    third\n  */" },
              { newline: "\n" },
              { variable: "c" },
              { newline: "\n" }
            ]
          ]
        },
        { newline: "\n" },
        { comment: "/* after */" },
        { newline: "\n" }
      ]
    ]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
