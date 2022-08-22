# save_monger
This is the production code that is used to load and save game state in for [Turing Complete](https://store.steampowered.com/app/1444480/Turing_Complete/).

It exposes 3 functions: 

### file_get_bytes(filepath: string): seq[uint8]

This function takes a file name, reads the file and returns its content as an array of bytes.

### proc parse_state(input: seq[uint8], headers_only = false): parse_result

You can takes an array of bytes and returns a "parse result" struct. Print the struct or check the source code to see which fields it contains.

### proc state_to_binary(save_id: int, components: seq[parse_component], wires: seq[parse_wire], gate: int, delay: int, menu_visible: bool, clock_speed: uint32, description: string, camera_position: point, hub_id: uint32, hub_description: string, synced = unsynced, campaign_bound = false, player_data = newSeq[uint8]): seq[uint8]

This will serialize game state to an array of bytes. You will probably want to read the source code for the exact definitions of the component and wire structs.

# License
This code is [CC0](https://creativecommons.org/share-your-work/public-domain/cc0/), however the included library SuperSnappy is MIT license.

# Rust version
Thanks to danielrab for porting this to rust: https://crates.io/crates/tc_save_monger
