import ../common

func get_point(bytes: seq[uint8], i: var int): point =
  return point(
    x: get_i8(bytes, i).int16, 
    y: get_i8(bytes, i).int16
  )

func get_seq_point(bytes: seq[uint8], i: var int): seq[point] =
  let len = get_int(bytes, i)
  for j in 0..len - 1:
    result.add(get_point(bytes, i))

func get_string(bytes: seq[uint8], i: var int): string =
  let len = get_int(bytes, i)
  for j in 0..len - 1:
    result.add(chr(get_u8(bytes, i)))

func get_seq_i64(bytes: seq[uint8], i: var int): seq[int] =
  let len = get_int(bytes, i)
  for j in 0..len - 1:
    result.add(get_int(bytes, i))

func get_component(bytes: seq[uint8], i: var int): parse_component =
  try: # Only fails for obsolete components (deleted enum values)
    result = parse_component(kind: component_kind(get_u16(bytes, i).int))
  except: discard
  result.position = get_point(bytes, i)
  result.rotation = get_u8(bytes, i)
  result.permanent_id = get_u32(bytes, i).int
  result.custom_string = get_string(bytes, i)
  if result.kind in [Program8_1, DELETED_6, DELETED_7, Program8_4, Program]:
    discard get_string(bytes, i)
  elif result.kind == Custom:
    result.custom_id = get_int(bytes, i)
    result.nudge_on_add = point(x: int16.low, y: int16.low)

func get_components(bytes: seq[uint8], i: var int): seq[parse_component] =
  let len = get_int(bytes, i)
  for j in 0..len - 1:
    let comp = get_component(bytes, i)
    if comp.kind in [Error, DELETED_0, DELETED_1, DELETED_2, DELETED_3, DELETED_4, DELETED_5, DELETED_6, DELETED_7]: continue
    result.add(comp)

func get_wire(bytes: seq[uint8], i: var int): parse_wire =
  discard get_u32(bytes, i).int # Used to be permanent id
  result.kind = wire_kind(get_u8(bytes, i))
  result.color = get_u8(bytes, i)
  result.comment = get_string(bytes, i)
  result.path = get_seq_point(bytes, i)

func get_wires(bytes: seq[uint8], i: var int): seq[parse_wire] =
  let len = get_int(bytes, i)
  for j in 0..len - 1:
    result.add(get_wire(bytes, i))

proc parse*(bytes: seq[uint8], meta_only: bool, solution: bool, parse_result: var parse_result) =
  var i = 1 # 0th byte is version

  parse_result.save_version = get_int(bytes, i)
  parse_result.gate = get_u32(bytes, i).int
  parse_result.delay = get_u32(bytes, i).int
  parse_result.menu_visible = get_bool(bytes, i)
  parse_result.clock_speed = get_u32(bytes, i)
  discard get_u8(bytes, i) # Used to be nesting level
  parse_result.dependencies = get_seq_i64(bytes, i)
  parse_result.description = get_string(bytes, i)

  if not meta_only:
    parse_result.components = get_components(bytes, i)
    parse_result.wires = get_wires(bytes, i)