import path_trie
export path_trie

import str_trie
export str_trie

import ../../model_types

import std/os

type PkScoreNeeded* {.pure.} = enum
  NoScore
  YesScore

type PkCustomSaveMode* {.pure.} = enum
  Custom_NoSave
  Custom_OnOverlap_Skip
  Custom_OnOverlap_Overwrite
  Custom_OnOverlap_NewIdSelf

type PkFileStoreMode* {.pure.} = enum
  File_NoStore
  File_OnOverlap_Overwrite

type PkDeserResult_Kind* {.pure.} = enum
  Success
  Error_Corrupt

type PkDeserData* = object
  version*: uint8
  level*: string
  scores*: seq[tuple[kind: ComponentKind, gate: int, delay: int]]
  files_pending_stores*: seq[tuple[path: string, data: seq[uint8]]]
  files_stored*: seq[string]

type PkDeserResult* = object
  case kind*: PkDeserResult_Kind
  of Success:
    data*: PkDeserData
  else:
    discard

type PkSerResult_Kind* {.pure.} = enum
  PkSer_Success
  PkSer_Error_MainNotFound

type PkSerResult* = object
  case kind*: PkSerResult_Kind
  of PkSer_Success:
    data*: seq[uint8]
  of PkSer_Error_MainNotFound:
    discard

proc add_file*(arr: var seq[uint8], path: string) =
  # Since the game loads files from 2 different threads, we can't assume the file isn't locked (on Windows)
  var file: File
  defer:
    file.close()

  while true:
    if not fileExists(path):
      arr.add_u32(0)
      return

    if file.open(path):
      break

    sleep(1)

  let num_byte_to_read = getFileSize(file)
  arr.add_u32(num_byte_to_read.uint32)
  if num_byte_to_read == 0:
    return

  let old_len = arr.len
  arr.setLen(old_len + num_byte_to_read)
  discard file.readBytes(arr, old_len, num_byte_to_read)
