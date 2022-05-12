import libraries/supersnappy/supersnappy
import common, versions/v49, versions/v0, versions/v1, versions/v2, versions/v3
export common

const FORMAT_VERSION = 3'u8

proc file_get_bytes*(file_name: string): seq[uint8] =
  var file = open(file_name)

  let len = getFileSize(file)
  var buffer = newSeq[uint8](len)
  if len == 0: return buffer
  discard file.readBytes(buffer, 0, len)
  file.close()
  return buffer

proc parse_state*(input: seq[uint8], meta_only = false, solution = false): parse_result =
  
  # Versions modify the result object instead of returning a new one. 
  # This is so that defaults can be set here for values old versions may not parse

  result.gate = 99999
  result.delay = 99999
  result.clock_speed = 100000.uint32
  result.menu_visible = true

  if input.len == 0: return

  var version = input[0]

  case version:
    of 49: v49.parse(input, meta_only, solution, result) # This is an ancient ascii version, where 49 meant "1"
    of 0:  v0.parse(input, meta_only, solution, result)
    of 1:  v1.parse(input, meta_only, solution, result)
    of 2:  v2.parse(input, meta_only, solution, result)
    of 3:  v3.parse(input, meta_only, solution, result)
    else: discard

proc add_component(arr: var seq[uint8], component: parse_component) =
  arr.add_component_kind(component.kind)
  arr.add_point(component.position)
  arr.add_u8(component.rotation)
  arr.add_int(component.permanent_id)
  arr.add_string(component.custom_string)
  arr.add_u64(component.setting_1)
  arr.add_u64(component.setting_2)
  if component.kind == Custom:
    arr.add_int(component.custom_id)
    arr.add_point(component.nudge_on_add)
  elif component.kind in [Program8_1, Program8_4, ProgramWord]:
    arr.add_u16(component.selected_programs.len.uint16)
    for level, program in component.selected_programs:
      arr.add_int(level)
      arr.add_string(program)

proc add_wire(arr: var seq[uint8], wire: parse_wire) =
  arr.add_wire_kind(wire.kind)
  arr.add_u8(wire.color)
  arr.add_string(wire.comment)
  arr.add_path(wire.path)

proc state_to_binary*(save_version: int, 
                      components: seq[parse_component], 
                      wires: seq[parse_wire], 
                      gate: int, 
                      delay: int, 
                      menu_visible: bool, 
                      clock_speed: uint32, 
                      description: string, 
                      camera_position: point,
                      player_data = newSeq[uint8]()): seq[uint8] =

  var dependencies: seq[int]
  var components_to_save: seq[int]

  for id, component in components:
    if component.kind == Custom and component.custom_id notin dependencies:
      dependencies.add(component.custom_id)
    if component.kind in VIRTUAL_KINDS: continue
    if component.kind == WireCluster: continue
    components_to_save.add(id)

  result.add_int(save_version)
  result.add_int(gate)
  result.add_int(delay)
  result.add_bool(menu_visible)
  result.add_u32(clock_speed)
  result.add_seq_int(dependencies)
  result.add_string(description)
  result.add_point(camera_position)
  result.add_bool(false) # Eventually architecture score data
  result.add_seq_uint8(newSeq[uint8]()) # Eventually image data
  result.add_seq_uint8(player_data)

  result.add_int(components_to_save.len)
  for id in components_to_save:
    result.add_component(components[id])

  result.add_int(wires.len)
  for id, wire in wires:
    result.add_wire(wire)

  return FORMAT_VERSION & compress(result)
