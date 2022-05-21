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
  VirtualRam8              = 18
  DELETED_0               = 19
  DELETED_1               = 20
  Stack                   = 21
  VirtualStack            = 22
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
  SRLatch                 = 53
  Decoder2                = 54
  Clock                   = 55
  WaveformGenerator       = 56
  DELETED_4               = 57
  DELETED_5               = 58
  Keyboard                = 59
  FileRom                 = 60
  Halt                    = 61
  WireCluster             = 62
  Screen                  = 63
  Program8_1              = 64
  Program8_1Red           = 65
  DELETED_6               = 66
  DELETED_7               = 67
  Program8_4              = 68
  LevelGate               = 69
  Input1                  = 70
  Input2Pin               = 71
  Input3Pin               = 72
  Input4Pin               = 73
  InputConditions         = 74
  Input8                  = 75
  Input64                 = 76
  InputCode               = 77
  Input1_1B               = 78
  Output1                 = 79
  Output1Sum              = 80
  Output1Car              = 81
  Output1Aval             = 82
  Output1Bval             = 83
  Output2Pin              = 84
  Output3Pin              = 85
  Output4Pin              = 86
  Output8                 = 87
  Output64                = 88
  Output1_1B              = 89
  OutputCounter           = 90
  InputOutput             = 91
  Custom                  = 92
  VirtualCustom           = 93
  ProgramWord             = 94
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

  Bidirectional1          = 128
  Bidirectional8          = 129
  Bidirectional16         = 130
  Bidirectional32         = 131
  Bidirectional64         = 132

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

  Output8zLevel           = 187

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

const VIRTUAL_KINDS*  = [VirtualDelayLine1, VirtualDelayLine8, VirtualDelayLine16, VirtualDelayLine32, VirtualDelayLine64, VirtualBitMemory, VirtualRam8, VirtualRegister8, VirtualCounter32, VirtualCounter16, VirtualRegister16, VirtualCustom, VirtualRamFast, VirtualCounter64, VirtualRegister32, VirtualRam, VirtualRegister8RedPlus, VirtualStack, VirtualRegister64, VirtualCounter8, VirtualRegister8Red, VirtualRamLatency, VirtualRom, VirtualSolutionRom, VirtualHdd, VirtualRamDualLoad]
const CUSTOM_INPUTS*  = [Input1, Input8, Input16, Input32, Input64]
const CUSTOM_OUTPUTS* = [Output1, Output8, Output16, Output32, Output64]
const LATCHES*        = [AndOrLatch, NandNandLatch, NorNorLatch]

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

type parse_component* = object
  kind*: component_kind
  position*: point
  rotation*: uint8
  real_offset*: int8
  permanent_id*: int
  custom_string*: string
  custom_id*: int
  nudge_on_add*: point
  setting_1*: uint64
  setting_2*: uint64
  selected_programs*: Table[int, string]

type parse_wire* = object
  path*: seq[point]
  kind*: wire_kind
  color*: uint8
  comment*: string

type parse_result* = object
  components*: seq[parse_component]
  wires*: seq[parse_wire]
  save_version*: int
  gate*: int
  delay*: int
  menu_visible*: bool
  clock_speed*: uint32
  dependencies*: seq[int]
  description*: string
  camera_position*: point
  player_data*: seq[uint8]
  image_data*: seq[uint8]

proc `+`*(a: point, b: point): point =
  return point(x: a.x + b.x, y: a.y + b.y)

proc `-`*(a: point, b: point): point =
  return point(x: a.x - b.x, y: a.y - b.y)

proc `*`*(a: point, b: int16): point =
  return point(x: a.x * b, y: a.y * b)

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

proc get_point*(input: seq[uint8], i: var int): point =
  return point(
    x: get_i16(input, i), 
    y: get_i16(input, i)
  )

proc get_seq_u8*(input: seq[uint8], i: var int): seq[uint8] =
  let len = get_u16(input, i)
  var j = 0'u16
  while j < len:
    result.add(get_u8(input, i))
    j += 1

proc get_seq_i64*(input: seq[uint8], i: var int): seq[int] =
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

proc add_component_kind*(arr: var seq[uint8], input: component_kind) =
  arr.add_u16(ord(input).uint16)

proc add_wire_kind*(arr: var seq[uint8], input: wire_kind) =
  arr.add(ord(input).uint8)

proc add_point*(arr: var seq[uint8], input: point) =
  arr.add_i16(input.x)
  arr.add_i16(input.y)

proc add_seq_uint8*(arr: var seq[uint8], input: seq[uint8]) =
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
