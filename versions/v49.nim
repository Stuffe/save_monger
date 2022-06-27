import strutils, random
import ../common

func to_string(str: seq[uint8]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, chr(ch))

proc parse*(bytes: seq[uint8], meta_only: bool, solution: bool, parse_result: var parse_result) =
  let parts = bytes.to_string.split("|")
  if parts.len notin [4, 5]:
    return

  if parts[3] != "":
    try:
      var scores = parts[3].split(",")
      parse_result.gate = parseInt(scores[0])
      parse_result.delay = parseInt(scores[1])
    except: discard

  if parts.len == 5 and parts[4] != "":
    parse_result.save_id = parseInt(parts[4])

  if not meta_only:
    if parts[1] != "":
      let component_strings = parts[1].split(";")
      for comp_string in component_strings:
        var comp_parts = comp_string.split("`")

        if comp_parts.len != 6:
          continue

        try:
          parse_result.components.add(parse_component(
            kind: parseEnum[component_kind](comp_parts[0]),
            position: point(x: parseInt(comp_parts[1]).int16, y: parseInt(comp_parts[2]).int16),
            rotation: parseInt(comp_parts[3]).uint8,
            permanent_id: parseInt(comp_parts[4]).uint32.int,
            custom_string: comp_parts[5]
          ))
          if parse_result.components[^1].kind == Custom:
            try:
              parse_result.components[^1].custom_id = parseInt(comp_parts[5])
            except:
              parse_result.components[^1].custom_id = rand(int.high.int)
        except:
          discard

    if parts[2] != "":
      let wire_strings = parts[2].split(";")
      
      for circ_string in wire_strings:
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

        parse_result.wires.add(parse_wire(
          kind: wire_kind(parseInt(circ_parts[1])),
          color: parseInt(circ_parts[2]).uint8, 
          comment: circ_parts[3],
          path: path, 
        ))