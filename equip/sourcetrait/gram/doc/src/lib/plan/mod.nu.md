# lib/plan/mod.nu

## campaign

The entry keeps its own fields, its tasks read by `child_tasks`; an entry
with no stage reads as criteria, and one with no tasks has none. The
campaign's file is checked to exist.

## task

The plan namepath is the campaign, then each task down the tree,
`Campaign/Task/Subtask`, each part held to letters, digits, `_`, and `-`,
and at least two parts (`task_names`). The walk goes through the campaign's
index entry, a name missing or listed twice among its siblings refused with
the path walked so far (`walk_tasks`). A task's file sits at its namepath
under the pool, but not every task has one, its details then in its campaign's
file, so `file` is null where none is held. Its stage and tasks are read as
`campaign` reads them.

## new campaign and new task

A new entry carries the summary given and `stage: criteria`, a task's under
its parent's `tasks`, added when the parent has none (`add_task`). Every
refusal comes before the first write: a summary `common check_summary`
refuses, checked first, an unknown pool, a campaign name any pool lists or
a completed campaign holds, a task named as its parent, campaign or task, a
missing parent, a task name its siblings hold, and a stub file already
present. A task's name may recur further down its campaign,
`Something/Plan/Something/Plan`. The stub, `# CAMPAIGN: <name>` or
`# TASK: <name>`, is written before the pool, so the pool never names a
missing file. Each returns what `campaign` or `task` reads back.

## child_tasks

An entry's tasks are its children as index entries, each its name, its
summary, and its stage, criteria where none is written, as the entry's own.
A child's own tasks are left to its `task`: a pool's tree runs as deep as its
work, and a call's result type is finite, every field declared at every
depth, so a child carried whole could not be typed.

## read_pool and write_pool

A pool is rewritten whole through `to yaml`, never patched as text, so a
pool file must already be exactly what `to yaml` writes, its summaries
within 80 characters and quoted only where YAML needs it; one that is not
is refused before anything changes, since rewriting it would reformat
lines no one asked to touch. The text written is checked to read back as
the items it came from.

## list_campaign and find_campaign

The pools are the iter's `plan/*.yaml` files, globbed rather than named,
so a pool added later is searched with the rest. A campaign's name is
unique across an iter's pools, so `find_campaign` refuses a name listed
twice, naming every pool that lists it, and a name listed nowhere;
`list_campaign` returns the listings, empty for a new name.

## list_old_campaign

A completed campaign keeps its name, so a plan ref, which names no pool,
finds one campaign. It sits in the iter's `old/plan/<pool>/`, or in
`old/task/<pool>/` for an earlier one, as its MD and its own YAML, either
file naming it, since a completed campaign may keep only one of them. The
pool directories holding it are returned, empty for a name no completed
campaign holds.
