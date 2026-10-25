# lib/repo/mod.nu

## repo_dir

The root is git's `rev-parse --show-toplevel` run in the caller's working
directory, so gram works on the repository it is run in, from its root or
any directory inside it, wherever gram itself is installed. Outside a git
work tree it refuses, naming the directory.
