use equip/sourcetrait/gram/lib/ref

# GramRefs' paths and summaries, an iter's top or subiters, in the order asked.
export def main [args: record<refs: list<string>>]: nothing -> record<refs: table<ref: string, path: oneof<nothing, path>, summary: oneof<nothing, string>, nest: oneof<nothing, record<top: string, summary: string, path: directory>, table<sub: string, summary: string, path: directory>>>> {
    { refs: (ref resolve (ref braced $args.refs)) }
}
