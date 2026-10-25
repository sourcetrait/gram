use equip/sourcetrait/gram/lib/ref

# A GramRef's path and indexed summary; braced or braceless.
export def main [args: record<ref: string>]: nothing -> record<ref: string, path: oneof<nothing, path>, summary: oneof<nothing, string>> {
    ref resolve (ref braced $args.ref)
}
