import ../libraries/supersnappy/supersnappy
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

func get_component(input: seq[uint8], i: var int, solution = false): parse_component =
  try: # Only fails for obsolete components (deleted enum values)
    var kind = component_kind(get_u16(input, i).int)
    let index = [DELETED_12, DELETED_13, DELETED_14, DELETED_15, DELETED_16].find(kind)
    if index != -1:
      kind = [Bidirectional1, Bidirectional8, Bidirectional16, Bidirectional32, Bidirectional64][index]
    result = parse_component(kind: kind)
  except: discard
  if solution and result.kind == Rom:
    result.kind = SolutionRom
  result.position = get_point(input, i)
  result.rotation = get_u8(input, i)
  result.permanent_id = get_int(input, i)
  result.custom_string = get_string(input, i)
  result.setting_1 = get_u64(input, i)
  result.setting_2 = get_u64(input, i)

  if result.kind == Custom:
    result.custom_id = get_int(input, i)
    result.custom_displacement = get_point(input, i)

  elif result.kind in [Program8_1, Program8_4, Program]:
    let len = get_u16(input, i)
    var j = 0'u16
    while j < len:
      let key = get_int(input, i)
      result.selected_programs[key] = get_string(input, i)
      j += 1

func get_components(input: seq[uint8], i: var int, solution = false): seq[parse_component] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    let comp = get_component(input, i, solution)
    if comp.kind == Error or comp.kind in DELETED_KINDS: continue
    result.add(comp)

func get_wire(input: seq[uint8], i: var int): parse_wire =
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

proc parse*(compressed: seq[uint8], headers_only: bool, solution: bool, parse_result: var parse_result) =
  var bytes = uncompress(compressed[1..^1])
  var i = 0

  parse_result.save_id = get_int(bytes, i)
  parse_result.hub_id = get_u32(bytes, i)
  parse_result.gate = get_int(bytes, i)
  parse_result.delay = get_int(bytes, i)
  parse_result.menu_visible = get_bool(bytes, i)
  parse_result.clock_speed = get_u32(bytes, i)
  parse_result.dependencies = get_seq_int(bytes, i)
  parse_result.description = get_string(bytes, i)
  parse_result.camera_position = get_point(bytes, i)
  parse_result.synced = get_sync_state(bytes, i)
  parse_result.campaign_bound = get_bool(bytes, i)
  discard get_u16(bytes, i) # Eventually used for architecture score
  parse_result.player_data = get_seq_u8(bytes, i)

  if not headers_only:
    parse_result.components = get_components(bytes, i, solution)
    parse_result.wires = get_wires(bytes, i)
