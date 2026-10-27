use equip/sourcetrait/gram/lib/model
use equip/sourcetrait/gram/lib/ref

# Iters' next, now, and last states by their iter refs.
export def main [data: record<refs: list<string>>]: nothing -> record<states: table<next: record<rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>>, now: record<rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>>, last: record<rev: int, ptr: oneof<nothing, string>, file: oneof<nothing, path>>>> {
    { states: (model state (ref braced $data.refs)) }
}
