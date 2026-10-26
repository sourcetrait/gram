use equip/sourcetrait/gram/lib/iter

# New iters scaffolded in order, each with its indices, state, and bootstrap.
export def main [args: record<iters: list<string>>]: nothing -> record<iters: table<iter: string, path: directory, files: list<path>>> {
    mut made = []
    for namepath in $args.iters {
        $made = ($made | append (iter new $namepath))
    }
    { iters: $made }
}
