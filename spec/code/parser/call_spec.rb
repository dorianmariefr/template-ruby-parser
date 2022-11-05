require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["a()", [{ call: { name: "a" } }]],
    [
      "hello(1)",
      [{ call: { arguments: [[{ integer: "1" }]], name: "hello" } }]
    ],
    [
      "User(:name)",
      [{ call: { arguments: [[{ string: "name" }]], name: "User" } }]
    ],
    [
      "each(&:update)",
      [
        {
          call: {
            arguments: [[{ variable: { block: true, name: ":update" } }]],
            name: "each"
          }
        }
      ]
    ],
    [
      "each do |user| update(user) end",
      [
        {
          variable: {
            block: {
              arguments: [[{ variable: "user" }]],
              body: [
                {
                  call: {
                    arguments: [[{ variable: "user" }]],
                    name: "update"
                  }
                }
              ]
            },
            name: "each"
          }
        }
      ]
    ],
    [
      "each { |user| update(user) }",
      [
        {
          variable: {
            block: {
              arguments: [[{ variable: "user" }]],
              body: [
                {
                  call: {
                    arguments: [[{ variable: "user" }]],
                    name: "update"
                  }
                }
              ]
            },
            name: "each"
          }
        }
      ]
    ],
    [
      "each{|user|update(user)}",
      [
        {
          variable: {
            block: {
              arguments: [[{ variable: "user" }]],
              body: [
                {
                  call: {
                    arguments: [[{ variable: "user" }]],
                    name: "update"
                  }
                }
              ]
            },
            name: "each"
          }
        }
      ]
    ],
    [
      "render(a, *b, **c, &d)",
      [
        {
          call: {
            arguments: [
              [{ variable: "a" }],
              [{ variable: { name: "b", splat: :regular } }],
              [{ variable: { name: "c", splat: :keyword } }],
              [{ variable: { block: true, name: "d" } }]
            ],
            name: "render"
          }
        }
      ]
    ],
    [
      "render(a) do end",
      [
        {
          call: {
            arguments: [[{ variable: "a" }]],
            block: {
              body: []
            },
            name: "render"
          }
        }
      ]
    ],
    [
      "render(a) {}",
      [
        {
          call: {
            arguments: [[{ variable: "a" }]],
            block: {
              body: []
            },
            name: "render"
          }
        }
      ]
    ],
    [
      "render(a){}",
      [
        {
          call: {
            arguments: [[{ variable: "a" }]],
            block: {
              body: []
            },
            name: "render"
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
