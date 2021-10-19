import strutils

const LATEST_SAVE_VERSION* = 1

# The order of this enum determines the order in the component panel
type component_kind* = enum
  Error
  Off
  On
  Buffer
  Not
  And
  And3
  Nand
  Or
  Or3
  Nor
  Xor
  Xnor
  Counter
  VirtualCounter
  QwordCounter
  VirtualQwordCounter
  Ram
  VirtualRam
  QwordRam
  VirtualQwordRam
  Stack
  VirtualStack
  Register
  VirtualRegister
  RegisterRed
  VirtualRegisterRed
  RegisterRedPlus
  VirtualRegisterRedPlus
  QwordRegister
  VirtualQwordRegister
  ByteSwitch
  Mux
  Demux
  BiggerDemux
  ByteConstant
  ByteNot
  ByteOr
  ByteAnd
  ByteXor
  ByteEqual
  ByteLess
  ByteLessU
  ByteLessI
  ByteNeg
  ByteAdd
  ByteAdd2
  ByteMul
  ByteSplitter
  ByteMaker
  QwordSplitter
  QwordMaker
  FullAdder
  BitMemory
  VirtualBitMemory
  SRLatch
  FlipFlop
  Random
  Clock
  WaveformGenerator
  HttpClient
  AsciiScreen
  Keyboard
  FileInput
  Halt
  CircuitCluster
  Screen
  Program1
  Program1Red
  Program2
  Program3
  Program4
  LevelGate
  Input1
  Input2
  Input3
  Input4
  Input1BConditions
  Input1B
  Input1BCode
  Input1_1B
  Output1
  Output1Sum
  Output1Car
  Output1Aval
  Output1Bval
  Output2
  Output3
  Output4
  Output1B
  Output1_1B
  OutputCounter
  InputOutput
  Custom
  VirtualCustom

const virtual_kinds* = [VirtualCustom, VirtualRegister, VirtualQwordRegister, VirtualBitMemory, VirtualCounter, VirtualQwordCounter, VirtualStack, VirtualRam, VirtualQwordRam, VirtualRegisterRedPlus, VirtualRegisterRed]

type circuit_kind* = enum
  ck_bit
  ck_byte
  ck_qword

type point* = object
  x*: int16
  y*: int16

type parse_component* = object
  kind*: component_kind
  position*: point
  rotation*: uint8
  permanent_id*: int
  custom_string*: string

type parse_circuit* = object
  permanent_id*: int
  path*: seq[point]
  kind*: circuit_kind
  color*: uint8
  comment*: string

proc parse_state*(input: string): (seq[parse_component], seq[parse_circuit], uint32, uint32, int) =
  var components: seq[parse_component]
  var circuits:   seq[parse_circuit]

  let parts = input.split("|")
  if parts.len notin [4, 5]:
    #log("Load state broken")
    return
  let version = parseInt(parts[0])
  var nand = 99999.uint32
  var delay = 99999.uint32
  var level_version = 0

  case version:
    of 0: # Still used in many of the levels
      if parts[1] != "":
        let component_strings = parts[1].split(";")
        for comp_string in component_strings:
          var comp_parts = comp_string.split("`")

          if comp_parts.len != 6:
            #log("broken component " & comp_parts.join(", "))
            continue
          
          try:
            components.add(parse_component(
              kind: parseEnum[component_kind](comp_parts[0]),
              position: point(x: parseInt(comp_parts[1]).int16, y: parseInt(comp_parts[2]).int16),
              rotation: parseInt(comp_parts[3]).uint8,
              permanent_id: parseInt(comp_parts[4]), 
              custom_string: comp_parts[5]
            ))
          except:
            #log("Error loading " & comp_parts[0])
            discard

      var next_circuit_id = 1
      if parts[2] != "":
        let circuits_strings = parts[2].split(";")
        
        for circ_string in circuits_strings:
          let circ_parts = circ_string.split("`")

          if circ_parts.len != 4: 
            #log("broken circuit " & circ_parts.join(", "))
            continue

          var path = newSeq[point]()
          var x = 0.int16
          var i = 0
          if circ_parts[3] != "":
            try:
              for n in circ_parts[3].split(","):
                if i mod 2 == 0:
                  x = parseInt(n).int16
                else:
                  path.add(point(x: x, y: parseInt(n).int16))
                i += 1
            except: 
              continue

            circuits.add(parse_circuit(
              permanent_id: next_circuit_id,
              path: path, 
              kind: circuit_kind(parseInt(circ_parts[0])),
              color: parseInt(circ_parts[1]).uint8, 
              comment: circ_parts[2],
            ))

            next_circuit_id += 1

    of 1:
      if parts[1] != "":
        let component_strings = parts[1].split(";")
        for comp_string in component_strings:
          var comp_parts = comp_string.split("`")

          if comp_parts.len != 6:
            #print("broken component " & comp_parts.join(", "))
            continue

          try:
            components.add(parse_component(
              kind: parseEnum[component_kind](comp_parts[0]),
              position: point(x: parseInt(comp_parts[1]).int16, y: parseInt(comp_parts[2]).int16),
              rotation: parseInt(comp_parts[3]).uint8,
              permanent_id: parseInt(comp_parts[4]),
              custom_string: comp_parts[5]
            ))
          except:
            #print("Error loading " & comp_parts[0])
            discard

      if parts[2] != "":
        let circuit_strings = parts[2].split(";")
        
        for circ_string in circuit_strings:
          let circ_parts = circ_string.split("`")

          if circ_parts.len != 5: 
            #log("broken circuit " & circ_parts.join(", "))
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

          circuits.add(parse_circuit(
            permanent_id: parseInt(circ_parts[0]),
            kind: circuit_kind(parseInt(circ_parts[1])),
            color: parseInt(circ_parts[2]).uint8, 
            comment: circ_parts[3],
            path: path, 
          ))

      if parts[3] != "":
        try:
          var scores = parts[3].split(",")
          nand = parseInt(scores[0]).uint32
          delay = parseInt(scores[1]).uint32
        except: discard

      if parts.len == 5 and parts[4] != "":
        level_version = parseInt(parts[4])

    else: discard

  return (components, circuits, nand, delay, level_version)

proc parse_state_to_string*(parse_components: seq[parse_component], parse_circuit: seq[parse_circuit], nand: uint32, delay: uint32, level_version: int): string =
  var component_strings: seq[string]
  var circuit_strings: seq[string]

  for component in parse_components:
    if component.kind in [CircuitCluster, VirtualCustom]: continue
    if component.kind in virtual_kinds: continue
    component_strings.add(
      @[$component.kind,
      $component.position.x,
      $component.position.y,
      $component.rotation,
      $component.permanent_id,
      component.custom_string].join("`")
    )

  for circuit in parse_circuit:
    var path = newSeq[string]()

    for point in circuit.path:
      path.add($point.x)
      path.add($point.y)

    circuit_strings.add(
      @[$circuit.permanent_id,
      $ord(circuit.kind),
      $circuit.color,
      circuit.comment,
      path.join(",")].join("`")
    )

  return $LATEST_SAVE_VERSION & "|" & component_strings.join(";") & "|" & circuit_strings.join(";") & "|" & $nand & "," & $delay & "|" & $level_version
