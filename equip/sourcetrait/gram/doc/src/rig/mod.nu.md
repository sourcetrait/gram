# rig/mod.nu

The rig, gram's calls for an MCP, installed with the lib from this equip:
`sourcetrait/gram:<module>:<call>`, or `gram:<module>:<call>` where the MCP
names gram a builtin, each call one CLI command over the same library
function, run on the git work tree the host's working directory sits in.

A call is a module whose `main` becomes a command of its name in its parent,
so a call takes the library's name where the CLI's is a builtin: `log
latest`, `state latest`, and `state advance`. The CLI's bare `sequence` and
`protocol` are each a module's own command, so a lookup by name is `lookup`,
and the CLI's `ref` is `ref resolve`, braced or braceless. A roll's new rev
rides in `{rev}`.

The CLI's one-or-many subjects take a list here, `log rev`'s `revs`, `ref
resolve`'s `refs`, and the lookups' `sequences` and `protocols`: a list where
the subject is a scalar, as each of these is, and a table where it is a
record. Each answers a table of the single's records, in the order asked,
inside a record, since a call answers a record. A list of one is the single
case, so no call is added for it and none takes `info()`'s room twice.
