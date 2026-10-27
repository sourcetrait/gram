use equip/sourcetrait/gram/lib/ref
use equip/sourcetrait/gram/lib/state

# An iter's state rolled: now to last, next to now, and the ptr into next.
export def main [data: record<iter: string, ptr: string>]: nothing -> record<rev: int> {
    { rev: (state advance $data.iter (ref braced $data.ptr)) }
}
