# lib/quote/mod.nu

GramQuote: an iter's `quote/`, a user's words kept once and cited by
`{quote:<iter>:<Name>}` everywhere else. `quote/quote.yaml` is its index,
an item a quote, `quote` its name and `summary` the intention it records;
`quote/<Name>.md` holds the words, and a quote's sub-quotes sit in a
same-named directory, `quote/<Name>/<Sub>.md`, as a ConceptTree lays out
its concepts. A pruned quote moves to `old/quote/`, the same tree with its
own `quote.yaml`, since quotes carry no revs to shard by.

## main and lookup

A quote by its iter and name, a record, or a table for a list of names.
A name is CamelCase parts joined by `/`, held to that shape before a path
is built from it. `lookup` reads `quote/quote.yaml` and `old/quote/quote.yaml`
once each (`homes`), an absent index read as empty, and finds each name in
one of them (`one_held`): listed in neither, twice in one, or in both is
refused by name. Every file found is checked at once through `common
require_files`. A GramRef names a quote, never a path, so a prune changes
no reference: `ref resolve` reads a pruned quote from `old/quote/`.
`new` and `prune` read through `lookup`, so the module never calls its own
`main`.

## new

The summary is checked first by `common check_summary`, then the name's
shape. Every refusal comes before the first write: a name listed live or
archived, a sub-quote whose parent is not a live quote, a stub that
exists, a summary that would not read back through YAML, and an index not
as `to yaml` writes it. The stub is written before the index, so the index
never names a missing file. The index is rewritten whole, sorted by name,
so a quote's sub-quotes follow it; the new entry is read back through
`lookup` and its summary compared with the one given. The stub's title is
the name's last part as prose (`title_of`): its words split at their
capitals, a run of capitals kept as one word, every word but the first
lowercased unless it is such a run. A title the split reads wrongly is
edited in the file.

## prune

The quotes the iter's own documents no longer cite leave `quote/` for
`old/quote/`. A document is any file under the iter but its `quote/`, its
`old/`, and its subiters' `sub/`, each scanned for `{quote:...}` tokens
naming this iter in either separator (`cited`); a citation from another
iter or from the memory keeps nothing live, since a pruned quote still
resolves. A top quote moves with its whole subtree, and only when no quote
in that subtree is cited (`in_tree`), so both trees stay well formed: a
cited sub-quote keeps its parent live, and no archived sub-quote lacks its
parent. Every refusal comes before the first write: an index either side
not as `to yaml` writes it, a moving quote's file missing, its file or its
entry already archived, and a file in a moving subtree's directory that no
entry names. Then each file is copied and its copy's SHA-256 held to its
source's, the archived index takes the entries sorted, the live index is
rewritten without them and read back, each source is removed after its
copy is checked again, each emptied subtree directory goes, and the moved
quotes are read back through `lookup` from `old/quote/`. It runs when I
choose, not on a count, as the log's prune does.

## named

A quote ref's body split into its iter and its name: the iter the leading
lowercase parts in either separator, `foo/bar` or `foo:bar`, written back
with `/`, and the name the first part opening in a capital, any `#` tail
dropped. `ref resolve`, `model quote`, and `cited` split a quote ref this
one way.
