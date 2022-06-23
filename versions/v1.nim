import ../common

const TELEPORT_WIRE = 0b0010_0000'u8
const DIRECTIONS = [
  point(x: 1, y: 0),
  point(x: 1, y: 1),
  point(x: 0, y: 1),
  point(x: -1, y: 1),
  point(x: -1, y: 0),
  point(x: -1, y: -1),
  point(x: 0, y: -1),
  point(x: 1, y: -1),
]

func get_seq_i64(input: seq[uint8], i: var int): seq[int] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    result.add(get_int(input, i))

func get_string(input: seq[uint8], i: var int): string =
  let len = get_int(input, i)
  for j in 0..len - 1:
    result.add(chr(get_u8(input, i)))

func get_point(input: seq[uint8], i: var int): point =
  return point(
    x: get_i16(input, i), 
    y: get_i16(input, i)
  )

func get_component(input: seq[uint8], i: var int, solution = false): parse_component =
  try: # Only fails for obsolete components (deleted enum values)
    result = parse_component(kind: component_kind(get_u16(input, i).int))
  except: discard
  if solution and result.kind == Rom:
    result.kind = SolutionRom
  result.position = get_point(input, i)
  result.rotation = get_u8(input, i)
  result.permanent_id = get_int(input, i)
  result.custom_string = get_string(input, i)
  if result.kind in [Program8_1, DELETED_6, DELETED_7, Program8_4, Program]:
    discard get_string(input, i)
  elif result.kind == Custom:
    result.custom_id = get_int(input, i)
    result.nudge_on_add = point(x: int16.low, y: int16.low)

func get_components(input: seq[uint8], i: var int, solution = false): seq[parse_component] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    let comp = get_component(input, i, solution)
    if comp.kind == Error or comp.kind in DELETED_KINDS: continue
    result.add(comp)

func get_wire(input: seq[uint8], i: var int): parse_wire =
  discard get_int(input, i) # used to be permanent_id
  result.kind = wire_kind(get_u8(input, i))
  result.color = get_u8(input, i)
  result.comment = get_string(input, i)
  
  #[
    Wire paths encoding rules:
    1. The wire starts with a point: (x: int16, y: int16). 
    2. After this follow 1 or more segments (3 bit direction, 5 bit length)
    3. We end once a 0 length segment is encountered (0 byte)
  ]#

  result.path.add(get_point(input, i))

  var segment = get_u8(input, i)

  # This is a special case to support players who want to generate disconnected wires
  if segment == TELEPORT_WIRE:
    result.path.add(get_point(input, i))
    return

  var length_left = (segment and 0b0001_1111).int
  while length_left != 0:
    let direction = DIRECTIONS[segment shr 5]

    while length_left > 0:
      result.path.add(result.path[^1] + direction)
      length_left -= 1

    segment = get_u8(input, i)
    length_left = (segment and 0b0001_1111).int

func get_wires(input: seq[uint8], i: var int): seq[parse_wire] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    result.add(get_wire(input, i))

proc parse*(bytes: seq[uint8], meta_only: bool, solution: bool, parse_result: var parse_result) =
  var i = 1 # 0th byte is version

  parse_result.save_id = get_int(bytes, i)
  parse_result.gate = get_u32(bytes, i).int
  parse_result.delay = get_u32(bytes, i).int
  parse_result.menu_visible = get_bool(bytes, i)
  parse_result.clock_speed = get_u32(bytes, i)
  discard get_u8(bytes, i) # Used to be nesting level
  parse_result.dependencies = get_seq_i64(bytes, i)
  parse_result.description = get_string(bytes, i)
  discard get_bool(bytes, i)
  parse_result.camera_position = get_point(bytes, i)
  discard get_bool(bytes, i)

  if not meta_only:
    parse_result.components = get_components(bytes, i, solution)
    parse_result.wires = get_wires(bytes, i)