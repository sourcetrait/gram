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
reads it by an iter ref, and `ref resolve` gives an iter ref this nest as
its `actual`.

## new

A new iter scaffolded at its namepath, `foo` a top iter at `./iter/foo` and
`foo/bar` a subiter at `./iter/foo/sub/bar`, either separator, its
directory refused where it exists. It holds the indices a boot reads, each
`[]`: `info/info.yaml`, `log/log.yaml`, the five pools under `plan/`,
`protocol/protocol.yaml`, `sequence/sequence.yaml`, and
`study/study.yaml`; its state fresh, `last`, `now`, and `next` at revs 1, 2,
and 3, each `ptr: none`; and an empty `bootstrap.md`. A top iter gains its
`iter.yaml`, its summary `To do` and no subiters; a subiter is listed in its
top iter's, `sub` its path under `sub/` and its summary `To do`. Every
refusal comes before the first write. The result names the iter, its
directory, and every file written, the top iter's `iter.yaml` first.

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
