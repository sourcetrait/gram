# gram/common/mod.nu

## read_index

An empty index file reads as null, so the read defaults it to an empty
list.

## check_summary

A summary is one line of at most 80 characters, counted as grapheme
clusters, and not blank, whitespace alone counting as blank. `log new`,
`plan new campaign`, and `plan new task` call it before anything is read,
and `kind`, `log` or `plan`, names the summary in the refusal.

## require_files

The check runs outside any `each` and names every missing file at once:
an error raised inside an `each` closure reaches the caller as nushell's
"Eval block failed with pipeline input", its own message an inner error.

## repo_dir_iter

Both separators split the namepath, `foo/bar` and `foo:bar` naming the same
subiter. Each part is held to letters, digits, `_`, and `-`, which refuses
an empty part, `.`, and `..`, so no namepath leaves `iter/`. The iter's own
directory is checked before its categories, so a missing iter is reported
as missing rather than as a category fault. A category is listed with its
hidden entries, since anything in it but a directory breaks the rule.
