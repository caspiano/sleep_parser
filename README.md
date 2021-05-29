# SLEEP Parser

Read and write SLEEP protocol headers in crystal lang.

Inspiration taken from [datrs' SLEEP parser](https://github.com/datrs/sleep-parser)

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
    sleep_parser:
    github: caspiano/sleep_parser
```

2. Run `shards install`

## Usage

```crystal
require "sleep_parser"

header = SleepParser::Header.from_io(some_io)
```

## Contributors

- [Caspian Baska](https://github.com/caspiano) - creator and maintainer
