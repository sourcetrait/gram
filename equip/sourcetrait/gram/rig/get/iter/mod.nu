use equip/sourcetrait/gram/lib/model
use equip/sourcetrait/gram/lib/ref

# Iters' models by their GramRefs: namepath, directory, summary, and nest.
export def main [args: record<refs: list<string>>]: nothing -> record<iters: table<iter: string, path: directory, summary: string, nest: oneof<record<top: string, summary: string, path: directory>, table<sub: string, summary: string, path: directory>>>> {
    { iters: (model iter (ref braced $args.refs)) }
}
