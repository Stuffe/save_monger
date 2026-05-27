import common

import ../libraries/supersnappy/supersnappy
import ../save_monger

import ../../model_types

import std/[os, random, strutils]

const MAX_UNCOMPRESSED_SIZE = 100_000_000 # 100 MB

proc get_file*(arr: seq[uint8], i: var int): seq[uint8] =
  let len = arr.get_u32(i).int
  result = arr[i ..< i + len]
  i += len

proc deserialize*(
    arr: seq[uint8],
    main_schematic_name: string,
    level_overwrite: string,
    foundry_overwrite: string,
    file_store_mode: PkFileStoreMode,
): PkDeserResult =
  result.data.version = 0

  let arr =
    try:
      uncompress(arr[1 .. ^1], MAX_UNCOMPRESSED_SIZE)
    except SnappyError:
      return PkDeserResult(kind: PkDeser_Error_Corrupt)

  var i = 0
  block BLK_METADATA:
    result.data.level = arr.get_string(i)
    if level_overwrite != "":
      result.data.level = level_overwrite

  var custom_id_remap: Table[int, int]
  proc get_file_and_store(parent_path: string, data: var PkDeserData) =
    let num_extra_file = arr.get_u16(i)
    for _ in 0.uint16 .. num_extra_file:
      let name = arr.get_string(i)
      let path = parent_path / name
      var binary = arr.get_file(i)

      if name.startsWith("circuit") and name.endsWith(".data"):
        try:
          var meta = parse_state(binary)
          if meta.custom_id != 0:
            if meta.custom_id notin custom_id_remap:
              custom_id_remap[meta.custom_id] = rand(int.high)
            meta.custom_id = custom_id_remap[meta.custom_id]

          for component in meta.schematic.components.mitems:
            if component.kind == com_custom:
              if component.custom_id notin custom_id_remap:
                custom_id_remap[component.custom_id] = rand(int.high)
              component.custom_id = custom_id_remap[component.custom_id]

          binary = state_to_binary(
            meta.custom_id, meta.schematic, meta.design, meta.gate, meta.delay,
            meta.menu_visible, meta.clock_speed, meta.description, meta.hub_id,
            meta.hub_description,
          )
        except:
          discard

      case file_store_mode
      of File_NoStore:
        data.files_pending_stores.add((path, binary))
      of File_OnOverlap_Overwrite:
        createDir(path.parentDir())

        var file: File
        defer:
          file.close()

        while not file.open(path, fmWrite):
          sleep(1)
        discard file.writeBytes(binary, 0, binary.len)
        data.files_stored.add(path.replace("\\", "/"))

  let level = campaign.levels[result.data.level]
  let level_id = if level.kind == architecture: "architecture" else: level.level_id
  var factory_path = global_save_base_path / "schematics"
  if foundry_overwrite != "":
    factory_path = factory_path / foundry_overwrite
  else:
    factory_path = factory_path / level_id / main_schematic_name

  let num_custom_schematics = arr.get_u16(i)
  for _ in 0.uint16 ..< num_custom_schematics:
    let parent_path = factory_path / arr.get_string(i)
    get_file_and_store(parent_path, result.data)

  block BLK_MAIN:
    let parent_path =
      global_save_base_path / "schematics" / level_id / main_schematic_name
    createDir(parent_path)
    get_file_and_store(parent_path, result.data)
