proc get_bool*(input: openArray[uint8], i: var int): bool =
  result = input[i] != 0
  i += 1

proc get_u64*(input: openArray[uint8], i: var int): uint64 =
  result =
    cast[uint64](input[i + 0]) shl 0 or cast[uint64](input[i + 1]) shl 8 or
    cast[uint64](input[i + 2]) shl 16 or cast[uint64](input[i + 3]) shl 24 or
    cast[uint64](input[i + 4]) shl 32 or cast[uint64](input[i + 5]) shl 40 or
    cast[uint64](input[i + 6]) shl 48 or cast[uint64](input[i + 7]) shl 56
  i += 8

proc get_i64*(input: openArray[uint8], i: var int): int64 =
  result = cast[int64](get_u64(input, i))

proc get_u32*(input: openArray[uint8], i: var int): uint32 =
  result =
    cast[uint32](input[i + 0]) shl 0 or cast[uint32](input[i + 1]) shl 8 or
    cast[uint32](input[i + 2]) shl 16 or cast[uint32](input[i + 3]) shl 24
  i += 4

proc get_i32*(input: openArray[uint8], i: var int): int32 =
  result = cast[int32](get_u32(input, i))

proc get_u16*(input: openArray[uint8], i: var int): uint16 =
  result = input[i + 0].uint16 shl 0 + input[i + 1].uint16 shl 8
  i += 2

proc get_i16*(input: openArray[uint8], i: var int): int16 =
  result = cast[int16](get_u16(input, i))

proc get_u8*(input: openArray[uint8], i: var int): uint8 =
  result = input[i]
  i += 1

proc get_i8*(input: openArray[uint8], i: var int): int8 =
  result = cast[int8](input[i])
  i += 1

proc get_long_seq_u8*(input: openArray[uint8], i: var int): seq[uint8] =
  var len = get_u32(input, i).int
  var j = 0
  while j < len:
    result.add(get_u8(input, i))
    j += 1

proc get_seq_u8*(input: openArray[uint8], i: var int): seq[uint8] =
  var len = get_u16(input, i).int
  var j = 0
  while j < len:
    result.add(get_u8(input, i))
    j += 1

proc get_seq_u64*(input: openArray[uint8], i: var int): seq[uint64] =
  var len = get_u16(input, i).int
  var j = 0
  while j < len:
    result.add(get_u64(input, i))
    j += 1

proc get_string*(input: openArray[uint8], i: var int): string =
  let len = get_u16(input, i)
  var j = 0'u16
  while j < len:
    result.add(chr(get_u8(input, i)))
    j += 1

proc add_bool*(arr: var seq[uint8], input: bool) =
  arr.add(input.uint8)

proc add_u64*(arr: var seq[uint8], input: uint64) =
  arr.add(cast[uint8](input shr 0))
  arr.add(cast[uint8](input shr 8))
  arr.add(cast[uint8](input shr 16))
  arr.add(cast[uint8](input shr 24))
  arr.add(cast[uint8](input shr 32))
  arr.add(cast[uint8](input shr 40))
  arr.add(cast[uint8](input shr 48))
  arr.add(cast[uint8](input shr 56))

proc add_i64*(arr: var seq[uint8], input: int64) =
  add_u64(arr, cast[uint64](input))

proc add_u32*(arr: var seq[uint8], input: uint32) =
  arr.add(cast[uint8](input shr 0))
  arr.add(cast[uint8](input shr 8))
  arr.add(cast[uint8](input shr 16))
  arr.add(cast[uint8](input shr 24))

proc add_i32*(arr: var seq[uint8], input: int32) =
  add_u32(arr, cast[uint32](input))

proc add_u16*(arr: var seq[uint8], input: uint16) =
  arr.add(cast[uint8](input shr 0))
  arr.add(cast[uint8](input shr 8))

proc add_i16*(arr: var seq[uint8], input: int16) =
  arr.add(cast[uint8]((input shr 0) and 0xff))
  arr.add(cast[uint8]((input shr 8) and 0xff))

proc add_u8*(arr: var seq[uint8], input: uint8) =
  arr.add(input)

proc add_i8*(arr: var seq[uint8], input: int8) =
  arr.add(cast[uint8](input))

proc add_long_seq_u8*(arr: var seq[uint8], input: openArray[uint8]) =
  arr.add_u32(input.len.uint32)
  for i in input:
    arr.add_u8(i)

proc add_seq_u8*(arr: var seq[uint8], input: openArray[uint8]) =
  arr.add_u16(input.len.uint16)
  for i in input:
    arr.add_u8(i)

proc add_seq_u64*(arr: var seq[uint8], input: seq[uint64]) =
  arr.add_u16(input.len.uint16)
  for i in input:
    arr.add_u64(i)

proc add_string*(arr: var seq[uint8], input: string) =
  arr.add_u16(input.len.uint16)
  for c in input:
    arr.add_u8(ord(c).uint8)

when isMainModule:
  var arr: seq[uint8]
  var i = 0

  block BLK_BOOL:
    for x in [true, false]:
      arr.add_bool(x)
      assert arr.get_bool(i) == x

  block BLK_U8:
    for x in [1'u8, 2, 3, 0, 255]:
      arr.add_u8(x)
      assert arr.get_u8(i) == x

  block BLK_I8:
    for x in [1'i8, -2, 3, 0, -128, 127]:
      arr.add_i8(x)
      assert arr.get_i8(i) == x

  block BLK_U16:
    for x in [1'u16, 2, 3, 0, 65535]:
      arr.add_u16(x)
      assert arr.get_u16(i) == x

  block BLK_I16:
    for x in [1'i16, -2, 3, 0, -32768, 32767]:
      arr.add_i16(x)
      assert arr.get_i16(i) == x

  block BLK_U32:
    for x in [1'u32, 2, 3, 0, 4294967295'u32]:
      arr.add_u32(x)
      assert arr.get_u32(i) == x

  block BLK_I32:
    for x in [1'i32, -2, 3, 0, -2147483648, 2147483647]:
      arr.add_i32(x)
      assert arr.get_i32(i) == x

  block BLK_U64:
    for x in [1'u64, 2, 3, 0, 18446744073709551615'u64]:
      arr.add_u64(x)
      assert arr.get_u64(i) == x

  block BLK_I64:
    for x in [1'i64, -2, 3, 0, -9223372036854775808, 9223372036854775807]:
      arr.add_i64(x)
      assert arr.get_i64(i) == x

  block BLK_SEQ_U8:
    for x in [@[1'u8, 2, 3, 0, 255], @[7'u8, 5, 18, 187, 255]]:
      arr.add_seq_u8(x)
      assert arr.get_seq_u8(i) == x

  block BLK_LONG_SEQ_U8:
    for x in [@[1'u8, 2, 3, 0, 255], @[7'u8, 5, 18, 187, 255]]:
      arr.add_long_seq_u8(x)
      assert arr.get_long_seq_u8(i) == x

  block BLK_SEQ_U64:
    for x in [
      @[1'u64, 2, 3, 0, 18446744073709551615'u64],
      @[256'u64, 1656, 4674737095'u64, 0, 18446744073709551615'u64],
    ]:
      arr.add_seq_u64(x)
      assert arr.get_seq_u64(i) == x

  block BLK_STRING:
    for x in ["", "hello", "hello world", "\b\0\n\r\t\f\v"]:
      arr.add_string(x)
      assert arr.get_string(i) == x

  echo arr
