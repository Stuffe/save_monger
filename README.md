# Save Monger

This is the production code that is used to load and save game state in [Turing Complete](https://store.steampowered.com/app/1444480/Turing_Complete/).

## Interface

It exposes 3 functions:

### file_get_bytes(orig_file_name: string, alternative_name: string = ""): seq[uint8]

This function takes a file name (and a fallback in case `orig_file_name` does not exist), reads the file and returns its content as an array of bytes.

### parse_state(input: seq[uint8], headers_only = false): ParseResult

You can takes an array of bytes and returns a `ParseResult` struct. Print the struct or check the source code to see which fields it contains.

### state_to_binary(...): seq[uint8]

This will serialize game state to an array of bytes. You will probably want to read the source code for the exact signature.

## License

This code is [CC0](https://creativecommons.org/share-your-work/public-domain/cc0/), however the included library SuperSnappy is MIT license.

## Unofficial Rust port

<https://crates.io/crates/tc_save_monger> (Credit: danielrab)
