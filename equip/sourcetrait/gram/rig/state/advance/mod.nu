use equip/sourcetrait/gram/lib/ref
use equip/sourcetrait/gram/lib/state

# An iter's state rolled: now to last, next to now, and the ptr into next.
export def main [args: record<iter: string, ptr: string>]: nothing -> record<rev: int> {
    { rev: (state advance $args.iter (ref braced $args.ptr)) }
}
