# The repository's root: the git work tree the working directory sits in.
export def repo_dir []: nothing -> directory {
    let found = (^git -C $env.PWD rev-parse --show-toplevel | complete)
    if $found.exit_code != 0 {
        error make --unspanned (
            $"no git work tree at ($env.PWD); gram runs inside one"
        )
    }
    $found.stdout | str trim
}
