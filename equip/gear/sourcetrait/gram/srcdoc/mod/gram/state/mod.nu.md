# gram/state/mod.nu

## now, next, latest, and states

`latest` reads `last.yaml`: `last` is a builtin, and a module's definitions
bind across its whole text, as in the log module. Every state is a record
of all three fields: `none`, GramRef's null, reads as a null ptr, and
`file` is null wherever the ptr names no file (User's types). `states`
lists them in the order a roll moves them, next, now, last (User).

## advance and fresh

`advance` is the CLI's `state roll`, `roll` being a builtin. A roll moves
each state one place with its rev, `now` to `last` and `next` to `now`,
and the ptr enters `next` at a new rev, one past the highest of the three,
so each file holds its own rev (User: "each of those should be a
different rev"). `fresh` rolls none into `next` (User: "$ptr can't be
empty or none, that's what fresh is for"). The ptr is checked through `ref
ref_filepath`, so a malformed ref or one naming a missing entry is
refused, and every check comes before the first write. The current files
are opened without resolving their ptrs, so a stale ptr moves on rather
than blocking the roll. Each file is written whole, `last` first, a ptr
single-quoted with its own quotes doubled, then read back.

## open_state and read_state

`open_state` checks a state file: it must parse to a record of an int rev
of at least 1 and a string ptr. A ptr written unquoted, `{log:jab:353}`
bare, is YAML's flow mapping and reads as a record, so it is refused; the
written form quotes it, `'{log:jab:353}'`. `read_state` adds the ptr's
file, so a ptr naming an entry or op that does not exist fails there, in
`ref ref_filepath`, with that index's own message.
