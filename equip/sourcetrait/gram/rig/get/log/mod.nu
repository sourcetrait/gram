use equip/sourcetrait/gram/lib/model
use equip/sourcetrait/gram/lib/ref

# Log entries by their GramRefs: each one's rev, summary, and file.
export def main [data: record<refs: list<string>>]: nothing -> record<logs: table<rev: int, summary: string, file: path>> {
    { logs: (model log (ref braced $data.refs)) }
}
