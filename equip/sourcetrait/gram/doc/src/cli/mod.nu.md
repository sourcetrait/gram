# cli/mod.nu

The CLI, a module loaded as gram: `overlay use -rp equip/sourcetrait/gram/cli
as gram` from nu's library path, then `gram <command>` from anywhere inside
a git work tree, gram working on that repository; `overlay hide gram` takes
it out. The module's directory is `cli`, so a plain `use` would name it
`cli`, while its listing and its help groups look for `gram`. `--reload`
re-reads gram's code, which an overlay binds at parse time.

A command leads with its verb: `get <kind>` reads a kind's concrete model,
`new <kind>` scaffolds one, and `ref` reads any GramRef's generic model, its
`actual` the kind's own part where it has one; `log prune`, `state roll`,
and `state fresh`, neither a get nor a new, stay under their kind. Each
wraps one library function: `get iter` calls `iter`, `get log` `log`, `get
campaign` and `get task` `plan campaign` and `plan task`, `get state` `state
states`, `get sequence` `sequence`, and `get protocol` `protocol`; `new
iter` calls `iter new`, `new log` `log new`, and `new campaign` and `new
task` `plan new campaign` and `plan new task`; `state roll` calls `state
advance`, `roll` being a builtin a library function never takes; and `ref`
calls `ref resolve`. A one-or-many subject is one argument, a value or a
list literal, `gram get log foo [3 4]`, a record back for one and a table
for a list; `get log` with no rev reads the newest entry. Nothing reads
`$in`.

Every wrapper imports its library module, `../lib/<concept>`, inside its own
body. A module-level `use` would put a library command beside the wrapper of
the same name, and `log prune` would call itself until nu's recursion limit;
a module file refuses `overlay use`, which could rename the library. The
body's import shadows the wrapper for that body alone.

A library module a wrapper's body imports is parsed inside this module's
scope, so this module's commands bind there too: a `get <kind>` command
takes any `get` of a field that kind names, and `get iter` in a library is
this module's `get iter`, a parse failure on its missing argument when
measured. A library reads such a field by its cell path, `($row).iter`. No
command is named `get` alone, which would take every `get`; `new`, `log`,
and `state` print nu's help, which lists their subcommands.

`ref` and `state roll` take a GramRef braced or braceless, `gram ref
log:foo/bar:32` or `gram ref [log:foo:1 mem:Topic]`, and brace it through
`ref braced`: nu refuses an unquoted braced ref of two or more colons and
reads one of one colon as a record. A ref with a `#` tail still takes
quotes, `#` opening a comment.

`gram` alone lists every command with its summary: the commands of the
module named `gram`, by their declarations in `scope modules`, each named as
the session has it, `gram get log` under the prefix. nu's `gram --help`
cannot list them, since it looks for subcommands of the def's own name,
`main`, and a module's `main` takes no `--help` of its own; its summary line
points to `gram`.
