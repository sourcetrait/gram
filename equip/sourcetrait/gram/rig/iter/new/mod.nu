use equip/sourcetrait/gram/lib/iter

# A new iter scaffolded: its empty indices, its fresh state, its empty bootstrap.
export def main [args: record<iter: string>]: nothing -> record<iter: string, path: directory, files: list<path>> {
    iter new $args.iter
}
