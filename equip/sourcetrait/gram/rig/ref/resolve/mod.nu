use equip/sourcetrait/gram/lib/ref

# GramRefs' paths and summaries, a top iter's subiters, in the order asked.
export def main [args: record<refs: list<string>>]: nothing -> record<refs: table<ref: string, path: oneof<nothing, path>, summary: oneof<nothing, string>, subiters: oneof<nothing, table<iter: path, summary: string, path: directory>>>> {
    { refs: (ref resolve (ref braced $args.refs)) }
}
