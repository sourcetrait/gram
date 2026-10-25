# rig/mod.nu

The rig, gram's calls for an MCP, installed with the lib from this equip:
`sourcetrait/gram:<module>:<call>`, each call one CLI command over the same
library function, run on the git work tree the host's working directory sits
in.

A call is a module whose `main` becomes a command of its name in its parent,
so a call takes the library's name where the CLI's is a builtin: `log
latest`, `state latest`, and `state advance`. The CLI's bare `sequence` and
`protocol` are each a module's own command, so a lookup by name is `lookup`,
and the CLI's `ref` is `ref resolve`, braced or braceless. A call takes one
subject and returns one record: the CLI's list forms stay the CLI's, and a
roll's new rev rides in `{rev}`.
