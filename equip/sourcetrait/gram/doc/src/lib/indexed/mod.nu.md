# lib/indexed/mod.nu

## entries

The finder the sequence and protocol modules share. The kind names the
index, `<kind>/<kind>.yaml`, the key its entries are listed under, and the
directory holding the index and each entry's `<Name>.md`. Names
are held to letters, digits, `_`, and `-` before a file path is built from
one. Every missing name and every name the index lists twice is named in
one error, before any entry is built, and the files are checked after,
through `common require_files`.
