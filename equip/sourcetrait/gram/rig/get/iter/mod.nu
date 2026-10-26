use equip/sourcetrait/gram/lib/iter

# An iter's model: its namepath, its directory, its summary, and its nest.
export def main [args: record<iter: string>]: nothing -> record<iter: string, path: directory, summary: string, nest: oneof<record<top: string, summary: string, path: directory>, table<sub: string, summary: string, path: directory>>> {
    iter $args.iter
}
