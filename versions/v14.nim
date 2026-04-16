import ../libraries/supersnappy/supersnappy
import ../common

proc get_component(input: seq[uint8], i: var int, solution = false): Component =
  let idx = get_u16(input, i).int
  var kind = com_none
  if idx <= ComponentKind.high.int:
    kind = ComponentKind(idx)

  var component = Component(kind: kind)
  var buffer_info = BufferInitializeInfo()

  component.position = get_point(input, i)
  component.rotation = get_u8(input, i)
  component.permanent_id = id(get_int(input, i))
  component.custom_string = get_string(input, i)

  let settings_len = get_u16(input, i)
  var j = 0
  while j < settings_len.int:
    component.settings.add(get_u64(input, i))
    j += 1
  buffer_info.size = get_bytes(input, i)
  component.ui_order = get_i16(input, i)
  component.word_size = get_bits(input, i)
  component.is_immutable = get_bool(input, i)
  
  let gate_variant = get_int(input, i)
  let delay_variant = get_int(input, i)
  if gate_variant < 0 and delay_variant < 0:
    component.cost_variant = CostVariant(kind: cvk_min_energy)
  elif gate_variant < 0:
    component.cost_variant = CostVariant(kind: cvk_min_gate)
  elif delay_variant < 0:
    component.cost_variant = CostVariant(kind: cvk_min_delay)
  else:
    component.cost_variant = CostVariant(kind: cvk_explicit, cost: Cost(gate: gate_variant, delay: delay_variant))
  
  buffer_info.is_little_endian = get_bool(input, i)
  buffer_info.init_data = get_init_data(input, i)

  let watched_component_count = get_u16(input, i).int
  var k = 0
  while k < watched_component_count:
    component.linked_components.add(LinkedComponent(
      permanent_id: id(get_int(input, i)),
      inner_id: id(get_int(input, i)),
      name: get_string(input, i),
      offset: get_int(input, i),
      word_size: get_bits(input, i),
    ))
    k += 1

  block:
    let len = get_u16(input, i)
    var j = 0'u16
    while j < len:
      let key = get_string(input, i)
      component.selected_programs[key] = AsmRelativePath(value: get_string(input, i))
      j += 1

  case component.kind:
    of com_custom:
      component.custom_id = get_int(input, i)
      var j = 0'u16
      let static_states_len = get_u16(input, i)
      while j < static_states_len:
        let a = id(get_int(input, i))
        let b = get_bits(input, i)
        component.custom_explicit_word_sizes[a] = b
        j += 1
      j = 0
      
    else: discard

  if component.kind in MIN_ONE_WATCHED_COMPONENT and component.linked_components.len == 0:
    component.linked_components.add(LinkedComponent())

  while component.settings.len < COMPONENT_DEFAULT_SETTING.getOrDefault(component.kind).len:
    component.settings.add(COMPONENT_DEFAULT_SETTING[component.kind][component.settings.len])

  component.buffer_info = buffer_info
  
  return component

proc get_components(input: seq[uint8], i: var int, solution = false): seq[Component] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    let comp = get_component(input, i, solution)
    result.add(comp)

func get_wire(input: seq[uint8], i: var int): Wire =
  result.color = get_u8(input, i)
  result.comment = get_string(input, i)
  
  let start = get_point(input, i)

  var segments: seq[Segment]

  while true:
    let segment = get_u16(input, i)
    let direction = (segment shr 13).uint8
    let length    = segment and 0b00011111_11111111

    if length == 0:
      break

    segments.add(new_segment(
      length.uint16,
      direction,
    ))

  result.path = new_path(start, segments)

func get_wires(input: seq[uint8], i: var int): seq[Wire] =
  let len = get_int(input, i)

  for j in 0..len - 1:
    result.add(get_wire(input, i))

proc parse*(compressed: seq[uint8], headers_only: bool, solution: bool, parse_result: var ParseResult) =
  var bytes = uncompress(compressed[1..^1])
  var i = 0

  parse_result.custom_id = get_int(bytes, i)
  parse_result.hub_id = get_u32(bytes, i)
  parse_result.gate = get_int(bytes, i)
  parse_result.delay = get_int(bytes, i)
  parse_result.menu_visible = get_bool(bytes, i)
  parse_result.clock_speed = get_u64(bytes, i)
  parse_result.dependencies = get_seq_int(bytes, i)
  parse_result.description = get_string(bytes, i)
  parse_result.synced = get_sync_state(bytes, i)
  discard get_u16(bytes, i) # Eventually used for architecture score
  parse_result.player_data = get_seq_u8(bytes, i)
  parse_result.hub_description = get_string(bytes, i)

  if not headers_only:
    if parse_result.custom_id != 0:
      for x in 0 ..< 32:
        for y in 0 ..< 16:
          let design_value = get_u8(bytes, i)
          parse_result.design[x][2 * y] = design_value and 0xF0
          parse_result.design[x][2 * y + 1] = design_value shl 4

    parse_result.schematic.components = get_components(bytes, i, solution)
    add_wires(parse_result.schematic, get_wires(bytes, i))
