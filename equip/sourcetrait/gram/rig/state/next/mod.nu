use equip/sourcetrait/gram/lib/state

# An iter's next state: its rev, its ptr, and the file its ptr names.
export def main [args: record<iter: string>]: nothing -> record<rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>> {
    state next $args.iter
}
