require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    ["a.b", [[{ left: { call: "a" }, right: { call: "b" } }]]],
    [
      "a.b.c",
      [
        [
          { left: { call: "a" }, right: { call: "b" } },
          { right: { call: "c" } }
        ]
      ]
    ],
    [
      "a(1).b.c(2)",
      [
        [
          {
            left: {
              call: {
                arguments: [[{ integer: 1 }]],
                name: "a"
              }
            },
            right: {
              call: "b"
            }
          },
          { right: { call: { arguments: [[{ integer: 2 }]], name: "c" } } }
        ]
      ]
    ],
    [
      "user.first_name",
      [[{ left: { call: "user" }, right: { call: "first_name" } }]]
    ],
    ["User.all", [[{ left: { call: "User" }, right: { call: "all" } }]]],
    [
      "User.each do |user| user.update(created_at: Time.now) end",
      [
        [
          {
            left: {
              call: "User"
            },
            right: {
              call: {
                block_arguments: [[{ call: "user" }]],
                block_body: [
                  [
                    {
                      left: {
                        call: "user"
                      },
                      right: {
                        call: {
                          arguments: [
                            {
                              key: {
                                call: "created_at"
                              },
                              value: [
                                [
                                  {
                                    left: {
                                      call: "Time"
                                    },
                                    right: {
                                      call: "now"
                                    }
                                  }
                                ]
                              ]
                            }
                          ],
                          name: "update"
                        }
                      }
                    }
                  ]
                ],
                name: "each"
              }
            }
          }
        ]
      ]
    ]
  ].each do |input, output|
    context input do
      let!(:input) { input }

      it { expect(subject).to eq(output) }
    end
  end
end
