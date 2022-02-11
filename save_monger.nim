import strutils, std/hashes

#{.warning[HoleEnumConv]: off.}

const FORMAT_VERSION* = 1.uint8
const TELEPORT_WIRE   = 0b0010_0000'u8

type component_kind* = enum
  Error                   = 0
  Off                     = 1
  On                      = 2
  Buffer                  = 3
  Not                     = 4
  And                     = 5
  And3                    = 6
  Nand                    = 7
  Or                      = 8
  Or3                     = 9
  Nor                     = 10
  Xor                     = 11
  Xnor                    = 12
  ByteCounter             = 13
  VirtualByteCounter      = 14
  QwordCounter            = 15
  VirtualQwordCounter     = 16
  Ram                     = 17
  VirtualRam              = 18
  QwordRam                = 19
  VirtualQwordRam         = 20
  Stack                   = 21
  VirtualStack            = 22
  Register                = 23
  VirtualRegister         = 24
  RegisterRed             = 25
  VirtualRegisterRed      = 26
  RegisterRedPlus         = 27
  VirtualRegisterRedPlus  = 28
  QwordRegister           = 29
  VirtualQwordRegister    = 30
  ByteSwitch              = 31
  ByteMux                 = 32
  Decoder1                = 33
  Decoder3                = 34
  ByteConstant            = 35
  ByteNot                 = 36
  ByteOr                  = 37
  ByteAnd                 = 38
  ByteXor                 = 39
  ByteEqual               = 40
  ByteLessU               = 41
  ByteLessI               = 42
  ByteNeg                 = 43
  ByteAdd                 = 44
  ByteMul                 = 45
  ByteSplitter            = 46
  ByteMaker               = 47
  QwordSplitter           = 48
  QwordMaker              = 49
  FullAdder               = 50
  BitMemory               = 51
  VirtualBitMemory        = 52
  SRLatch                 = 53
  Random                  = 54
  Clock                   = 55
  WaveformGenerator       = 56
  HttpClient              = 57
  AsciiScreen             = 58
  Keypad                  = 59
  FileRom                 = 60
  Halt                    = 61
  CircuitCluster          = 62
  Screen                  = 63
  Program1                = 64
  Program1Red             = 65
  Program2                = 66
  Program3                = 67
  Program4                = 68
  LevelGate               = 69
  Input1                  = 70
  Input2                  = 71
  Input3                  = 72
  Input4                  = 73
  Input1BConditions       = 74
  Input1B                 = 75
  InputQword              = 76
  Input1BCode             = 77
  Input1_1B               = 78
  Output1                 = 79
  Output1Sum              = 80
  Output1Car              = 81
  Output1Aval             = 82
  Output1Bval             = 83
  Output2                 = 84
  Output3                 = 85
  Output4                 = 86
  Output1B                = 87
  OutputQword             = 88
  Output1_1B              = 89
  OutputCounter           = 90
  InputOutput             = 91
  Custom                  = 92
  VirtualCustom           = 93
  QwordProgram            = 94
  DelayBuffer             = 95
  VirtualDelayBuffer      = 96
  Console                 = 97
  ByteShl                 = 98
  ByteShr                 = 99

  QwordConstant           = 100
  QwordNot                = 101
  QwordOr                 = 102
  QwordAnd                = 103
  QwordXor                = 104
  QwordNeg                = 105
  QwordAdd                = 106
  QwordMul                = 107
  QwordEqual              = 108
  QwordLessU              = 109
  QwordLessI              = 110
  QwordShl                = 111
  QwordShr                = 112
  QwordMux                = 113
  QwordSwitch             = 114

  StateBit                = 115
  StateByte               = 116

const VIRTUAL_KINDS*  = [VirtualDelayBuffer, VirtualCustom, VirtualRegister, VirtualQwordRegister, VirtualBitMemory, VirtualByteCounter, VirtualQwordCounter, VirtualStack, VirtualRam, VirtualQwordRam, VirtualRegisterRedPlus, VirtualRegisterRed]
const CUSTOM_INPUTS*  = [Input1, Input1B, InputQword]
const CUSTOM_OUTPUTS* = [Output1, Output1B, OutputQword]

type circuit_kind* = enum
  ck_bit
  ck_byte
  ck_qword

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

type parse_component* = object
  kind*: component_kind
  position*: point
  rotation*: uint8
  permanent_id*: int
  custom_string*: string
  custom_id*: int
  program_name*: string

type parse_circuit* = object
  permanent_id*: int
  path*: seq[point]
  kind*: circuit_kind
  color*: uint8
  comment*: string

type parse_result* = object
  components*: seq[parse_component]
  circuits*: seq[parse_circuit]
  save_version*: int
  nand*: uint32
  delay*: uint32
  menu_visible*: bool
  nesting_level*: uint8
  clock_speed*: uint32
  dependencies*: seq[int]
  description*: string
  unpacked*: bool
  camera_position*: point

proc `+`*(a: point, b: point): point =
  return point(x: a.x + b.x, y: a.y + b.y)

proc `-`*(a: point, b: point): point =
  return point(x: a.x - b.x, y: a.y - b.y)

proc to_string*(str: seq[uint8]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, chr(ch))

proc to_bytes*(input: string): seq[uint8] = 
  result = newSeq[uint8](input.len)
  for i in 0..input.high:
    result[i] = uint8(input[i])

proc file_get_bytes*(file_name: string): seq[uint8] =
  var file = open(file_name)

  let len = getFileSize(file)
  var buffer = newSeq[uint8](len)
  if len == 0: return buffer
  discard file.readBytes(buffer, 0, len)
  file.close()
  return buffer

# Backwards compatability November 2021
proc to_custom_id*(input: string): int =
  var name = input
  name = name.split('/')[^1]
  name = name.split('\\')[^1]
  return abs(hash(name))

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

proc get_seq_i64*(input: seq[uint8], i: var int): seq[int] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    result.add(get_int(input, i))

proc get_string*(input: seq[uint8], i: var int): string =
  let len = get_int(input, i)
  for j in 0..len - 1:
    result.add(chr(get_u8(input, i)))

proc get_point*(input: seq[uint8], i: var int): point =
  return point(
    x: get_i16(input, i), 
    y: get_i16(input, i)
  )

proc get_component*(input: seq[uint8], i: var int): parse_component =
  try: # Only fails for obsolete components (deleted enum values)
    result = parse_component(kind: component_kind(get_u16(input, i).int))
  except: discard
  result.position = get_point(input, i)
  result.rotation = get_u8(input, i)
  result.permanent_id = get_int(input, i)
  result.custom_string = get_string(input, i)
  if result.kind in [Program1, Program2, Program3, Program4, QwordProgram]:
    result.program_name = get_string(input, i)
  elif result.kind == Custom:
    result.custom_id = get_int(input, i)

proc get_components*(input: seq[uint8], i: var int): seq[parse_component] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    let comp = get_component(input, i)
    if comp.kind == Error: continue
    result.add(comp)

proc get_circuit*(input: seq[uint8], i: var int): parse_circuit =
  result.permanent_id = get_int(input, i)
  result.kind = circuit_kind(get_u8(input, i))
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

proc get_circuits*(input: seq[uint8], i: var int): seq[parse_circuit] =
  let len = get_int(input, i)
  for j in 0..len - 1:
    result.add(get_circuit(input, i))

proc parse_state*(input: seq[uint8], meta_only = false): parse_result =
  result.nand = 99999.uint32
  result.delay = 99999.uint32
  result.clock_speed = 100000.uint32
  result.menu_visible = true

  if input.len == 0: return

  var version = input[0]

  case version:
    of 49: # 1 in ascii
      let parts = input.to_string.split("|")
      if parts.len notin [4, 5]:
        return

      if parts[3] != "":
        try:
          var scores = parts[3].split(",")
          result.nand = parseInt(scores[0]).uint32
          result.delay = parseInt(scores[1]).uint32
        except: discard

      if parts.len == 5 and parts[4] != "":
        result.save_version = parseInt(parts[4])

      if not meta_only:
        if parts[1] != "":
          let component_strings = parts[1].split(";")
          for comp_string in component_strings:
            var comp_parts = comp_string.split("`")

            if comp_parts.len != 6:
              continue

            try:
              result.components.add(parse_component(
                kind: parseEnum[component_kind](comp_parts[0]),
                position: point(x: parseInt(comp_parts[1]).int16, y: parseInt(comp_parts[2]).int16),
                rotation: parseInt(comp_parts[3]).uint8,
                permanent_id: parseInt(comp_parts[4]).uint32.int,
                custom_string: comp_parts[5]
              ))
              if result.components[^1].kind == Custom:
                try:
                  result.components[^1].custom_id = parseInt(comp_parts[5])
                except:
                  result.components[^1].custom_id = to_custom_id(comp_parts[5]) # Old string name
            except:
              discard

        if parts[2] != "":
          let circuit_strings = parts[2].split(";")
          
          for circ_string in circuit_strings:
            let circ_parts = circ_string.split("`")

            if circ_parts.len != 5: 
              continue

            var path = newSeq[point]()
            var x = 0.int16
            var i = 0
            for n in circ_parts[4].split(","):
              if i mod 2 == 0:
                x = parseInt(n).int16
              else:
                path.add(point(x: x, y: parseInt(n).int16))
              i += 1

            result.circuits.add(parse_circuit(
              permanent_id: parseInt(circ_parts[0]),
              kind: circuit_kind(parseInt(circ_parts[1])),
              color: parseInt(circ_parts[2]).uint8, 
              comment: circ_parts[3],
              path: path, 
            ))

    of 0:
      var i = 1 # 0th byte is version

      result.save_version = get_int(input, i)
      result.nand = get_u32(input, i)
      result.delay = get_u32(input, i)
      result.menu_visible = get_bool(input, i)
      result.clock_speed = get_u32(input, i)
      result.nesting_level = get_u8(input, i)
      result.dependencies = get_seq_i64(input, i)
      result.description = get_string(input, i)

      if not meta_only:
        # Old versions of these procs
        proc get_point(input: seq[uint8], i: var int): point =
          return point(
            x: get_i8(input, i).int16, 
            y: get_i8(input, i).int16
          )

        proc get_seq_point(input: seq[uint8], i: var int): seq[point] =
          let len = get_int(input, i)
          for j in 0..len - 1:
            result.add(get_point(input, i))

        proc get_component(input: seq[uint8], i: var int): parse_component =
          try: # Only fails for obsolete components (deleted enum values)
            result = parse_component(kind: component_kind(get_u16(input, i).int))
          except: discard
          result.position = get_point(input, i)
          result.rotation = get_u8(input, i)
          result.permanent_id = get_u32(input, i).int
          result.custom_string = get_string(input, i)
          if result.kind in [Program1, Program2, Program3, Program4, QwordProgram]:
            result.program_name = get_string(input, i)
          elif result.kind == Custom:
            result.custom_id = get_int(input, i)

        proc get_components(input: seq[uint8], i: var int): seq[parse_component] =
          let len = get_int(input, i)
          for j in 0..len - 1:
            let comp = get_component(input, i)
            if comp.kind == Error: continue
            result.add(comp)

        proc get_circuit(input: seq[uint8], i: var int): parse_circuit =
          result.permanent_id = get_u32(input, i).int
          result.kind = circuit_kind(get_u8(input, i))
          result.color = get_u8(input, i)
          result.comment = get_string(input, i)
          result.path = get_seq_point(input, i)

        proc get_circuits(input: seq[uint8], i: var int): seq[parse_circuit] =
          let len = get_int(input, i)
          for j in 0..len - 1:
            result.add(get_circuit(input, i))

        result.components = get_components(input, i)
        result.circuits = get_circuits(input, i)

    of 1:
      var i = 1 # 0th byte is version

      result.save_version = get_int(input, i)
      result.nand = get_u32(input, i)
      result.delay = get_u32(input, i)
      result.menu_visible = get_bool(input, i)
      result.clock_speed = get_u32(input, i)
      result.nesting_level = get_u8(input, i)
      result.dependencies = get_seq_i64(input, i)
      result.description = get_string(input, i)
      result.unpacked = get_bool(input, i)
      result.camera_position = get_point(input, i)
      discard get_bool(input, i) # Has cached design, for future custom component lazy loading

      if not meta_only:
        result.components = get_components(input, i)
        result.circuits = get_circuits(input, i)

    else: discard

proc add_bytes*(arr: var seq[uint8], input: bool) =
  arr.add(input.uint8)

proc add_bytes*(arr: var seq[uint8], input: int) =
  arr.add(cast[uint8]((input shr 0)  and 0xff))
  arr.add(cast[uint8]((input shr 8)  and 0xff))
  arr.add(cast[uint8]((input shr 16) and 0xff))
  arr.add(cast[uint8]((input shr 24) and 0xff))
  arr.add(cast[uint8]((input shr 32) and 0xff))
  arr.add(cast[uint8]((input shr 40) and 0xff))
  arr.add(cast[uint8]((input shr 48) and 0xff))
  arr.add(cast[uint8]((input shr 56) and 0xff))

proc add_bytes*(arr: var seq[uint8], input: uint64) =
  add_bytes(arr, cast[int](input))

proc add_bytes*(arr: var seq[uint8], input: uint32) =
  arr.add(cast[uint8]((input shr 0)  and 0xff))
  arr.add(cast[uint8]((input shr 8)  and 0xff))
  arr.add(cast[uint8]((input shr 16) and 0xff))
  arr.add(cast[uint8]((input shr 24) and 0xff))

proc add_bytes*(arr: var seq[uint8], input: uint16) =
  arr.add(cast[uint8]((input shr 0)  and 0xff))
  arr.add(cast[uint8]((input shr 8)  and 0xff))

proc add_bytes*(arr: var seq[uint8], input: int16) =
  arr.add(cast[uint8]((input shr 0)  and 0xff))
  arr.add(cast[uint8]((input shr 8)  and 0xff))

proc add_bytes*(arr: var seq[uint8], input: uint8) =
  arr.add(input)

proc add_bytes*(arr: var seq[uint8], input: component_kind) =
  arr.add_bytes(ord(input).uint16)

proc add_bytes*(arr: var seq[uint8], input: circuit_kind) =
  arr.add(ord(input).uint8)

proc add_bytes*(arr: var seq[uint8], input: point) =
  arr.add_bytes(input.x)
  arr.add_bytes(input.y)

proc add_bytes*(arr: var seq[uint8], input: seq[int]) =
  arr.add_bytes(input.len)
  for i in input:
    arr.add_bytes(i)

proc add_bytes*(arr: var seq[uint8], input: seq[uint64]) =
  arr.add_bytes(input.len)
  for i in input:
    arr.add_bytes(i)

proc add_bytes*(arr: var seq[uint8], input: string) =
  arr.add_bytes(input.len)
  for c in input:
    arr.add_bytes(ord(c).uint8)

proc add_path*(arr: var seq[uint8], path: seq[point]) =
  #[
    Wire paths encoding rules:
    1. The wire starts with a point: (x: int16, y: int16). 
    2. After this follow 1 or more segments (3 bit direction, 5 bit length)
    3. We end once a 0 length segment is encountered (0 byte)
  ]#

  arr.add_bytes(path[0])

  var offset = 0

  while offset < path.high:
    let original_direction = DIRECTIONS.find(path[offset + 1] - path[offset])

    if original_direction == -1: 
      if path.len == 2:
        # Special case for players who want to generate "teleport" wires
        arr.add_bytes(TELEPORT_WIRE)
        arr.add_bytes(path[1])
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
    arr.add_bytes(segment)

    offset += length

  # Length 0 segment, ends the wire
  arr.add_bytes(0.uint8)

proc add_bytes(arr: var seq[uint8], component: parse_component) =
  arr.add_bytes(component.kind)
  arr.add_bytes(component.position)
  arr.add_bytes(component.rotation)
  arr.add_bytes(component.permanent_id)
  arr.add_bytes(component.custom_string)
  case component.kind:
    of Program1: arr.add_bytes(component.program_name)
    of Program2: arr.add_bytes(component.program_name)
    of Program3: arr.add_bytes(component.program_name)
    of Program4: arr.add_bytes(component.program_name)
    of QwordProgram: arr.add_bytes(component.program_name)
    of Custom:   arr.add_bytes(component.custom_id)
    else: discard

proc add_bytes(arr: var seq[uint8], circuit: parse_circuit) =
  arr.add_bytes(circuit.permanent_id)
  arr.add_bytes(circuit.kind)
  arr.add_bytes(circuit.color)
  arr.add_bytes(circuit.comment)
  arr.add_path(circuit.path)

proc state_to_binary*(save_version: int, components: seq[parse_component], circuits: seq[parse_circuit], nand: uint32, delay: uint32, menu_visible: bool, clock_speed: uint32, nesting_level: uint8, description: string, unpacked: bool, camera_position: point): seq[uint8] =
  var dependencies: seq[int]

  var components_to_save: seq[int]
  for id, component in components:
    if component.kind == Custom and component.custom_id notin dependencies:
      dependencies.add(component.custom_id)

    if component.kind in [CircuitCluster, VirtualCustom]: continue
    if component.kind in VIRTUAL_KINDS: continue
    components_to_save.add(id)

  result.add_bytes(FORMAT_VERSION)
  result.add_bytes(save_version)
  result.add_bytes(nand)
  result.add_bytes(delay)
  result.add_bytes(menu_visible)
  result.add_bytes(clock_speed)
  result.add_bytes(nesting_level)
  result.add_bytes(dependencies)
  result.add_bytes(description)
  result.add_bytes(unpacked)
  result.add_bytes(camera_position)
  result.add_bytes(false) # Has cached design, for custom component lazy loading

  result.add_bytes(components_to_save.len)
  for id in components_to_save:
    result.add_bytes(components[id])

  result.add_bytes(circuits.len)
  for id, circuit in circuits:
    result.add_bytes(circuit)

