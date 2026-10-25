use equip/sourcetrait/gram/lib/state

# An iter's state rolled fresh: now to last, next to now, none into next.
export def main [args: record<iter: string>]: nothing -> record<rev: int> {
    { rev: (state fresh $args.iter) }
}
