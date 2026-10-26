# cli/mod.nu

The CLI, a module loaded as gram: `overlay use -rp equip/sourcetrait/gram/cli
as gram` from nu's library path, then `gram <command>` from anywhere inside
a git work tree, gram working on that repository; `overlay hide gram` takes
it out. The module's directory is `cli`, so a plain `use` would name it
`cli`, while its listing and its help groups look for `gram`. `--reload`
re-reads gram's code, which an overlay binds at parse time.

Each command wraps one library function under the name typed at the command
line: `log last` calls `log latest`, `state last` `state latest`, `state
roll` `state advance`, `states` `state states`, and `ref` `ref resolve`,
`last` and `roll` being builtins a library function never takes. A
one-or-many subject is one argument, a value or a list literal, `gram log
rev foo [3 4]`, a record back for one and a table for a list; nothing reads
`$in`.

Every wrapper imports its library module, `../lib/<concept>`, inside its own
body. A module-level `use` would put a library command beside the wrapper of
the same name, and `log rev` would call itself until nu's recursion limit; a
module file refuses `overlay use`, which could rename the library. The
body's import shadows the wrapper for that body alone.

`ref` and `state roll` take a GramRef braced or braceless, `gram ref
log:foo/bar:32` or `gram ref [log:foo:1 mem:Topic]`, and brace it through
`ref braced`: nu refuses an unquoted braced ref of two or more colons and
reads one of one colon as a record. A ref with a `#` tail still takes
quotes, `#` opening a comment.

`gram` alone lists every command with its summary: the commands of the
module named `gram`, by their declarations in `scope modules`, each named as
the session has it, `gram log rev` under the prefix. nu's `gram --help`
cannot list them, since it looks for subcommands of the def's own name,
`main`, and a module's `main` takes no `--help` of its own; its summary line
points to `gram`. `iter`, `log`, `plan`, `plan new`, and `state` print
nu's help, which lists their subcommands.
