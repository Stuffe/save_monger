import ../common

func get_point(bytes: seq[uint8], i: var int): Point =
  return Point(
    x: get_i8(bytes, i).int16, 
    y: get_i8(bytes, i).int16
  )

func get_seq_point(bytes: seq[uint8], i: var int): seq[Point] =
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

proc get_component(bytes: seq[uint8], i: var int): Component =
  var kind = ComponentKind(get_u16(bytes, i).int)
  let position = get_point(bytes, i)
  let rotation = get_u8(bytes, i)
  let permanent_id = id(get_u32(bytes, i).int)
  let custom_string = get_string(bytes, i)
  var custom_id: int
  if kind == com_custom:
    custom_id = get_int(bytes, i)

  return Component(kind: kind, position: position, rotation: rotation, custom_string: custom_string, custom_id: custom_id, permanent_id: permanent_id)

proc get_components(bytes: seq[uint8], i: var int): seq[Component] =
  let len = get_int(bytes, i)
  for j in 0..len - 1:
    let comp = get_component(bytes, i)
    if comp.kind == com_none: continue
    result.add(comp)

func get_wire(bytes: seq[uint8], i: var int): Wire =
  discard get_u32(bytes, i).int # Used to be permanent id
  discard get_u8(bytes, i)
  result.color = get_u8(bytes, i)
  result.comment = get_string(bytes, i)
  result.path = point_list_to_path(get_seq_point(bytes, i))

func get_wires(bytes: seq[uint8], i: var int): seq[Wire] =
  let len = get_int(bytes, i)
  for j in 0..len - 1:
    result.add(get_wire(bytes, i))

proc parse*(bytes: seq[uint8], headers_only: bool, solution: bool, parse_result: var ParseResult) =
  var i = 1 # 0th byte is version

  parse_result.custom_id = get_int(bytes, i)
  parse_result.gate = get_u32(bytes, i).int
  parse_result.delay = get_u32(bytes, i).int
  parse_result.menu_visible = get_bool(bytes, i)
  parse_result.clock_speed = get_u32(bytes, i)
  discard get_u8(bytes, i) # Used to be nesting level
  parse_result.dependencies = get_seq_i64(bytes, i)
  parse_result.description = get_string(bytes, i)

  if not headers_only:
    parse_result.schematic.components = get_components(bytes, i)
    add_wires(parse_result.schematic, get_wires(bytes, i))