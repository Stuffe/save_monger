# Save monger for package (.pk) file serialization/deserialization
# Package file stores a schematic, together with its custom-component dependencies & programming workspace
# The name of the schematic is the name of the .pk file, for user-friendly renaming
# The content is prefixed with a byte indicating the version of the save format
# The rest of the file is compressed with supersnappy
# The uncompressed data is sectioned as follows:
# - metadata
# - custom components' files (e.g. circuit.data, spec.isa, new_program.asm)
# - supplementary files to main schematic
# - main schematic

import pk_versions/[common, v0]
export common

import save_monger
import libraries/supersnappy/supersnappy

import ../board/schematics
import ../board/custom_prototype_list
import ../model_types

import std/[os, sequtils, sets, strutils]

const LATEST_VERSION = 0'u8

proc deserialize_package*(
    arr: seq[uint8],
    main_schematic_name: string,
    level_overwrite: string = "",
    foundry_overwrite: string = "",
    file_store_mode: PkFileStoreMode = File_NoStore,
): PkDeserResult =
  if arr.len < 1:
    return PkDeserResult(kind: PkDeser_Error_Corrupt)

  try:
    let version = arr[0]
    case version
    of 0:
      return v0.deserialize(arr, main_schematic_name, level_overwrite, foundry_overwrite, file_store_mode)
    else:
      return PkDeserResult(kind: PkDeser_Error_Corrupt)
  except IndexDefect:
    return PkDeserResult(kind: PkDeser_Error_Corrupt)

proc serialize_minimal_package*(path: string, level: string): PkSerResult =
  ## The serialization assumes caller is not malicious
  var (custom_id, components, dependencies) = block BLK_PRELIM_CHECK:
    let path_schematic = path / "circuit.data"
    if not fileExists(path_schematic):
      return PkSerResult(kind: PkSer_Error_MainNotFound)

    let (broken, meta) = get_schematic_safe(path_schematic)
    if broken:
      return PkSerResult(kind: PkSer_Error_MainNotFound)

    var dependencies: seq[int]
    for component in meta.schematic.components:
      if component.kind == com_custom and component.custom_id notin dependencies:
        dependencies.add(component.custom_id)

    (meta.custom_id, meta.schematic.components, dependencies)

  var arr: seq[uint8]
  block BLK_METADATA:
    arr.add_string(level)

  # Find the topological order of the custom components
  var schematics_rev_topo_sorted = block:
    var visited: seq[int]
    visited.add(custom_id)
    while dependencies.len > 0:
      let custom_id = dependencies.pop()
      if custom_id in visited:
        continue
      visited.add(custom_id)

      let prototype = get_custom_prototype(custom_id)
      for component in prototype.schematic.components:
        if component.kind == com_custom and component.custom_id notin visited:
          dependencies.add(component.custom_id)

    visited

  # All schematics are serialized in reverse topological order
  # The schematic at the front is the root schematic & is treated differently
  assert schematics_rev_topo_sorted.len >= 1

  var serialized_files = initStrTrie()
  proc find_files(parent_path: string, components: seq[Component]): seq[string] =
    var has_asm = false
    for component in components:
      if component.kind notin ASSEMBLER_MEMORY:
        continue
      if component.settings.len < 3:
        continue

      let path =
        case initial_data(component)
        of ini_assembler:
          has_asm = true
          component.selected_programs.getOrDefault(level).value
        of ini_punch_card, ini_file, ini_hex_editor, ini_persistent:
          $component.permanent_id & "." & TC_BIN_EXTENSION
        else:
          continue
      if serialized_files.contains(parent_path / path):
        continue

      result.add(path)

    if has_asm:
      result.add("spec.isa")

  let foundry_path = global_save_base_path / "schematics/foundry"
  arr.add_u16(schematics_rev_topo_sorted.len.uint16 - 1)
  while schematics_rev_topo_sorted.len > 1:
    let custom_id = schematics_rev_topo_sorted.pop()
    let prototype = get_custom_prototype(custom_id)
    let parent_path = foundry_path / prototype.path
    let files = find_files(parent_path, prototype.schematic.components)

    arr.add_string(prototype.path)
    arr.add_u16(files.len.uint16)
    for path in files:
      arr.add_string(path)
      arr.add_file(parent_path / path)
    arr.add_string("circuit.data")
    arr.add_file(parent_path / "circuit.data")

  block BLK_MAIN:
    let parent_path = path.strip(leading = false, chars = {'/'})
    let files = find_files(parent_path, components)

    arr.add_u16(files.len.uint16)
    for path in files:
      arr.add_string(path)
      arr.add_file(parent_path / path)
    arr.add_string("circuit.data")
    arr.add_file(parent_path / "circuit.data")

  result.data = LATEST_VERSION & compress(arr)

proc serialize_maximal_package*(path: string, level: string): PkSerResult =
  ## The serialization assumes caller is not malicious
  var (custom_id, dependencies) = block BLK_PRELIM_CHECK:
    let path_schematic = path / "circuit.data"
    if not fileExists(path_schematic):
      return PkSerResult(kind: PkSer_Error_MainNotFound)

    let (broken, meta) = get_schematic_safe(path_schematic)
    if broken:
      return PkSerResult(kind: PkSer_Error_MainNotFound)

    var dependencies: OrderedSet[int]
    for component in meta.schematic.components:
      if component.kind == com_custom:
        dependencies.incl(component.custom_id)

    for path in walkDirRec(path, yieldFilter = {pcDir}):
      let path_schematic = path / "circuit.data"
      if not fileExists(path_schematic):
        continue
      let (broken, meta) = get_schematic_safe(path_schematic)
      if broken:
        continue
      for component in meta.schematic.components:
        if component.kind == com_custom:
          dependencies.incl(component.custom_id)

    (meta.custom_id, dependencies.toSeq())

  var arr: seq[uint8]
  block BLK_METADATA:
    arr.add_string(level)

  # Find the topological order of the custom components
  var schematics_rev_topo_sorted = block:
    var visited: OrderedSet[int]
    visited.incl(custom_id)
    while dependencies.len > 0:
      let custom_id = dependencies.pop()
      if custom_id in visited:
        continue
      visited.incl(custom_id)

      let prototype = get_custom_prototype(custom_id)
      for component in prototype.schematic.components:
        if component.kind == com_custom and component.custom_id notin visited:
          dependencies.add(component.custom_id)

    visited.toSeq()

  # All schematics are serialized in reverse topological order
  # The schematic at the front is the root schematic & is treated differently
  assert schematics_rev_topo_sorted.len >= 1

  var serialized_folders = initPathTrie()
  proc find_files(parent_path: string): seq[string] =
    if serialized_folders.contains(parent_path):
      return

    var dirs: seq[string]
    dirs.add(parent_path)
    while dirs.len > 0:
      let dir_path = dirs.pop()
      for (kind, path) in walkDir(dir_path):
        let path = path.replace("\\", "/")
        case kind
        of pcFile:
          let path = path[parent_path.len + 1 ..^ 1]
          let name = path.extractFilename()
          if name[0] == '.' or (name.startsWith("circuit") and name.endsWith(".data")):
            continue
          result.add(path)
        of pcDir:
          if serialized_folders.contains(path):
            continue
          dirs.add(path)
        else:
          discard
    serialized_folders.insert(parent_path)

  let foundry_path = global_save_base_path / "schematics/foundry"
  arr.add_u16(schematics_rev_topo_sorted.len.uint16 - 1)
  while schematics_rev_topo_sorted.len > 1:
    let custom_id = schematics_rev_topo_sorted.pop()
    let prototype = get_custom_prototype(custom_id)
    let path =
      prototype.path.strip(chars = {'/'}, leading = false)[foundry_path.len + 1 .. ^1]
    let parent_path = foundry_path / path
    let files = find_files(parent_path)

    arr.add_string(path)
    arr.add_u16(files.len.uint16)
    for path in files:
      arr.add_string(path)
      arr.add_file(parent_path / path)
    arr.add_string("circuit.data")
    arr.add_file(parent_path / "circuit.data")

  block BLK_MAIN:
    let parent_path = path.strip(leading = false, chars = {'/'})
    let files = find_files(parent_path)

    arr.add_u16(files.len.uint16)
    for path in files:
      arr.add_string(path)
      arr.add_file(parent_path / path)
    arr.add_string("circuit.data")
    arr.add_file(parent_path / "circuit.data")

  result.data = LATEST_VERSION & compress(arr)
