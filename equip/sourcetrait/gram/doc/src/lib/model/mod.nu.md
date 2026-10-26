# lib/model/mod.nu

Each kind's concrete model by its GramRef, read by the CLI's `get` and
`list` and the rig's `get` calls: `iter`, `log`, `campaign`, `task`,
`sequence`, `protocol`, and `state`, each taking a braced ref or a list of
them and answering a record for one and a table in the order asked for a
list. A ref of another kind is refused by name: an iter's model and its
state take an iter ref, a log entry a log ref, a campaign and a task a plan
ref, the campaign's namepath its name alone and the task's its campaign's
and its own, and a sequence and a protocol their own kinds, the older `seq`
and `proto` among them. Each reads through its concept's module, `iter`,
`log rev`, `plan campaign` and `plan task`, `sequence`, `protocol`, and
`state states`, a ref's body split by `ref kind_body` and `ref
iter_and_name`, so a kind's checks keep one home.

Each function is named for its kind and imports its concept's module inside
its own body, where the import shadows the function of the same name; a
module-level import would put the concept's command beside the function,
which would then call itself. The refs are read in a loop rather than a
closure, so a refused ref's own message is the error.
