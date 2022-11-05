defmodule SpfParserTest do
  use ExUnit.Case, async: true

  @spf [
    {
      "v=spf1 ~all",
      [
        version: ["v=spf1"],
        directives: [
          [qualifier: "~", mechanism: ["all"]]
        ]
      ]
    },
    {
      "v=spf1 include:spf.example.net",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["include", ":", {:macro_string, [{:macro_literal, "spf.example.net"}]}]]
        ]
      ]
    },
    {
      "v=spf1 include:spf.example.net -all",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["include", ":", {:macro_string, [{:macro_literal, "spf.example.net"}]}]],
          [qualifier: "-", mechanism: ["all"]]
        ]
      ]
    },
    {
      "v=spf1 include:%{d}.example.net",
      [
        version: ["v=spf1"],
        directives: [
          [
            mechanism: [
              "include",
              ":",
              {:macro_string,
               [
                 {:macro_expand, ["%{", {:macro_letter, "d"}, {:transformers, ""}, "}"]},
                 {:macro_literal, ".example.net"}
               ]}
            ]
          ]
        ]
      ]
    },
    {
      "v=spf1 a",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["a"]]
        ]
      ]
    },
    {
      "v=spf1 a:example.org",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["a", ":", {:macro_string, [macro_literal: "example.org"]}]]
        ]
      ]
    },
    {
      "v=spf1 a:example.org/28",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["a", ":", {:macro_string, [macro_literal: "example.org/28"]}]]
        ]
      ]
    },
    {
      "v=spf1 mx",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["mx"]]
        ]
      ]
    },
    {
      "v=spf1 ptr",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["ptr"]]
        ]
      ]
    },
    {
      "v=spf1 ip4:192.0.2.1",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["ip4", ":", "192.0.2.1"]]
        ]
      ]
    },
    {
      "v=spf1 ip4:192.0.2.1/28",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["ip4", ":", "192.0.2.1", {:ip4_cidr_length, "28"}]]
        ]
      ]
    },
    {
      "v=spf1 ip6:2001:0000:0000:0000:0000:0000:0000:0000",
      [
        version: ["v=spf1"],
        directives: [
          [mechanism: ["ip6", ":", "2001:0000:0000:0000:0000:0000:0000:0000"]]
        ]
      ]
    },
    {
      "v=spf1 ip6:2001:0000:0000:0000:0000:0000:0000:0000/123",
      [
        version: ["v=spf1"],
        directives: [
          [
            mechanism: [
              "ip6",
              ":",
              "2001:0000:0000:0000:0000:0000:0000:0000",
              {:ip6_cidr_length, "123"}
            ]
          ]
        ]
      ]
    },
    {
      "v=spf1 exists:%{i2r}.sbl.example.net",
      [
        version: ["v=spf1"],
        directives: [
          [
            mechanism: [
              "exists",
              ":",
              {:macro_string,
               [
                 {:macro_expand, ["%{", {:macro_letter, "i"}, {:transformers, "2r"}, "}"]},
                 {:macro_literal, ".sbl.example.net"}
               ]}
            ]
          ]
        ]
      ]
    }
  ]

  for {spf, expected} <- @spf do
    test "path spf rule '#{spf}'" do
      assert unquote(expected) == SpfParser.parse!(unquote(spf))
    end
  end
end
