# lib/log/mod.nu

`common` and `repo` are imported by relative paths, which nushell resolves
against the importing file, so they are found wherever gram is loaded from.

## latest

Named `latest` rather than `last`: `last` is a builtin, and a module's
definitions bind across its whole text, so an `export def last` would take
the module's own `$items | last`, a parse failure on the shadowing
definition's missing argument when measured. The CLI's `log last` keeps
the name `last` and calls this.

## rev

A rev is read from `log/log.yaml` when it lists it, else from the rev's
shard under `old/log/` (`shard_dir`), that shard's own `log.yaml` and
`<rev>.md`. Each index is read once, and a missing one reads as empty. A
GramRef names a rev, never a path, so archiving entries into their shards
changes no reference. A rev under 1 is refused first. Every rev no index
lists and every rev an index lists twice is named in one error with the
places looked in, before any entry is built; the revs are a counter with no
reuse, so a repeat means the index is broken. `oneof<int, list<int>>` keeps
the int first: an int member, unlike a string, never takes a list literal's
text.

## prune

Every entry but the newest KEPT, 20, leaves `log/` for its shard, so the
log's index stays short enough to read whole while `latest` and `new` still
read it alone; run whenever the index holds 50 or more. Every refusal comes
before the first write: an index `to yaml` would rewrite differently, one
out of rev order, a missing entry file, an entry already in its shard, a
shard index listing a rev at or past the first one moving into it, and a
shard index not ending with a newline. Then each entry is copied and its
copy's SHA-256 held to its source's, each shard's index takes its items,
created where absent, the log's index is rewritten with the kept items and
read back, and only then is each source removed, its copy checked again;
so at every step each index names files that exist, and every rev reads.
The moved revs are read back through `rev` from their shards.

## shard_dir

The rev's thousand's range, then its hundred's, each `<first>-<last>`, under
`old/log/`: rev 112 sits in `old/log/1-1000/101-200`, so a shard's name says
which revs it holds.

## new

The summary is checked before anything is read, by `common check_summary`.
The new rev is the index's last plus one. Every refusal comes before the
first write: the stub's file must be absent, the item must read back as
written through YAML (`to yaml` quotes a summary that needs it), and an
index being appended to must end with a newline. The stub is written
before the index item, so the index never names a missing file. The item
is appended as text, so every earlier item keeps its bytes; an index that
reads as empty is written whole. The entry returned is `rev`'s read of the
index after the write, its summary compared with the one given.

## entries

The entries are built first, each in the directory its index sits in, and
their files checked after, through `common require_files`, so every
missing file is named in one message.
