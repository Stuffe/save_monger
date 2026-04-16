import std/[strutils, tables]

type StrTrieNode* = ref object
  is_leaf: bool
  children: Table[string, StrTrieNode]

type StrTrie* {.requiresInit.} = object
  root: StrTrieNode

proc initStrTrie*(): StrTrie =
  StrTrie(root: StrTrieNode())

proc contains*(trie: StrTrie, path: string): bool =
  var node = trie.root
  for part in path.split({'/', '\\'}):
    node = node.children.getOrDefault(part, nil)
    if node == nil:
      return false
  node.is_leaf

proc insert*(trie: var StrTrie, path: string) =
  var node = trie.root
  for part in path.split({'/', '\\'}):
    node = node.children.mgetOrPut(part, StrTrieNode())
  node.is_leaf = true
