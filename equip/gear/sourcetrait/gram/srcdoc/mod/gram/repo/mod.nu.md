# gram/repo/mod.nu

## repo_dir

The root is git's `rev-parse --show-toplevel` from the module's own
location, `path self .` held in a parse-time constant, never from the
caller's working directory, so the tool answers the same from a shell
anywhere and from a run body that imports a gram module by its repository
path. gram expects a git work tree around it; outside one, git's failure
becomes a refusal naming the module's directory.
