require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["{}", [{ dictionnary: [] }]],
    ["{a}", [{ dictionnary: [{ key: [{ variable: "a" }] }] }]],
    ["{1}", [{ dictionnary: [{ key: [{ integer: "1" }] }] }]],
    ["{/* cool */}", [{ dictionnary: [{ key: [{ comment: "/* cool */" }] }] }]],
    [
      "{a:1}",
      [
        {
          dictionnary: [{ key: [{ variable: "a" }], value: [{ integer: "1" }] }]
        }
      ]
    ],
    [
      "{a:1,}",
      [
        {
          dictionnary: [{ key: [{ variable: "a" }], value: [{ integer: "1" }] }]
        }
      ]
    ],
    [
      "{a => 1}",
      [
        {
          dictionnary: [{ key: [{ variable: "a" }], value: [{ integer: "1" }] }]
        }
      ]
    ],
    [
      "{a => 1,}",
      [
        {
          dictionnary: [{ key: [{ variable: "a" }], value: [{ integer: "1" }] }]
        }
      ]
    ],
    [
      "{a => 1, b: 2}",
      [
        {
          dictionnary: [
            { key: [{ variable: "a" }], value: [{ integer: "1" }] },
            { key: [{ variable: "b" }], value: [{ integer: "2" }] }
          ]
        }
      ]
    ],
    [
      "{a => 1, b: 2,}",
      [
        {
          dictionnary: [
            { key: [{ variable: "a" }], value: [{ integer: "1" }] },
            { key: [{ variable: "b" }], value: [{ integer: "2" }] }
          ]
        }
      ]
    ],
    [
      <<~INPUT,
      { /* start */
        a /* key1 */ => 1 // value1
        ,
        /* key2 */ b: 2 # value2
      } /* after */
      INPUT
      [
        {
          dictionnary: [
            {
              key: [
                { comment: "/* start */" },
                { newline: "\n" },
                { variable: "a" },
                { comment: "/* key1 */" }
              ],
              value: [{ integer: "1" }, { comment: "// value1\n" }]
            },
            {
              key: [
                { newline: "\n" },
                { comment: "/* key2 */" },
                { variable: "b" }
              ],
              value: [{ integer: "2" }, { comment: "# value2\n" }]
            }
          ]
        },
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
