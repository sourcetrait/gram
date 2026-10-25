# gram/ref/mod.nu

## ref_filepath

`located`'s path alone, the file a ref names; `state` holds a roll's ptr to
it, so a ptr naming a missing file is refused.

## resolve

Each ref as `located` reads it, its path and its summary beside it: a
record for one ref, a table in the given order for a list, and nothing
nested, no tasks and no `apply`. The refs are read in a loop rather than a
closure, so a refused ref's own message is the error. `oneof<list<string>,
string>` keeps the list first, as `protocol` and `sequence` do.

## braced and braceless

The two forms a GramRef is written in: braced, `{log:jab/fps:32}`, the one
every store and the library take, and braceless, `log:jab/fps:32`, which
nu's parser reads as a plain string where it refuses an unquoted braced
ref of two or more colons and reads one of one colon as a record. Each
takes either form and returns its own, a string for one ref and a list in
order for a list, `none` as itself; anything else is refused. The CLI
braces what it is given before the library sees it.

## one_braced

A ref already braced, or `none`, comes back as it is; a braceless one, a
lowercase kind, a colon, then a body without braces, gains its braces.

## located

A GramRef is `{kind:body}`. `none`, GramRef's null, names no file and has
no summary, and neither has a kind with no file to find, a `url`, a
`journal`, an `infer` or an `env` value. The kinds held: `log`, `protocol`,
`sequence`, `mem`, `info`, `study`, `plan`, and `file`, with `proto` and
`seq` read as `protocol` and `sequence` for the log entries that carry
them. A log, protocol, or sequence ref resolves through the log, protocol,
and sequence modules, so each index's checks keep one home: the entry
listed once and its file present; its summary is that entry's. Their body
splits at its last colon, so the iter takes either namepath separator,
`jab/fps` or `jab:fps`.

An info ref names a GramInfo concept, `{info:jab/kernel:Display}`, the
iter first, then the concept's path, then any header anchors, and a
`#a-b` line range last. The iter is the leading lowercase parts and the
concept the first part opening in a capital, since an iter's namepath is
lowercase and a concept's name CamelCase; the anchors and the range name
places in the file, so the file alone is returned. Every info ref names
its iter, the referring file's own included, so one with none,
`{info:Machine/Line}`, is refused. Its summary is its concept entry's in
the iter's `info/info.yaml`, which lists every concept, so a concept it
lacks is refused.

A study ref names a concept of a GramStudy study,
`{study:jab/fps:fame/QuakeTwo:Render/Cpu}`: the iter, then the study's
namepath, snake_case directories ending in a ConceptName, then the
concept's path, then any GramRefTail. The iter is the leading lowercase
parts as in an info ref, the study the part after it, and the concept the
next, each held to its shape before a path is built; the file is the
concept's under the iter's `study/` and the study's namepath. A ref missing
its iter, its study, or its concept is refused. Its summary is its concept
entry's in the study's own `info.yaml`, which lists every concept of the
study, so a concept it lacks is refused.

A memory ref names a concept of the memory tree by its path under `mem/`,
`{mem:GramIter}` or `{mem:Layout/Home}`, CamelCase parts joined by
`/`. A GramRefTail after it, a `#a-b` range or a section's headers after a
colon, names a place in the file, so the file alone is returned. The path
is held to that shape before a path is built from it, so no ref leaves
`mem/`. Its summary is its entry's in `mem/mem.yaml`.

A file ref's path is returned as it is written, its tail dropped, held to
exist: `./` and a bare path from the repository's root, `~/` from home.
It has no summary.

## plan_located

A plan ref's body is its iter, then the plan namepath, which opens in a
campaign's capital; a body with none is a whole iter's tasking, its path
the iter's `plan/` and no summary. A campaign's path and summary are `plan
campaign`'s; a task's summary is `plan task`'s, and its path the nearest
file holding it: its own, else its parent task's, up to its campaign's.

## indexed_summary and listed_summary

An index's one item whose key names the entry, its summary; an entry listed
twice is refused by both. `indexed_summary` refuses an entry the index
lacks, and `listed_summary` reads it as nothing.
