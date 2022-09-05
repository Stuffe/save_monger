# Save Monger
This is the production code that is used to load and save game state in for [Turing Complete](https://store.steampowered.com/app/1444480/Turing_Complete/).

It exposes 3 functions: 

### file_get_bytes(filepath: string): seq[uint8]

This function takes a file name, reads the file and returns its content as an array of bytes.

### parse_state(input: seq[uint8], headers_only = false): parse_result

You can takes an array of bytes and returns a "parse result" struct. Print the struct or check the source code to see which fields it contains.

### state_to_binary(save_id: int, components: seq[parse_component], wires: seq[parse_wire], ...): seq[uint8]

This will serialize game state to an array of bytes. You will probably want to read the source code for the exact definitions of the component and wire structs.

# License
This code is [CC0](https://creativecommons.org/share-your-work/public-domain/cc0/), however the included library SuperSnappy is MIT license.

# Unofficial Rust port
https://crates.io/crates/tc_save_monger (Credit: danielrab)
