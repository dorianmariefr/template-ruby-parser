require "spec_helper"

RSpec.describe ::Code::Parser do
  subject { ::Code::Parser.parse(input) }

  [
    [
      "a.b",
      [{ chained_call: [{ left: { call: "a" }, right: { call: "b" } }] }]
    ],
    [
      "a.b.c",
      [
        {
          chained_call: [
            { left: { call: "a" }, right: { call: "b" } },
            { right: { call: "c" } }
          ]
        }
      ]
    ],
    [
      "a(1).b.c(2)",
      [
        {
          chained_call: [
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
        }
      ]
    ],
    [
      "user.first_name",
      [
        {
          chained_call: [
            { left: { call: "user" }, right: { call: "first_name" } }
          ]
        }
      ]
    ],
    [
      "User.all",
      [{ chained_call: [{ left: { call: "User" }, right: { call: "all" } }] }]
    ],
    [
      "User.each do |user| user.update(created_at: Time.now) end",
      [
        {
          chained_call: [
            {
              left: {
                call: "User"
              },
              right: {
                call: {
                  block_body: [
                    {
                      chained_call: [
                        {
                          left: {
                            call: "user"
                          },
                          right: {
                            call: {
                              arguments: [
                                {
                                  default: [
                                    {
                                      chained_call: [
                                        {
                                          left: {
                                            call: "Time"
                                          },
                                          right: {
                                            call: "now"
                                          }
                                        }
                                      ]
                                    }
                                  ],
                                  keyword: true,
                                  statement: {
                                    call: "created_at"
                                  }
                                }
                              ],
                              name: "update"
                            }
                          }
                        }
                      ]
                    }
                  ],
                  block_parameters: [{ name: "user" }],
                  name: "each"
                }
              }
            }
          ]
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
