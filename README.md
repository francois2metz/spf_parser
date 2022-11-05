# SpfParser

Parse the Sender Policy Framework (SPF) as defined in the [RFC 7208][].

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `spf_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spf_parser, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/spf_parser>.

## Usage

```elixir
SpfParser.parse!("v=spf1 include:spf.example.net")
```

[RFC 7208]: https://www.rfc-editor.org/rfc/rfc7208
