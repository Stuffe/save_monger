import tables
export tables

const TELEPORT_WIRE   = 0b0010_0000'u8

type component_kind* = enum
  Error                   = 0
  Off                     = 1
  On                      = 2
  Buffer1                 = 3
  Not                     = 4
  And                     = 5
  And3                    = 6
  Nand                    = 7
  Or                      = 8
  Or3                     = 9
  Nor                     = 10
  Xor                     = 11
  Xnor                    = 12
  Counter8                = 13
  VirtualCounter8         = 14
  Counter64               = 15
  VirtualCounter64        = 16
  Ram8                    = 17
  VirtualRam8             = 18
  DELETED_0               = 19
  DELETED_1               = 20
  DELETED_17              = 21
  DELETED_18              = 22
  Register8               = 23
  VirtualRegister8        = 24
  Register8Red            = 25
  VirtualRegister8Red     = 26
  Register8RedPlus        = 27
  VirtualRegister8RedPlus = 28
  Register64              = 29
  VirtualRegister64       = 30
  Switch8                 = 31
  Mux8                    = 32
  Decoder1                = 33
  Decoder3                = 34
  Constant8               = 35
  Not8                    = 36
  Or8                     = 37
  And8                    = 38
  Xor8                    = 39
  Equal8                  = 40
  DELETED_2               = 41
  DELETED_3               = 42
  Neg8                    = 43
  Add8                    = 44
  Mul8                    = 45
  Splitter8               = 46
  Maker8                  = 47
  Splitter64              = 48
  Maker64                 = 49
  FullAdder               = 50
  BitMemory               = 51
  VirtualBitMemory        = 52
  DELETED_10              = 53
  Decoder2                = 54
  Timing                  = 55
  NoteSound               = 56
  DELETED_4               = 57
  DELETED_5               = 58
  Keyboard                = 59
  FileLoader              = 60
  Halt                    = 61
  WireCluster             = 62
  LevelScreen             = 63
  Program8_1              = 64
  Program8_1Red           = 65
  DELETED_6               = 66
  DELETED_7               = 67
  Program8_4              = 68
  LevelGate               = 69
  Input1                  = 70
  LevelInput2Pin          = 71
  LevelInput3Pin          = 72
  LevelInput4Pin          = 73
  LevelInputConditions    = 74
  Input8                  = 75
  Input64                 = 76
  LevelInputCode          = 77
  LevelInputArch          = 78
  Output1                 = 79
  LevelOutput1Sum         = 80
  LevelOutput1Car         = 81
  DELETED_8               = 82
  DELETED_9               = 83
  LevelOutput2Pin         = 84
  LevelOutput3Pin         = 85
  LevelOutput4Pin         = 86
  Output8                 = 87
  Output64                = 88
  LevelOutputArch         = 89
  LevelOutputCounter      = 90
  DELETED_11              = 91
  Custom                  = 92
  VirtualCustom           = 93
  Program                 = 94
  DelayLine1              = 95
  VirtualDelayLine1       = 96
  Console                 = 97
  Shl8                    = 98
  Shr8                    = 99

  Constant64              = 100
  Not64                   = 101
  Or64                    = 102
  And64                   = 103
  Xor64                   = 104
  Neg64                   = 105
  Add64                   = 106
  Mul64                   = 107
  Equal64                 = 108
  LessU64                 = 109
  LessI64                 = 110
  Shl64                   = 111
  Shr64                   = 112
  Mux64                   = 113
  Switch64                = 114

  ProbeMemoryBit          = 115
  ProbeMemoryWord         = 116

  AndOrLatch              = 117
  NandNandLatch           = 118
  NorNorLatch             = 119

  LessU8                  = 120
  LessI8                  = 121

  DotMatrixDisplay        = 122
  SegmentDisplay          = 123

  Input16                 = 124
  Input32                 = 125

  Output16                = 126
  Output32                = 127

  DELETED_12              = 128
  DELETED_13              = 129
  DELETED_14              = 130
  DELETED_15              = 131
  DELETED_16              = 132

  Buffer8                 = 133
  Buffer16                = 134
  Buffer32                = 135
  Buffer64                = 136

  ProbeWireBit            = 137
  ProbeWireWord           = 138

  Switch1                 = 139

  Output1z                = 140
  Output8z                = 141
  Output16z               = 142
  Output32z               = 143
  Output64z               = 144

  Constant16              = 145
  Not16                   = 146
  Or16                    = 147
  And16                   = 148
  Xor16                   = 149
  Neg16                   = 150
  Add16                   = 151
  Mul16                   = 152
  Equal16                 = 153
  LessU16                 = 154
  LessI16                 = 155
  Shl16                   = 156
  Shr16                   = 157
  Mux16                   = 158
  Switch16                = 159
  Splitter16              = 160
  Maker16                 = 161
  Register16              = 162
  VirtualRegister16       = 163
  Counter16               = 164
  VirtualCounter16        = 165

  Constant32              = 166
  Not32                   = 167
  Or32                    = 168
  And32                   = 169
  Xor32                   = 170
  Neg32                   = 171
  Add32                   = 172
  Mul32                   = 173
  Equal32                 = 174
  LessU32                 = 175
  LessI32                 = 176
  Shl32                   = 177
  Shr32                   = 178
  Mux32                   = 179
  Switch32                = 180
  Splitter32              = 181
  Maker32                 = 182
  Register32              = 183
  VirtualRegister32       = 184
  Counter32               = 185
  VirtualCounter32        = 186

  LevelOutput8z           = 187

  Nand8                   = 188
  Nor8                    = 189
  Xnor8                   = 190
  Nand16                  = 191
  Nor16                   = 192
  Xnor16                  = 193
  Nand32                  = 194
  Nor32                   = 195
  Xnor32                  = 196
  Nand64                  = 197
  Nor64                   = 198
  Xnor64                  = 199

  Ram                     = 200
  VirtualRam              = 201
  RamLatency              = 202
  VirtualRamLatency       = 203

  RamFast                 = 204
  VirtualRamFast          = 205
  Rom                     = 206
  VirtualRom              = 207
  SolutionRom             = 208
  VirtualSolutionRom      = 209

  DelayLine8              = 210
  VirtualDelayLine8       = 211
  DelayLine16             = 212
  VirtualDelayLine16      = 213
  DelayLine32             = 214
  VirtualDelayLine32      = 215
  DelayLine64             = 216
  VirtualDelayLine64      = 217

  RamDualLoad             = 218
  VirtualRamDualLoad      = 219

  Hdd                     = 220
  VirtualHdd              = 221

  Network                 = 222

  Rol8                    = 223
  Rol16                   = 224
  Rol32                   = 225
  Rol64                   = 226
  Ror8                    = 227
  Ror16                   = 228
  Ror32                   = 229
  Ror64                   = 230

  IndexerBit              = 231
  IndexerByte             = 232

  DivMod8                 = 233
  DivMod16                = 234
  DivMod32                = 235
  DivMod64                = 236

  SpriteDisplay           = 237
  ConfigDelay             = 238

  Clock                   = 239

  LevelInput1             = 240
  LevelInput8             = 241
  LevelOutput1            = 242
  LevelOutput8            = 243

  Ashr8                   = 244
  Ashr16                  = 245
  Ashr32                  = 246
  Ashr64                  = 247

  Bidirectional1          = 248
  VirtualBidirectional1   = 249
  Bidirectional8          = 250
  VirtualBidirectional8   = 251
  Bidirectional16         = 252
  VirtualBidirectional16  = 253
  Bidirectional32         = 254
  VirtualBidirectional32  = 255
  Bidirectional64         = 256
  VirtualBidirectional64  = 257

const EARLY_KINDS*             = {LevelInput1, LevelInput2Pin, LevelInput3Pin, LevelInput4Pin, LevelInputConditions, LevelInput8, Input64, LevelInputCode, LevelOutput1, LevelOutput1Sum, LevelOutput1Car, LevelOutput2Pin, LevelOutput3Pin, LevelOutput4Pin, LevelOutput8, LevelOutputArch, LevelOutputCounter, LevelOutput8z, DelayLine1, DelayLine16, BitMemory, Ram8, Hdd, Register8, Counter32, Counter16, Register16, DelayLine8, Custom, SolutionRom, RamFast, Counter64, Rom, Register32, Ram, Register8RedPlus, DelayLine64, Register64, DelayLine32, Counter8, Register8Red, RamLatency, RamDualLoad, DelayLine1, DelayLine16, BitMemory, Ram8, Hdd, Register8, Counter32, Counter16, Register16, DelayLine8, Custom, SolutionRom, RamFast, Counter64, Rom, Register32, Ram, Register8RedPlus, DelayLine64, Register64, DelayLine32, Counter8, Register8Red, RamLatency, RamDualLoad, Bidirectional1, Bidirectional8, Bidirectional16, Bidirectional32, Bidirectional64}
const LATE_KINDS*              = {VirtualCounter8, VirtualCounter64, VirtualRam8, VirtualRegister8, VirtualRegister8Red, VirtualRegister8RedPlus, VirtualRegister64, VirtualBitMemory, VirtualCustom, VirtualDelayLine1, VirtualRegister16, VirtualCounter16, VirtualRegister32, VirtualCounter32, VirtualRam, VirtualRamLatency, VirtualRamFast, VirtualRom, VirtualSolutionRom, VirtualDelayLine8, VirtualDelayLine16, VirtualDelayLine32, VirtualDelayLine64, VirtualRamDualLoad, VirtualHdd, VirtualBidirectional1, VirtualBidirectional8, VirtualBidirectional16, VirtualBidirectional32, VirtualBidirectional64}
const CUSTOM_INPUTS*           = {Input1, Input8, Input16, Input32, Input64}
const CUSTOM_OUTPUTS*          = {Output1, Output8, Output16, Output32, Output64}
const CUSTOM_TRISTATE_OUTPUTS* = {Output1z, Output8z, Output16z, Output32z, Output64z}
const CUSTOM_BIDIRECTIONAL*    = {Bidirectional1, Bidirectional8, Bidirectional16, Bidirectional32, Bidirectional64}
const LEVEL_INPUTS*            = {LevelInput1, LevelInput2Pin, LevelInput3Pin, LevelInput4Pin, LevelInput8, LevelInputArch, LevelInputCode, LevelInputConditions}
const LEVEL_OUTPUTS*           = {LevelOutput1, LevelOutput1Car, LevelOutput1Sum, LevelOutput2Pin, LevelOutput3Pin, LevelOutput4Pin, LevelOutput8, LevelOutput8z, LevelOutputArch, LevelOutputCounter}
const LATCHES*                 = {AndOrLatch, NandNandLatch, NorNorLatch}
const DELETED_KINDS*           = {DELETED_0, DELETED_1, DELETED_2, DELETED_3, DELETED_4, DELETED_5, DELETED_6, DELETED_7, DELETED_9, DELETED_9, DELETED_10, DELETED_11, DELETED_12, DELETED_13, DELETED_14, DELETED_15, DELETED_16, DELETED_17, DELETED_18}

type point* = object
  x*: int16
  y*: int16

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

type wire_kind* = enum
  wk_1
  wk_8
  wk_16
  wk_32
  wk_64

type sync_state* = enum
  unsynced
  synced
  changed_after_sync

type parse_component* = object
  kind*: component_kind
  position*: point
  custom_displacement*: point
  rotation*: uint8
  real_offset*: int8
  permanent_id*: int
  custom_string*: string
  custom_id*: int
  setting_1*: uint64
  setting_2*: uint64
  selected_programs*: Table[int, string]
  ui_order*: int16

type parse_wire* = object
  path*: seq[point]
  kind*: wire_kind
  color*: uint8
  comment*: string

type parse_result* = object
  version*: uint8
  components*: seq[parse_component]
  wires*: seq[parse_wire]
  save_id*: int # Unique id for each architectures and custom components. For levels it serves as a check against outdated versions
  hub_id*: uint32
  hub_description*: string
  gate*: int
  delay*: int
  menu_visible*: bool
  clock_speed*: uint32
  dependencies*: seq[int]
  description*: string
  camera_position*: point
  player_data*: seq[uint8]
  synced*: sync_state
  campaign_bound*: bool

# Unfortunately casting to uints is necessary to avoid crashing on under / overflows
proc `+`*(a: point, b: point): point =
  return point(
    x: cast[int16](cast[uint16](a.x) + cast[uint16](b.x)), 
    y: cast[int16](cast[uint16](a.y) + cast[uint16](b.y))
  )

proc `-`*(a: point, b: point): point =
  return point(
    x: cast[int16](cast[uint16](a.x) - cast[uint16](b.x)), 
    y: cast[int16](cast[uint16](a.y) - cast[uint16](b.y))
  )

proc `*`*(a: point, b: int16): point =
  return point(
    x: cast[int16](cast[uint16](a.x) * cast[uint16](b)),
    y: cast[int16](cast[uint16](a.y) * cast[uint16](b))
  )

proc get_bool*(input: seq[uint8], i: var int): bool =
  result = input[i] != 0
  i += 1

proc get_int*(input: seq[uint8], i: var int): int =
  result =  input[i+0].int shl 0 +
            input[i+1].int shl 8 +
            input[i+2].int shl 16 +
            input[i+3].int shl 24 +
            input[i+4].int shl 32 +
            input[i+5].int shl 40 +
            input[i+6].int shl 48 +
            input[i+7].int shl 56
  i += 8

proc get_u64*(input: seq[uint8], i: var int): uint64 =
  result = cast[uint64](get_int(input, i))

proc get_u32*(input: seq[uint8], i: var int): uint32 =
  result =  input[i+0].uint32 shl 0 +
            input[i+1].uint32 shl 8 +
            input[i+2].uint32 shl 16 +
            input[i+3].uint32 shl 24
  i += 4

proc get_u16*(input: seq[uint8], i: var int): uint16 =
  result =  input[i+0].uint16 shl 0 +
            input[i+1].uint16 shl 8
  i += 2

proc get_i16*(input: seq[uint8], i: var int): int16 =
  result = cast[int16](get_u16(input, i))

proc get_u8*(input: seq[uint8], i: var int): uint8 =
  result = input[i]
  i += 1

proc get_i8*(input: seq[uint8], i: var int): int8 =
  result = cast[int8](input[i])
  i += 1

proc get_sync_state*(input: seq[uint8], i: var int): sync_state =
  result = sync_state(get_u8(input, i))

proc get_point*(input: seq[uint8], i: var int): point =
  return point(
    x: get_i16(input, i), 
    y: get_i16(input, i)
  )

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
  arr.add(cast[uint8]((input shr 0)  and 0xff))
  arr.add(cast[uint8]((input shr 8)  and 0xff))
  arr.add(cast[uint8]((input shr 16) and 0xff))
  arr.add(cast[uint8]((input shr 24) and 0xff))
  arr.add(cast[uint8]((input shr 32) and 0xff))
  arr.add(cast[uint8]((input shr 40) and 0xff))
  arr.add(cast[uint8]((input shr 48) and 0xff))
  arr.add(cast[uint8]((input shr 56) and 0xff))

proc add_u64*(arr: var seq[uint8], input: uint64) =
  add_int(arr, cast[int](input))

proc add_u32*(arr: var seq[uint8], input: uint32) =
  arr.add(cast[uint8]((input shr 0)  and 0xff))
  arr.add(cast[uint8]((input shr 8)  and 0xff))
  arr.add(cast[uint8]((input shr 16) and 0xff))
  arr.add(cast[uint8]((input shr 24) and 0xff))

proc add_u16*(arr: var seq[uint8], input: uint16) =
  arr.add(cast[uint8]((input shr 0)  and 0xff))
  arr.add(cast[uint8]((input shr 8)  and 0xff))

proc add_i16*(arr: var seq[uint8], input: int16) =
  arr.add(cast[uint8]((input shr 0)  and 0xff))
  arr.add(cast[uint8]((input shr 8)  and 0xff))

proc add_u8*(arr: var seq[uint8], input: uint8) =
  arr.add(input)

proc add_i8*(arr: var seq[uint8], input: int8) =
  arr.add(cast[uint8](input))

proc add_component_kind*(arr: var seq[uint8], input: component_kind) =
  arr.add_u16(ord(input).uint16)

proc add_wire_kind*(arr: var seq[uint8], input: wire_kind) =
  arr.add(ord(input).uint8)

proc add_sync_state*(arr: var seq[uint8], input: sync_state) =
  arr.add(ord(input).uint8)

proc add_point*(arr: var seq[uint8], input: point) =
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

proc add_path*(arr: var seq[uint8], path: seq[point]) =
  #[
    Wire paths encoding rules:
    1. The wire starts with a point: (x: int16, y: int16). 
    2. After this follow 1 or more segments (3 bit direction, 5 bit length)
    3. We end once a 0 length segment is encountered (0 byte)
  ]#

  arr.add_point(path[0])

  var offset = 0

  while offset < path.high:
    let original_direction = DIRECTIONS.find(path[offset + 1] - path[offset])

    if original_direction == -1: 
      if path.len == 2:
        # Special case for players who want to generate "teleport" wires
        arr.add_u8(TELEPORT_WIRE)
        arr.add_point(path[1])
        return
      break

    # We have 5 bits to save the length, so max length is 31
    let max_length = min(path.high - offset, 0b0001_1111)
    var length = 1
    var direction = original_direction

    while length < max_length:
      direction = DIRECTIONS.find(path[offset + length + 1] - path[offset + length])
      if direction != original_direction: break
      length += 1

    let segment = ((original_direction shl 5) or length).uint8
    arr.add_u8(segment)

    offset += length

  # Length 0 segment, ends the wire
  arr.add_u8(0.uint8)
