const MOD_DIR = path self .

# The ai repository's root: the git work tree holding these modules.
export def repo_dir []: nothing -> directory {
    let found = (^git -C $MOD_DIR rev-parse --show-toplevel | complete)
    if $found.exit_code != 0 {
        error make --unspanned $"gram sits in no git work tree: ($MOD_DIR)"
    }
    $found.stdout | str trim
}
