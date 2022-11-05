defmodule SpfParser do
  use AbnfParsec,
    abnf: """
    record           = version directives *sp
    version          = "v=spf1"
    directives       = *( 1*sp ( directive ) )
    directive        = [ qualifier ] mechanism
    qualifier        = ( "+" / "-" / "?" / "~" )
    mechanism        = ( all / include / a / mx / ptr / ip4 / ip6 / exists )
    all              = "all"
    include          = "include"  ":" domain-spec
    a                = "a" [ ":" domain-spec ]
    mx               = "mx" [ ":" domain-spec ]
    ptr              = "ptr" [ ":" domain-spec ]
    ip4              = "ip4" ":" ip4-network [ ip4-cidr-length ]
    ip6              = "ip6" ":" ip6-network [ ip6-cidr-length ]
    exists           = "exists"   ":" domain-spec

    ip4-cidr-length  = slash ("0" / %x31-39 0*1DIGIT) ; value range 0-32
    ip6-cidr-length  = slash ("0" / %x31-39 0*2DIGIT) ; value range 0-128
    slash            = "/"

    ip4-network      = qnum "." qnum "." qnum "." qnum
    qnum =
           "25" %x30-35      /   ; 250-255
           "2" %x30-34 DIGIT /   ; 200-249
           "1" 2DIGIT        /   ; 100-199
           %x31-39 DIGIT     /   ; 10-99
           DIGIT                 ; 0-9

    ip6-network      =                          6( h16 ":" ) ls32
                   /                       "::" 5( h16 ":" ) ls32
                   / [               h16 ] "::" 4( h16 ":" ) ls32
                   / [ *1( h16 ":" ) h16 ] "::" 3( h16 ":" ) ls32
                   / [ *2( h16 ":" ) h16 ] "::" 2( h16 ":" ) ls32
                   / [ *3( h16 ":" ) h16 ] "::"    h16 ":"   ls32
                   / [ *4( h16 ":" ) h16 ] "::"              ls32
                   / [ *5( h16 ":" ) h16 ] "::"              h16
                   / [ *6( h16 ":" ) h16 ] "::"

    h16              = 1*4HEXDIG
    ls32             = ( h16 ":" h16 ) / ip4-network

    domain-spec      = macro-string / domain-end
    domain-end       = ( "." toplabel [ "." ] ) / macro-expand

    toplabel         = ( *alphanum ALPHA *alphanum ) /( 1*alphanum "-" *( alphanum / "-" ) alphanum )

    macro-string     = *( macro-expand / macro-literal )
    macro-expand     = ( "%{" macro-letter transformers *delimiter "}" ) / "%%" / "%_" / "%-"

    macro-literal    = %x21-24 / %x26-7E ; visible characters except "%"
    macro-letter     = "s" / "l" / "o" / "d" / "i" / "p" / "h" / "c" / "r" / "t" / "v"
    transformers     = *DIGIT [ "r" ]
    delimiter        = "." / "-" / "+" / "," / "/" / "_" / "="

    alphanum         = ( ALPHA / DIGIT )
    sp               = SP
    """,
    transform: %{
      "transformers" => {:reduce, {List, :to_string, []}},
      "ip4-network" => {:reduce, {List, :to_string, []}},
      "ip6-network" => {:reduce, {List, :to_string, []}},
      "ip4-cidr-length" => {:reduce, {List, :to_string, []}},
      "ip6-cidr-length" => {:reduce, {List, :to_string, []}},
      "macro-string" => {:post_traverse, {:clean_macro_string, []}}
    },
    untag: ["directive"],
    unwrap: ["qualifier", "macro-letter", "transformers", "ip4-cidr-length", "ip6-cidr-length"],
    unbox: [
      "alphanum",
      "domain-spec",
      "record",
      "ip4-network",
      "ip6-network",
      "qnum",
      "h16",
      "ls32",
      "all",
      "include",
      "a",
      "mx",
      "ptr",
      "ip4",
      "ip6",
      "exists"
    ],
    ignore: ["sp", "slash"],
    skip: [],
    parse: :record

  defp clean_macro_string(rest, macro, context, _line, _offset) do
    add_rest_macro_literal = fn literal, list ->
      case literal do
        "" -> list
        x -> [{:macro_literal, x} | list]
      end
    end

    result =
      Enum.reduce(macro, %{list: [], literal: ""}, fn entry, acc ->
        %{list: list, literal: literal} = acc

        case entry do
          {:macro_literal, x} ->
            %{list: list, literal: List.to_string(x) <> literal}

          a ->
            %{list: [a | add_rest_macro_literal.(literal, list)], literal: ""}
        end
      end)

    {rest, Enum.reverse(add_rest_macro_literal.(result[:literal], result[:list])), context}
  end
end
