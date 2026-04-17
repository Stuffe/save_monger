import tables, random
export tables

const MAX_BITWIDTH* = 64'u8

type ComponentKind* = enum
  com_none = 0
  com_off = 1
  com_on = 2
  com_not_bit = 3
  com_and_bit = 4
  com_and_3_bit = 5
  com_nand_bit = 6
  com_or_bit = 7
  com_or_3_bit = 8
  com_nor_bit = 9
  com_xor_bit = 10
  com_xnor_bit = 11
  com_switch_bit = 12
  com_delay_line_bit = 13
  com_register_bit = 14
  com_full_adder = 15
  com_maker_bit_8 = 16
  com_splitter_bit_8 = 17
  com_not_word = 18
  com_or_word = 19
  com_and_word = 20
  com_nand_word = 21
  com_nor_word = 22
  com_xor_word = 23
  com_xnor_word = 24
  com_switch_word = 25
  com_equal = 26
  com_less_u = 27
  com_less_s = 28
  com_neg = 29
  com_add = 30
  com_mul = 31
  com_div = 32
  com_lsl = 33
  com_lsr = 34
  com_rol = 35
  com_ror = 36
  com_asr = 37
  com_counter = 38
  com_register_word = 39
  com_level_output_8_pin = 40
  com_deleted_5 = 41
  com_mux = 42
  com_decoder_1 = 43
  com_decoder_2 = 44
  com_decoder_3 = 45
  com_constant = 46
  com_splitter_word_2 = 47
  com_maker_word_2 = 48
  com_clz = 49
  com_register_word_config = 50
  com_delay_line_word_asm = 51
  com_deleted_6 = 52
  com_deleted_4 = 53
  com_load_port = 54
  com_delay_line_word = 55
  com_store_port = 56
  com_ctz = 57
  com_cc_level_output = 58
  com_level_gate = 59
  com_level_input_1_pin = 60
  com_level_input_word = 61
  com_level_input_switched = 62
  com_level_input_2_pin = 63
  com_level_input_3_pin = 64
  com_level_input_4_pin = 65
  com_deleted_16 = 66
  com_deleted_17 = 67
  com_level_output_1_pin = 68
  com_level_output_word = 69
  com_level_output_switched = 70
  com_deleted_2 = 71
  com_deleted_3 = 72
  com_level_output_2_pin = 73
  com_level_output_3_pin = 74
  com_level_output_4_pin = 75
  com_deleted_18 = 76
  com_level_output_counter = 77
  com_custom = 78
  com_cc_input = 79
  com_cc_input_buffer = 80
  com_cc_output = 81
  com_probe_memory_bit = 82
  com_probe_memory_word = 83
  com_probe_wire_bit = 84
  com_probe_wire_word = 85
  com_config_delay = 86
  com_halt = 87
  com_deleted_1 = 88
  com_segment_display = 89
  com_static_value = 90
  com_screen = 91
  com_time = 92
  com_keyboard = 93
  com_static_eval = 94
  com_verilog_input = 95
  com_verilog_output = 96
  com_maker_word_4 = 97
  com_maker_word_8 = 98
  com_splitter_word_4 = 99
  com_splitter_word_8 = 100
  com_static_indexer = 101
  com_deleted_7 = 102
  com_deleted_8 = 103
  com_inc = 104
  com_deleted_19 = 105
  com_cc_level_input = 106
  com_deleted_9 = 107
  com_mod = 108
  com_splitter_bit_2 = 109
  com_splitter_bit_4 = 110
  com_maker_bit_2 = 111
  com_maker_bit_4 = 112
  com_deleted_10 = 113
  com_concatenator_2 = 114
  com_concatenator_4 = 115
  com_concatenator_8 = 116
  com_static_indexer_config = 117
  com_ram = 118
  com_delay_line_word_config = 119
  com_deleted_11 = 120
  com_deleted_12 = 121
  com_deleted_13 = 122
  com_deleted_14 = 123
  com_deleted_15 = 124

const UNUSED_COMPONENTS* = {
  com_none, com_deleted_1, com_deleted_2, com_deleted_3, com_deleted_4, com_deleted_5,
  com_deleted_6, com_deleted_7, com_deleted_8, com_deleted_9, com_deleted_10,
  com_deleted_11, com_deleted_12, com_deleted_13, com_deleted_14, com_deleted_15,
  com_deleted_16, com_deleted_17, com_deleted_18, com_deleted_19,
}
const ARCHITECTURE_KINDS* = {com_level_input_switched, com_level_output_switched}
const WATCHABLE_KINDS* = {
  com_level_input_word, com_level_input_switched, com_level_output_word,
  com_level_output_switched, com_level_output_counter, com_cc_input, com_cc_output,
  com_cc_level_input, com_cc_level_output, com_probe_wire_word, com_probe_memory_word,
  com_probe_wire_bit, com_probe_memory_bit, com_counter, com_register_word,
  com_register_word_config, com_delay_line_bit, com_delay_line_word,
  com_delay_line_word_asm, com_delay_line_word_config, com_register_bit,
  com_ram,
}
const VISUAL_VALUE_KINDS* = {
  com_level_input_word, com_level_input_switched, com_level_output_word,
  com_level_output_switched, com_level_output_counter, com_cc_input, com_cc_output,
  com_cc_level_input, com_cc_level_output, com_probe_wire_word, com_probe_memory_word,
  com_probe_wire_bit, com_probe_memory_bit, com_counter, com_register_word,
  com_register_word_config, com_delay_line_bit, com_delay_line_word,
  com_delay_line_word_asm, com_delay_line_word_config, com_register_bit, com_constant,
  com_static_value, com_static_indexer, com_static_indexer_config,
}
const LEVEL_INPUTS* = {
  com_level_input_1_pin, com_level_input_2_pin, com_level_input_3_pin,
  com_level_input_4_pin, com_level_input_word, com_level_input_switched,
}
const LEVEL_OUTPUTS* = {
  com_level_output_1_pin, com_level_output_2_pin, com_level_output_3_pin,
  com_level_output_4_pin, com_level_output_8_pin, com_level_output_word, com_level_output_switched,
  com_level_output_counter,
}
const MIN_ONE_WATCHED_COMPONENT* =
  {com_probe_memory_bit, com_probe_memory_word, com_screen}
const ASSEMBLER_COMPONENTS* = {com_ram}
const ASSEMBLER_MEMORY* = {com_ram}

type Bits* = object
  amount*: int

type Bytes* = object
  amount*: int

proc to_bytes*(input: Bits): Bytes =
  return Bytes(amount: (input.amount + 7) div 8)

proc to_bits*(input: Bytes): Bits =
  return Bits(amount: input.amount * 8)

proc bits*(input: int): Bits =
  return Bits(amount: input)

proc bytes*(input: int): Bytes =
  return Bytes(amount: input)

proc `+`*(a: Bits, b: Bits): Bits =
  return bits(a.amount + b.amount)

proc `+`*(a: Bits, b: int): Bits =
  return bits(a.amount + b)

proc `-`*(a: Bits, b: int): Bits =
  return bits(a.amount - b)

proc `-`*(a: Bits): Bits =
  return bits(- a.amount)

proc `*`*(a: Bits, b: int): Bits =
  return bits(a.amount * b)

proc `div`*(a: Bits, b: int): Bits =
  return bits(a.amount div b)

proc `min`*(a: Bits, b: Bits): Bits =
  return bits(min(a.amount, b.amount))

proc `max`*(a: Bits, b: Bits): Bits =
  return bits(max(a.amount, b.amount))

proc `+`*(a: Bytes, b: int): Bytes =
  return bytes(a.amount + b)

proc `+`*(a: Bytes, b: Bytes): Bytes =
  return bytes(a.amount + b.amount)

proc `-`*(a: Bytes, b: int): Bytes =
  return bytes(a.amount - b)

proc `-`*(a: Bytes, b: Bytes): Bytes =
  return bytes(a.amount - b.amount)

proc `-`*(a: Bytes): Bytes =
  return bytes(- a.amount)

proc `*`*(a: Bytes, b: int): Bytes =
  return bytes(a.amount * b)

proc `min`*(a: Bytes, b: Bytes): Bytes =
  return bytes(min(a.amount, b.amount))

proc `max`*(a: Bytes, b: Bytes): Bytes =
  return bytes(max(a.amount, b.amount))

proc `$`*(input: Bits): string =
  return $input.amount

proc `$`*(input: Bytes): string =
  return $input.amount

const MEMORY_COMPONENTS* = {com_ram: bytes(256)}.toTable
const SETTING_IMMUTABLE_DATA* = 2
const Z_STATE_BYTES* = bytes(1)

const COMPONENT_DEFAULT_SETTING* = {
  com_constant: @[0'u64],
  com_cc_input: @[2'u64],
  com_cc_output: @[0'u64],
  com_config_delay: @[0'u64],
  com_level_gate: @[0'u64],
  com_segment_display: @[0'u64],
  com_keyboard: @[1'u64],
  com_static_indexer: @[0'u64],
  com_ram: @[0'u64, 0'u64, 0'u64],
}.toTable

type Point* = object
  x*: int16
  y*: int16

type Rect* = object
  x*: int16
  y*: int16
  w*: int16
  h*: int16

const DIRECTIONS* = [
  Point(x: 1, y: 0),
  Point(x: 1, y: 1),
  Point(x: 0, y: 1),
  Point(x: -1, y: 1),
  Point(x: -1, y: 0),
  Point(x: -1, y: -1),
  Point(x: 0, y: -1),
  Point(x: 1, y: -1),
]

type PermanentID* = object
  value*: int

type AsmRelativePath* = object
  value*: string

const NO_ID* = PermanentID()

proc id*(value: int): PermanentID =
  return PermanentID(value: value)

func mix*(a: PermanentID, b: PermanentID): PermanentID =
  return PermanentID(value: a.value xor b.value)

func mix*(a: PermanentID, b: PermanentID, c: PermanentID): PermanentID =
  return PermanentID(value: a.value xor b.value xor c.value)

func inverse*(id: PermanentID): PermanentID =
  return id(id.value * -1)

func `$`*(permanent_id: PermanentID): string =
  return $permanent_id.value

proc get_value*(permanent_id: PermanentID): int =
  return permanent_id.value

func new_permanent_id*(): PermanentID =
  {.noSideEffect.}:
    return PermanentID(value: rand(int.high))

func is_valid*(id: PermanentID): bool =
  return id.value != 0

type SyncState* = enum
  unsynced
  synced
  changed_after_sync

type WireRuntimeKind* = enum
  r_normal
  r_short_circuit

type WireCompKind* = enum
  wck_normal
  wck_bus

type SimIndex* = int

type Allocation* = object
  index = 1
  size = Bytes(amount: 256)
  can_be_z = true

const NO_ALLOC* = Allocation()

type LinkedComponent* = object
  permanent_id*: PermanentID
  inner_id*: PermanentID
  name*: string
  offset*: int # For RAM etc
  word_size*: Bits

type LinkedIndex* = object
  name*: string
  pointer*: int
  word_size*: Bits

  sim_address*: string
  component_id*: int

  # Used for custom panels
  position*: Point
  custom_is_bit*: bool
  custom_permanent_id*: PermanentID

type ValueStructure* = object
  kind*: WireCompKind
  index*: Allocation
  replay_index*: Allocation
    # For simulation purposes, an output pin and a wire can share one state. We do need to distinguish this visually though # ALSO We need to be able to rerun simulations using previous memory outputs
  word_size*: Bits
  input_count*: int16
  output_index*: uint16
  any_top_level_wire_id*: int

type PortData* = object
  component_id*: int
  enable_pointer*: int
  data_pointer*: int
  address_size*: Bits
  port_size*: Bits
  can_enable_be_z*: bool
  is_load*: bool
  critical_path*: bool
  circular_dependency*: bool

type InitialDataKind* = enum
  ini_zeroes
  ini_assembler
  ini_punch_card
  ini_file
  ini_hex_editor

type BufferInitializeInfo* = object
  size*: Bytes
  is_little_endian*: bool
  init_data*: InitialDataKind
  generation*: int

type Buffer* = object
  size*: Bytes
  is_little_endian*: bool
  data*: int
  reset_data*: int
  settings*: int
  init_data*: InitialDataKind
  generation*: int

type Cost* = object
  gate*: int
  delay*: int

type Score* = object
  gate*: int
  delay*: int
  tick*: int

type CostVariantKind* = enum
  cvk_min_gate
  cvk_min_energy
  cvk_min_delay
  cvk_explicit

type CostVariant* = object
  case kind*: CostVariantKind
  of cvk_explicit:
    cost*: Cost
  else:
    discard

type Component* = object
  kind*: ComponentKind
  position*: Point
  rotation*: uint8
  permanent_id*: PermanentID
  parent_permanent_id*: PermanentID
  top_level_permanent_id*: PermanentID
  is_late_version*: bool
  other_version*: int
  inputs*: seq[ValueStructure]
  outputs*: seq[ValueStructure]
  memory*: ValueStructure
  global_input_start*: uint16
  settings*: seq[uint64]
  ui_order*: int16
  custom_string*: string
  word_size*: Bits
  computed_word_size*: Bits
  linked_components*: seq[LinkedComponent]
  linked_indexes*: seq[LinkedIndex]
  is_overlap_ghost*: bool
  first_read_port*: int
  
  calculated_gate*: int
  calculated_delay*: int
  parent_ram_id*: int

  cc_input_custom_delay*: int

  buffer*: Buffer
  buffer_info*: BufferInitializeInfo

  # Custom component
  custom_id*: int
  custom_explicit_word_sizes*: Table[PermanentID, Bits]

  # Ram
  selected_programs*: Table[string, AsmRelativePath]
  connected_port_data*: seq[PortData]
  port_index_on_ram*: int

  is_immutable*: bool
  cost_variant*: CostVariant

  # Render cache
  draw_index*: uint32
  draw_index_static_value*: uint32
  draw_index_segment_display*: uint32
  draw_index_bit_watchee*: uint32
  draw_index_word_watchee*: uint32
  draw_index_byte_port_color*: uint32
  draw_index_screen*: uint32
  draw_index_comment*: uint32
  draw_index_button*: uint32
  draw_mode_button*: uint8

type Segment* = object
  direction: uint8
  length: uint16

type Path* = object
  start: Point
  finish: Point # Cached
  segments*: seq[Segment]

type WireID* = object
  wid*: int

const INVALID_WIRE_ID* = WireID(wid: -1)
const INVALID_PATH*    = Path(start: Point(x: int16.low))

type Wire* = object
  comp_kind*: WireCompKind
  runtime_kind*: WireRuntimeKind
  color*: uint8
  comment*: string
  path*: Path
  word_size*: Bits
  value_index*: Allocation
  delay*: int
  circular_dependency*: bool
  critical_path*: bool
  reverse_flow*: bool

type Schematic* = object
  components*: seq[Component]
    # Needs deterministic ordering for global input / outputs. Tombstones are used to achieve persistent IDs. OrderedTable turned out to be a major hassle, especially in 'prepare'
  component_buffer_references*: seq[seq[uint8]]
    # Component buffers are allocated as seqs and collected by nim when this is no longer used
  wires: seq[Wire]
  next_global_input*: uint16
  level_size*: int16
  breakpoint_component_ids*: seq[int]

iterator wires*(schematic: Schematic): (WireID, Wire) =
  for index, wire in schematic.wires:
    yield (WireID(wid: index), wire)

proc wires*(schematic: Schematic): seq[Wire] =
  return schematic.wires

proc get_wire*(schematic: Schematic, wire_id: WireID): Wire =
  return schematic.wires[wire_id.wid]

proc make_tombstone*(schematic: var Schematic, wire_id: WireID) =
  schematic.wires[wire_id.wid].path = Path()

proc set_wire*(schematic: var Schematic, wire_id: WireID, wire: Wire) =
  schematic.wires[wire_id.wid] = wire

proc add_wire*(schematic: var Schematic, wire: Wire): WireID {.discardable.} =
  result = WireID(wid: schematic.wires.len)
  schematic.wires.add(wire)

proc add_wires*(schematic: var Schematic, wires: seq[Wire]) =
  for wire in wires:
    add_wire(schematic, wire)

proc set_wire_path*(schematic: var Schematic, wire_id: WireID, path: Path) =
  schematic.wires[wire_id.wid].path = path

proc wires_len*(schematic: Schematic): int =
  return schematic.wires.len

proc set_wire_static_data*(
    schematic: var Schematic,
    wire_id: WireID,
    value_index: Allocation,
    word_size: Bits,
    comp_kind: WireCompKind,
    delay: int,
    circular_dependency: bool,
    critical_path: bool,
    reverse_flow: bool,
) =
  schematic.wires[wire_id.wid].value_index = value_index
  schematic.wires[wire_id.wid].word_size = word_size
  schematic.wires[wire_id.wid].comp_kind = comp_kind
  schematic.wires[wire_id.wid].delay = delay
  schematic.wires[wire_id.wid].circular_dependency = circular_dependency
  schematic.wires[wire_id.wid].critical_path = critical_path
  schematic.wires[wire_id.wid].reverse_flow = reverse_flow

proc set_wire_runtime_kind*(
    schematic: var Schematic, wire_id: WireID, runtime_kind: WireRuntimeKind
) =
  schematic.wires[wire_id.wid].runtime_kind = runtime_kind

proc set_wire_value_index*(
    schematic: var Schematic, wire_id: WireID, allocation: Allocation
) =
  schematic.wires[wire_id.wid].value_index = allocation

proc set_wire_color*(schematic: var Schematic, wire_id: WireID, color: uint8) =
  schematic.wires[wire_id.wid].color = color

proc set_wire_comment*(schematic: var Schematic, wire_id: WireID, comment: string) =
  schematic.wires[wire_id.wid].comment = comment

type ParseResult* = object
  comp_kind*: WireCompKind
  version*: uint8
  schematic*: Schematic
  custom_id*: int
  hub_id*: uint32
  hub_description*: string
  gate*: int
  delay*: int
  menu_visible*: bool
  clock_speed*: uint64
  dependencies*: seq[int]
  description*: string
  player_data*: seq[uint8]
  synced*: SyncState
  design*: array[32, array[32, uint8]]

proc length*(seg: Segment): uint16 =
  return seg.length

proc direction*(seg: Segment): uint8 =
  return seg.direction

proc new_segment*(length: uint16, direction: uint8): Segment =
  assert length != 0
  return Segment(length: length, direction: direction)

# Unfortunately casting to uints is necessary to avoid crashing on under / overflows
proc `+`*(a: Point, b: Point): Point =
  return Point(
    x: cast[int16](cast[uint16](a.x) + cast[uint16](b.x)),
    y: cast[int16](cast[uint16](a.y) + cast[uint16](b.y)),
  )

proc `+=`*(a: var Point, b: Point) =
  a = Point(
    x: cast[int16](cast[uint16](a.x) + cast[uint16](b.x)),
    y: cast[int16](cast[uint16](a.y) + cast[uint16](b.y)),
  )

proc `-`*(a: Point, b: Point): Point =
  return Point(
    x: cast[int16](cast[uint16](a.x) - cast[uint16](b.x)),
    y: cast[int16](cast[uint16](a.y) - cast[uint16](b.y)),
  )

proc `-=`*(a: var Point, b: Point) =
  a = Point(
    x: cast[int16](cast[uint16](a.x) - cast[uint16](b.x)),
    y: cast[int16](cast[uint16](a.y) - cast[uint16](b.y)),
  )

proc `*`*(a: Point, b: int16): Point =
  return Point(
    x: cast[int16](cast[uint16](a.x) * cast[uint16](b)),
    y: cast[int16](cast[uint16](a.y) * cast[uint16](b)),
  )

proc `*`*(a: Point, b: uint16): Point =
  return
    Point(x: cast[int16](cast[uint16](a.x) * b), y: cast[int16](cast[uint16](a.y) * b))

proc `*`*(a: Point, b: int): Point =
  return Point(
    x: cast[int16](cast[uint16](a.x) * cast[uint16](b)),
    y: cast[int16](cast[uint16](a.y) * cast[uint16](b)),
  )

proc `/`*(a: Point, b: int16): Point =
  return Point(x: a.x div b, y: a.y div b)

iterator each_point*(r: Rect): Point =
  for h in 0 .. r.h - 1:
    for w in 0 .. r.w - 1:
      yield Point(x: r.x + w.int16, y: r.y + h.int16)

iterator each_point*(rects: seq[Rect]): Point =
  for r in rects:
    for p in each_point(r):
      yield p

proc max_radius*(rect: Rect): int16 =
  let max_x = max(abs(rect.x), abs(rect.x + rect.w))
  let max_y = max(abs(rect.y), abs(rect.y + rect.h))
  return max_x + max_y

proc max_radius*(list: seq[Rect]): int16 =
  var current_max = 0'i16
  for area in list:
    current_max = max(current_max, max_radius(area))
  return current_max

func draw_segment_count*(path: Path): uint32 =
  return cast[uint32](path.segments.len)

func get_segment*(path: Path, index: uint32): Segment =
  return path.segments[index.int]

proc is_path_short*(path: Path): bool =
  return path.segments.len == 1 and path.segments[0].length < 2

iterator points*(path: Path): Point =
  yield path.start

  if path.segments.len == 0:
    yield path.finish
  else:
    var position = path.start
    for segment in path.segments:
      let direction = DIRECTIONS[segment.direction]
      for i in 0'u16 .. segment.length - 1:
        position += direction
        yield position

proc rotate*(position: Point, rotation: uint8): Point =
  case rotation
  of 0:
    return position
  of 1:
    return Point(x: -position.y, y: position.x)
  of 2:
    return Point(x: -position.x, y: -position.y)
  of 3:
    return Point(x: position.y, y: -position.x)
  else:
    assert false

func rotate_then_translate*(path: Path, rotation: uint8, translation: Point): Path =
  result = path
  result.start = result.start.rotate(rotation) + translation
  result.finish = result.finish.rotate(rotation) + translation
  for segment in result.segments.mitems:
    segment.direction = (segment.direction + rotation * 2) mod 8

iterator inner_points*(path: Path): (int, Point) =
  var i = 1
  if path.segments.len > 0:
    var position = path.start
    for seg_i, segment in path.segments:
      let direction = DIRECTIONS[segment.direction]
      for _ in 0 .. segment.length.int - 2:
        position += direction
        yield (i, position)
        i += 1
      if seg_i != path.segments.high:
        position += direction
        yield (i, position)
        i += 1

iterator segments*(path: Path): Segment =
  for segment in path.segments:
    yield segment

proc `in`*(p: Point, path: Path): bool =
  # This could be done faster
  for point in points(path):
    if p == point:
      return true

proc midpoint*(path: Path): tuple[sum: Point, direction: uint8] =
  var length = 0

  for segment in path.segments:
    length += segment.length.int

  var median_length_left = (length + 1) div 2
  var median_offset = median_length_left - length div 2

  var position = path.start
  for segment in path.segments:
    if segment.length.int < median_length_left:
      position += DIRECTIONS[segment.direction] * segment.length.int
      median_length_left -= segment.length.int
    else:
      result.sum =
        position * 2 +
        DIRECTIONS[segment.direction] * (median_length_left * 2 - median_offset)
      result.direction = segment.direction
      return

  assert false

proc get_start*(path: Path): Point =
  return path.start

proc get_finish*(path: Path): Point =
  return path.finish

proc has_segments*(path: Path): bool =
  return
    path.segments.len > 0
      # Teleport wires don't have segments, but they aren't tombstones

proc has_segments*(wire: Wire): bool =
  return has_segments(wire.path)

proc is_tombstone*(path: Path): bool =
  return path.start == path.finish

proc is_tombstone*(wire: Wire): bool =
  return is_tombstone(wire.path)


proc get_bool*(input: seq[uint8], i: var int): bool =
  result = input[i] != 0
  i += 1

proc get_int*(input: seq[uint8], i: var int): int =
  result =
    input[i + 0].int shl 0 + input[i + 1].int shl 8 + input[i + 2].int shl 16 +
    input[i + 3].int shl 24 + input[i + 4].int shl 32 + input[i + 5].int shl 40 +
    input[i + 6].int shl 48 + input[i + 7].int shl 56
  i += 8

proc get_bits*(input: seq[uint8], i: var int): Bits =
  result = bits(get_int(input, i))

proc get_bytes*(input: seq[uint8], i: var int): Bytes =
  result = bytes(get_int(input, i))

proc get_u64*(input: seq[uint8], i: var int): uint64 =
  result = cast[uint64](get_int(input, i))

proc get_u32*(input: seq[uint8], i: var int): uint32 =
  result =
    input[i + 0].uint32 shl 0 + input[i + 1].uint32 shl 8 + input[i + 2].uint32 shl 16 +
    input[i + 3].uint32 shl 24
  i += 4

proc get_u16*(input: seq[uint8], i: var int): uint16 =
  result = input[i + 0].uint16 shl 0 + input[i + 1].uint16 shl 8
  i += 2

proc get_i16*(input: seq[uint8], i: var int): int16 =
  result = cast[int16](get_u16(input, i))

proc get_u8*(input: seq[uint8], i: var int): uint8 =
  result = input[i]
  i += 1

proc get_i8*(input: seq[uint8], i: var int): int8 =
  result = cast[int8](input[i])
  i += 1

proc get_sync_state*(input: seq[uint8], i: var int): SyncState =
  result = SyncState(get_u8(input, i))

proc get_init_data*(input: seq[uint8], i: var int): InitialDataKind =
  result = InitialDataKind(get_u8(input, i))

proc get_point*(input: seq[uint8], i: var int): Point =
  return Point(x: get_i16(input, i), y: get_i16(input, i))

proc get_seq_u8*(input: seq[uint8], i: var int, bits32 = false): seq[uint8] =
  var len = 0
  if bits32:
    len = get_u32(input, i).int
  else:
    len = get_u16(input, i).int
  var j = 0
  while j < len:
    result.add(get_u8(input, i))
    j += 1

proc get_seq_int*(input: seq[uint8], i: var int): seq[int] =
  let len = get_u16(input, i)
  var j = 0'u16
  while j < len:
    result.add(get_int(input, i))
    j += 1

proc get_string*(input: seq[uint8], i: var int): string =
  let len = get_u16(input, i)
  var j = 0'u16
  while j < len:
    result.add(chr(get_u8(input, i)))
    j += 1

proc add_bool*(arr: var seq[uint8], input: bool) =
  arr.add(input.uint8)

proc add_int*(arr: var seq[uint8], input: int) =
  arr.add(cast[uint8]((input shr 0) and 0xff))
  arr.add(cast[uint8]((input shr 8) and 0xff))
  arr.add(cast[uint8]((input shr 16) and 0xff))
  arr.add(cast[uint8]((input shr 24) and 0xff))
  arr.add(cast[uint8]((input shr 32) and 0xff))
  arr.add(cast[uint8]((input shr 40) and 0xff))
  arr.add(cast[uint8]((input shr 48) and 0xff))
  arr.add(cast[uint8]((input shr 56) and 0xff))

proc add_u64*(arr: var seq[uint8], input: uint64) =
  add_int(arr, cast[int](input))

proc add_bits*(arr: var seq[uint8], input: Bits) =
  add_int(arr, input.amount)

proc add_bytes*(arr: var seq[uint8], input: Bytes) =
  add_int(arr, input.amount)

proc add_u32*(arr: var seq[uint8], input: uint32) =
  arr.add(cast[uint8]((input shr 0) and 0xff))
  arr.add(cast[uint8]((input shr 8) and 0xff))
  arr.add(cast[uint8]((input shr 16) and 0xff))
  arr.add(cast[uint8]((input shr 24) and 0xff))

proc add_u16*(arr: var seq[uint8], input: uint16) =
  arr.add(cast[uint8]((input shr 0) and 0xff))
  arr.add(cast[uint8]((input shr 8) and 0xff))

proc add_i16*(arr: var seq[uint8], input: int16) =
  arr.add(cast[uint8]((input shr 0) and 0xff))
  arr.add(cast[uint8]((input shr 8) and 0xff))

proc add_u8*(arr: var seq[uint8], input: uint8) =
  arr.add(input)

proc add_i8*(arr: var seq[uint8], input: int8) =
  arr.add(cast[uint8](input))

proc add_component_kind*(arr: var seq[uint8], input: ComponentKind) =
  arr.add_u16(ord(input).uint16)

proc add_init_data*(arr: var seq[uint8], input: InitialDataKind) =
  arr.add_u8(ord(input).uint8)

proc add_sync_state*(arr: var seq[uint8], input: SyncState) =
  arr.add(ord(input).uint8)

proc add_point*(arr: var seq[uint8], input: Point) =
  arr.add_i16(input.x)
  arr.add_i16(input.y)

proc add_seq_u8*(arr: var seq[uint8], input: seq[uint8], bits32 = false) =
  if bits32:
    arr.add_u32(input.len.uint32)
  else:
    arr.add_u16(input.len.uint16)
  for i in input:
    arr.add_u8(i)

proc add_seq_int*(arr: var seq[uint8], input: seq[int]) =
  arr.add_u16(input.len.uint16)
  for i in input:
    arr.add_int(i)

proc add_seq_u64*(arr: var seq[uint8], input: seq[uint64]) =
  arr.add_u16(input.len.uint16)
  for i in input:
    arr.add_u64(i)

proc add_string*(arr: var seq[uint8], input: string) =
  arr.add_u16(input.len.uint16)
  for c in input:
    arr.add_u8(ord(c).uint8)

proc add_table_int_string*(arr: var seq[uint8], input: Table[int, string]) =
  arr.add_int(input.len)
  for key, value in input:
    arr.add_int(key)
    arr.add_string(value)

proc pop_first*(path: var Path) =
  if path.segments.len == 0:
    return
  if path.segments[0].length <= 1:
    path.segments.delete(0)
    if path.segments.len == 0:
      # Make sure fake start and end gets out of the way for whoever is using this
      path.start = Point(x: int16.high)
      path.finish = path.start
    return
  path.segments[0].length -= 1
  path.start += DIRECTIONS[path.segments[0].direction]

proc pop_last*(path: var Path) =
  if path.segments.len == 0:
    return
  if path.segments[^1].length <= 1:
    discard path.segments.pop()
    if path.segments.len == 0:
      # Make sure fake start and end gets out of the way for whoever is using this
      path.start = Point(x: int16.high)
      path.finish = path.start
    return
  path.segments[^1].length -= 1
  path.finish -= DIRECTIONS[path.segments[^1].direction]

proc reverse*(path: Path): Path =
  result.finish = path.start
  result.start = path.finish
  var i = path.segments.high
  while i >= 0:
    result.segments.add(path.segments[i])
    result.segments[^1].direction = (result.segments[^1].direction + 4) mod 8
    i -= 1

proc new_path*(start: Point, segments: var seq[Segment]): Path =
  var position = start
  for segment in segments.mitems:
    position += DIRECTIONS[segment.direction] * segment.length
  return Path(start: start, finish: position, segments: segments)

proc empty_path*(start: Point): Path =
  return Path(start: start, finish: start)

proc teleport_path*(start: Point, finish: Point): Path =
  return Path(start: start, finish: finish)

proc point_list_to_path*(path: seq[Point]): Path =
  var offset = 0'u16
  var segments: seq[Segment]

  while offset < path.high.uint16:
    var original_direction = DIRECTIONS.find(path[offset + 1] - path[offset])

    if original_direction == -1:
      return teleport_path(path[0], path[^1])

    let max_length = path.high.uint16 - offset
    var length = 1'u16
    var direction = original_direction

    while length < max_length:
      direction = DIRECTIONS.find(path[offset + length + 1] - path[offset + length])
      if direction != original_direction:
        break
      length += 1

    assert length != 0
    segments.add(Segment(direction: original_direction.uint8, length: length))

    offset += length

  return new_path(path[0], segments)

proc add_path*(arr: var seq[uint8], path: Path) =
  arr.add_point(path.start)

  for segment in path.segments:
    let segs = (segment.direction.uint16 shl 13) or segment.length
    arr.add_u16(segs)

  arr.add_u16(0'u16)

proc length*(path: Path): int =
  for segment in path.segments:
    result += segment.length.int

proc split_path*(path: Path, index: int): (Path, Path) =
  result[0].start = path.start
  var index_left = index
  var position = path.start
  var segment_index = 0

  while segment_index <= path.segments.high and
      index_left > path.segments[segment_index].length.int:
    let segment = path.segments[segment_index]
    result[0].segments.add(segment)
    position += DIRECTIONS[segment.direction] * segment.length
    index_left -= segment.length.int
    segment_index += 1

  var split_position = position

  if index_left > 0:
    let segment = path.segments[segment_index]
    position += DIRECTIONS[segment.direction] * segment.length
    split_position += DIRECTIONS[segment.direction] * index_left

    var segment0 = path.segments[segment_index]
    segment0.length = index_left.uint16
    result[0].segments.add(segment0)

    var segment1 = path.segments[segment_index]
    segment1.length -= index_left.uint16
    if segment1.length > 0:
      result[1].segments.add(segment1)

    segment_index += 1

  result[0].finish = split_position
  result[1].start = split_position

  while segment_index < path.segments.len:
    let segment = path.segments[segment_index]
    position += DIRECTIONS[segment.direction] * segment.length
    result[1].segments.add(segment)
    segment_index += 1

  result[1].finish = position

var private_next_memory_index = 0

proc reset_allocation_index*() =
  private_next_memory_index = 256

proc allocate_memory*(orig_amount: Bytes, can_be_z: bool): Allocation =
  #let can_be_z = true # Let all allocs be z since the front end always reads z

  var amount = orig_amount

  # Simplex does not support store / loads of below odd sizes
  if amount.amount == 3:
    amount.amount = 4

  if amount.amount in [5,6,7]:
    amount.amount = 8

  var allocation = Allocation(
    index: private_next_memory_index, 
    size: amount,
    can_be_z: can_be_z,
  )
  private_next_memory_index += amount.amount
  if can_be_z:
    allocation.index += 1
    private_next_memory_index += 1

  return allocation

proc get_allocation_top*(): int =
  return private_next_memory_index

proc get_z_state_index*(allocation: Allocation): int =
  #assert allocation.can_be_z, $allocation
  return allocation.index - 1

proc get_state_index*(allocation: Allocation, index = 0): int =
  assert index < allocation.size.amount, $allocation & " " & $index
  return allocation.index + index

proc get_id*(allocation: Allocation): string =
  assert allocation.index != 0
  return "id" & $allocation.index

#proc `$`*(alloc: Allocation): string = assert false, "FIXME"

proc teleport_path*(path: seq[Point]): Path =
  return teleport_path(path[0], path[1])


