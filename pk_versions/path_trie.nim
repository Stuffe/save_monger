import std/[options, strutils, tables]

type PathTrieNode* = ref object
  children: Option[Table[string, PathTrieNode]]

type PathTrie* {.requiresInit.} = object
  root: PathTrieNode

proc initPathTrie*(): PathTrie =
  PathTrie(root: PathTrieNode(children: some(initTable[string, PathTrieNode]())))

proc contains*(trie: PathTrie, path: string): bool =
  var node = trie.root
  for part in path.split({'/', '\\'}):
    node = node.children.get().getOrDefault(part, nil)
    if node == nil:
      return false
    if node.children.isNone:
      return true
  false

proc insert*(trie: var PathTrie, path: string) =
  var node = trie.root
  var parts = path.rsplit({'/', '\\'})
  if parts.len == 0:
    return

  while parts.len > 1:
    if node.children.isNone:
      return
    let part = parts.pop()
    node = node.children.get().mgetOrPut(part, initPathTrie().root)

  if node.children.isNone:
    return
  let part = parts.pop()
  node.children.get()[part] = PathTrieNode()
