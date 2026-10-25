use equip/sourcetrait/gram/lib/state

# An iter's next, now, and last states in one record.
export def main [args: record<iter: string>]: nothing -> record<next: record<rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>>, now: record<rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>>, last: record<rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>>> {
    state states $args.iter
}
