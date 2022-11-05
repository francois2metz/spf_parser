# SpfParser

Parse the Sender Policy Framework (SPF) as defined in the [RFC 7208][].

## Installation

The package can be installed by adding `spf_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spf_parser, "~> 0.1.0"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/spf_parser>.

## Usage

```elixir
SpfParser.parse!("v=spf1 include:spf.example.net")
```

[RFC 7208]: https://www.rfc-editor.org/rfc/rfc7208
