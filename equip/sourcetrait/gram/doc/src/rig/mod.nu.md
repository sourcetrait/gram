# rig/mod.nu

The rig, gram's calls for an MCP, installed with the lib from this equip:
`sourcetrait/gram:<module>:<call>`, or `gram:<module>:<call>` where the MCP
names gram a builtin, each call one CLI command over the same library
function, run on the git work tree the host's working directory sits in.

The rig mirrors the CLI, so the API reads the same through either: `get` and
`new` are modules whose calls are the kinds, `gram:get:iter` and
`gram:new:campaign`, with `log`'s `prune` and `state`'s `advance` and
`fresh` under their kinds. A call is a module whose `main` becomes a command
of its name in its parent, so a call takes the library's name where the
CLI's is a builtin, `state advance` for `state roll`, and the CLI's `ref` is
`ref resolve`. A roll's new rev rides in `{rev}`.

The CLI's singular and plural are one call here, which takes a list and
answers a table: a get takes its refs, `{refs}`, and answers its kind's
models in the order asked under the kind's plural, `{iters}`, `{logs}`,
`{campaigns}`, `{tasks}`, `{sequences}`, `{protocols}`, or `{states}`, as
`ref resolve` answers `{refs}`, since a call answers a record. A list of
one is the single case, so no call is added for it and none takes
`info()`'s room twice.

A new takes its subjects the same way and answers what each made under the
same plural: `new iter` a list of namepaths, `{iters}`, and `new log`, `new
campaign`, and `new task` a table of each one's arguments, `{logs}`,
`{campaigns}`, and `{tasks}`. They are made in order, each refused before
its own first write, so a refusal stops the rest with the earlier ones
made. `log prune`, `state advance`, and `state fresh` keep their one
subject, being of special use.
