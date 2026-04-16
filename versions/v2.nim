import random
import ../libraries/supersnappy/supersnappy
import ../common

const TELEPORT_WIRE = 0b0010_0000'u8
const DIRECTIONS = [
  Point(x: 1, y: 0),
  Point(x: 1, y: 1),
  Point(x: 0, y: 1),
  Point(x: -1, y: 1),
  Point(x: -1, y: 0),
  Point(x: -1, y: -1),
  Point(x: 0, y: -1),
  Point(x: 1, y: -1),
]

proc get_component(input: seq[uint8], i: var int, solution = false): Component =
  let kind = ComponentKind(get_u16(input, i).int)

  var position = get_point(input, i)
  let rotation = get_u8(input, i)
  let permanent_id = id(get_int(input, i))
  let custom_string = get_string(input, i)
  var settings = @[get_u64(input, i)]
  settings.add(get_u64(input, i))
  var custom_id: int

  if kind == com_custom:
    custom_id = get_int(input, i)
    position = result.position + get_point(input, i)

  return Component(kind: kind, position: position, rotation: rotation, custom_string: custom_string, custom_id: custom_id, permanent_id: permanent_id)

proc get_components(input: seq[uint8], i: var int, solution = false): seq[Component] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    let comp = get_component(input, i, solution)
    if comp.kind == com_none: continue
    result.add(comp)

func get_wire(input: seq[uint8], i: var int): Wire =
  discard get_u8(input, i)
  result.color = get_u8(input, i)
  result.comment = get_string(input, i)
  
  #[
    Wire paths encoding rules:
    1. The wire starts with a point: (x: int16, y: int16). 
    2. After this follow 1 or more segments (3 bit direction, 5 bit length)
    3. We end once a 0 length segment is encountered (0 byte)
  ]#

  var path: seq[Point]
  path.add(get_point(input, i))

  defer: 
    result.path = point_list_to_path(path)

  var segment = get_u8(input, i)

  # This is a special case to support players who want to generate disconnected wires
  if segment == TELEPORT_WIRE:
    path.add(get_point(input, i))
    return

  var length_left = (segment and 0b0001_1111).int
  while length_left != 0:
    let direction = DIRECTIONS[segment shr 5]

    while length_left > 0:
      path.add(path[^1] + direction)
      length_left -= 1

    segment = get_u8(input, i)
    length_left = (segment and 0b0001_1111).int



func get_wires(input: seq[uint8], i: var int): seq[Wire] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    result.add(get_wire(input, i))

proc parse*(compressed: seq[uint8], headers_only: bool, solution: bool, parse_result: var ParseResult) =
  var bytes = uncompress(compressed[1..^1])
  var i = 0

  parse_result.custom_id = rand(int.high) # This version was live for 2 hours only, because this field was missing, which causes custom components to crash
  parse_result.gate = get_int(bytes, i)
  parse_result.delay = get_int(bytes, i)
  parse_result.menu_visible = get_bool(bytes, i)
  parse_result.clock_speed = get_u32(bytes, i)
  parse_result.dependencies = get_seq_int(bytes, i)
  parse_result.description = get_string(bytes, i)
  discard get_point(bytes, i)
  discard get_bool(bytes, i)
  discard get_seq_u8(bytes, i)
  parse_result.player_data = get_seq_u8(bytes, i)

  if not headers_only:
    parse_result.schematic.components = get_components(bytes, i, solution)
    add_wires(parse_result.schematic, get_wires(bytes, i))