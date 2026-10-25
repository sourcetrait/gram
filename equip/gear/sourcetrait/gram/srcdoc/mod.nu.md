# gram/mod.nu

The CLI, User's, a module: `cd ~/ai/two; use gram` once a session, or `use
~/ai/two/gram` in config.nu, every command then `gram <command>`. `overlay
use --prefix gram` brings the same names in an overlay of their own,
`overlay hide gram` taking them out, and a plain `overlay use gram` brings
them in bare. `use` binds at parse time, so a change to gram's code takes
another `use gram`.

Each command wraps one library function under the name User types: `log
last` calls `log latest`, `state last` `state latest`, `state roll` `state
advance`, `states` `state states`, and `ref` `ref resolve`, `last` and
`roll` being builtins a library function never takes. A one-or-many subject
is one argument, a value or a list literal, `gram log rev jab [343 344]`, a
record back for one and a table for a list; nothing reads `$in`.

Every wrapper imports its library inside its own body. A module-level `use`
would put a library command beside the wrapper of the same name, and `log
rev` would call itself until nu's recursion limit; a module file refuses
`overlay use`, which could rename the library. The body's import shadows
the wrapper for that body alone.

`ref` and `state roll` take a GramRef braced or braceless, `gram ref
log:jab/fps:32` or `gram ref [log:jab:1 mem:GramLog]`, and brace it through
`ref braced`: nu refuses an unquoted braced ref of two or more colons and
reads one of one colon as a record. A ref with a `#` tail still takes
quotes, `#` opening a comment.

`gram` alone lists every command with its summary: the module's own
commands, by their declarations in `scope modules`, each named as the
session has it, `gram log rev` under `use gram` and `log rev` under a plain
`overlay use gram`. nu's `gram --help` cannot list them, since it looks for
subcommands of the def's own name, `main`, and a module's `main` takes no
`--help` of its own; its summary line points to `gram`. `log`, `plan`,
`plan new`, and `state` print nu's help, which lists their subcommands.
