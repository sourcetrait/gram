use equip/sourcetrait/gram/lib/ref

# GramRefs' paths and indexed summaries, braced or braceless, in the order asked.
export def main [data: record<refs: list<string>>]: nothing -> record<refs: table<ref: string, path: oneof<nothing, path>, summary: oneof<nothing, string>>> {
    { refs: (ref resolve (ref braced $data.refs)) }
}
