# lib/iter/mod.nu

## main

An iter's concrete model by its namepath, `foo` or `foo/bar`, either
separator: `iter` its namepath written with `/`, `path` its directory as
`common repo_dir_iter` finds it, `summary` its top iter's `iter.yaml`'s,
the file's own `summary` for a top iter and its entry under `subiters` for
a subiter, and `nest`, a oneof whose shape tells the two apart. A top
iter's is a table of its subiters, each its `sub`, a GramRef,
`{iter:foo/bar}`, its summary, and its directory, held to exist, `[]` where
it has none; a subiter's is a record of its top iter, its `top`,
`{iter:foo}`, its summary, and its directory. A subiter its top iter's file
lists twice or not at all is refused. The subiters are gathered in a loop,
so a listed subiter's missing directory is refused by name. `model iter`
reads it by an iter ref, and `ref resolve` an iter ref's directory and
summary.

## new

A new iter scaffolded at its namepath, `foo` a top iter at `./iter/foo` and
`foo/bar` a subiter at `./iter/foo/sub/bar`, either separator, its
directory refused where it exists. It holds the indices a boot reads, each
`[]`: `info/info.yaml`, `log/log.yaml`, the five pools under `plan/`,
`protocol/protocol.yaml`, `quote/quote.yaml`, `sequence/sequence.yaml`, and
`study/study.yaml`; its state fresh, `last`, `now`, and `next` at revs 1, 2,
and 3, each `ptr: none`; and an empty `bootstrap.md`. A top iter gains its
`iter.yaml`, its summary `To do` and no subiters; a subiter is listed in its
top iter's, `sub` its path under `sub/` and its summary `To do`. Every
refusal comes before the first write. The result names the iter, its
directory, and every file written, the top iter's `iter.yaml` first.

## load

An iter's boot in one call: every file GramBoot reads for it, in GramBoot's
order, each as a `FILE: <path>` line and the file's text, the path from the
repository's root, `./iter/foo/plan/agenda.yaml`. The
result is one page, `{page, remaining, content}`, pages counted from 0 and
`remaining` the pages after this one; a page past the last is refused,
naming how many there are. A boot calls it with page 0 and then each page
`remaining` leaves, and a session reloads its iter the same way right
after a compaction.

## boot_files

GramBoot's repo boot comes first, `any`'s `sequence/sequence.yaml` and
`protocol/protocol.yaml`, then the top iter's `iter.yaml`, then for the top
iter and, where one is named,
its subiter, BOOT_FILES in GramBoot's order: the three states, the log's
index, the understanding's, the five pools, and the protocol and sequence
indices. After them come OPTIONAL_FILES, the indices of the parts an iter
keeps where it has them, `study/study.yaml` and `quote/quote.yaml`, each
read where it exists. Last comes the leaf iter's `bootstrap.md`, GramBoot's
third step: the subiter's where one is named, else the top iter's. A
BOOT_FILES file or a bootstrap that is missing is refused, every one named,
since GramBoot holds those paths guaranteed. `none` is the repo boot alone
and `any` adds its `iter.yaml`; a special iter with a subiter is refused. The memory's index and the environment's are left out:
a harness loads them with its own instructions, before any boot.

## paged and payload

The files are packed into pages in order, each page as many whole files
as fit: a file is never split, so one larger than the limit takes a page
of its own and passes it. A page's size is what the host answers for it,
its content as NUON, every newline and quote escaped, plus PAGE_OVERHEAD,
128 bytes for the page's record and the host's `{nonce, result}`
envelope. MAX_PAYLOAD is 50,000 because Claude Code saves a successful
text result longer than 50,000 characters to a file, whatever its token
count, unless the tool declares `anthropic/maxResultSizeChars`; the size
is counted in UTF-8 bytes, which never undercounts characters. The limit
is a constant until the host's configuration carries it.

## top_index

A subiter's top iter's `iter.yaml`, which `new` rewrites whole, so it is
held to exactly what `to yaml` writes, as a pool file is: one in another
form is refused rather than reformatted. A missing file, one without a
summary, and one already listing the subiter are refused.

## check_categories

A subiter may sit under category directories, `foo/game/arena` at
`./iter/foo/sub/game/arena`; an existing category holding a file is
refused, as `common repo_dir_iter` refuses it on reading.

## read_index

A top iter's `iter.yaml` as `main` reads it, refused missing, without a
`summary`, or with a subiter lacking its `sub` or `summary`. Unlike
`top_index` it takes the file in any form, since nothing is written back.
