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

The CLI's one-or-many subjects take a list here, `get log`'s `revs`, `ref
resolve`'s `refs`, and `get sequence`'s `sequences` and `get protocol`'s
`protocols`: a list where the subject is a scalar, as each of these is, and
a table where it is a record. Each answers a table of the single's records,
in the order asked, inside a record, since a call answers a record. A list
of one is the single case, so no call is added for it and none takes
`info()`'s room twice. `get log`'s empty `revs` reads the newest entry
alone, as the CLI's `get log` with no rev.
