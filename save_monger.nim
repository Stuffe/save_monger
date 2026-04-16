import os, random, sets
import libraries/supersnappy/supersnappy
import common, versions/[v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14]
export common

const LATES_VERSION* = 14'u8

proc file_get_bytes*(orig_file_name: string, alternative_name = ""): seq[uint8] =
  var file_name = orig_file_name
  if not fileExists(file_name):
    if alternative_name != "" and fileExists(alternative_name):
      file_name = alternative_name
    else:
      return

  var file: File

  # Since the game loads files from 2 different threads, we can't assume the file isn't locked (on Windows)
  while not file.open(file_name):
    sleep(1)
  defer:
    file.close()

  let len = getFileSize(file)
  var buffer = newSeq[uint8](len)
  if len == 0:
    return buffer

  discard file.readBytes(buffer, 0, len)
  return buffer

proc parse_state*(
    input: seq[uint8], headers_only = false, solution = false
): ParseResult =
  # Versions modify the result object instead of returning a new one. 
  # This is so that defaults can be set here for values old versions may not contain

  result.gate = 99999
  result.delay = 99999
  result.menu_visible = true

  if input.len != 0:
    result.version = input[0]

    try:
      case result.version:
        of 0: v0.parse(input, headers_only, solution, result)
        of 1: v1.parse(input, headers_only, solution, result)
        of 2: v2.parse(input, headers_only, solution, result)
        of 3: v3.parse(input, headers_only, solution, result)
        of 4: v4.parse(input, headers_only, solution, result)
        of 5: v5.parse(input, headers_only, solution, result)
        of 6: v6.parse(input, headers_only, solution, result)
        of 7: v7.parse(input, headers_only, solution, result)
        of 8: v8.parse(input, headers_only, solution, result)
        of 9: v9.parse(input, headers_only, solution, result)
        of 10: v10.parse(input, headers_only, solution, result)
        of 11: v11.parse(input, headers_only, solution, result)
        of 12: v12.parse(input, headers_only, solution, result)
        of 13: v13.parse(input, headers_only, solution, result)
        of 14: v14.parse(input, headers_only, solution, result)
        else: discard
    except CatchableError, IndexDefect, RangeDefect: discard

  if result.clock_speed == 0:
    result.clock_speed = 10_000_000

  while result.custom_id == 0:
    result.custom_id = rand(int.high)

proc add_component(arr: var seq[uint8], component: Component) =
  arr.add_component_kind(component.kind)
  arr.add_point(component.position)
  arr.add_u8(component.rotation)
  arr.add_int(get_value(component.permanent_id))
  arr.add_string(component.custom_string)
  arr.add_u16(component.settings.len.uint16)
  for setting in component.settings:
    arr.add_u64(setting)
  arr.add_bytes(component.buffer_info.size)
  arr.add_i16(component.ui_order)
  arr.add_bits(component.word_size)
  arr.add_bool(component.is_immutable)

  case component.cost_variant.kind
  of cvk_min_energy:
    arr.add_int(-1)
    arr.add_int(-1)
  of cvk_min_gate:
    arr.add_int(-1)
    arr.add_int(0)
  of cvk_min_delay:
    arr.add_int(0)
    arr.add_int(-1)
  of cvk_explicit:
    arr.add_int(component.cost_variant.cost.gate)
    arr.add_int(component.cost_variant.cost.delay)

  arr.add_bool(component.buffer_info.is_little_endian)
  arr.add_init_data(component.buffer_info.init_data)

  arr.add_u16(component.linked_components.len.uint16)
  for linked_component in component.linked_components:
    arr.add_int(get_value(linked_component.permanent_id))
    arr.add_int(get_value(linked_component.inner_id))
    arr.add_string(linked_component.name)
    arr.add_int(linked_component.offset)
    arr.add_bits(linked_component.word_size)

  arr.add_u16(component.selected_programs.len.uint16)
  for level, program in component.selected_programs:
    arr.add_string(level)
    arr.add_string(program.value)

  case component.kind
  of com_custom:
    arr.add_int(component.custom_id)
    arr.add_u16(component.custom_explicit_word_sizes.len.uint16)
    for a, b in component.custom_explicit_word_sizes:
      arr.add_int(get_value(a))
      arr.add_bits(b)
  else:
    discard

proc add_wire(arr: var seq[uint8], wire: Wire) =
  arr.add_u8(wire.color)
  arr.add_string(wire.comment)
  arr.add_path(wire.path)

proc state_to_binary*(
    custom_id: int,
    schematic: Schematic,
    design: array[32, array[32, uint8]],
    gate: int,
    delay: int,
    menu_visible: bool,
    clock_speed: uint64,
    description: string,
    hub_id: uint32,
    hub_description: string,
    synced = unsynced,
    player_data = newSeq[uint8](),
): seq[uint8] =
  var dependencies: seq[int]

  var new_components: seq[Component]
  var new_wires: seq[Wire]
  var seen_ids: HashSet[PermanentID]

  for component in schematic.components:
    if component.kind == com_custom and component.custom_id notin dependencies:
      dependencies.add(component.custom_id)
    if component.kind in UNUSED_COMPONENTS:
      continue
    if component.permanent_id in seen_ids:
      continue
    seen_ids.incl(component.permanent_id)

    new_components.add(component)

  for _, wire in schematic.wires:
    if is_tombstone(wire): continue
    new_wires.add(wire)

  var res: seq[uint8]
  res.add_int(custom_id)
  res.add_u32(hub_id)
  res.add_int(gate)
  res.add_int(delay)
  res.add_bool(menu_visible)
  res.add_u64(clock_speed)
  res.add_seq_int(dependencies)
  res.add_string(description)
  res.add_sync_state(synced)
  res.add_u16(0'u16) # Eventually used for architecture score
  res.add_seq_u8(player_data)
  res.add_string(hub_description)

  if custom_id != 0:
    for i in 0 ..< 32:
      for j in 0 ..< 16:
        res.add_u8((design[i][2 * j] and 0xF0) or (design[i][2 * j + 1] shr 4))

  res.add_int(new_components.len)
  for component in new_components:
    res.add_component(component)

  res.add_int(new_wires.len)
  for wire in new_wires:
    res.add_wire(wire)

  result = LATES_VERSION & compress(res)
